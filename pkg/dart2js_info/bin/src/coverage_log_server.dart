// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: avoid_dynamic_calls

/// A tool to gather coverage data from an app generated with dart2js. This
/// depends on code that has been landed in the bleeding_edge version of dart2js
/// and that we expect to become publicly visible in version 0.13.0 of the Dart
/// SDK).
///
/// This tool starts a server that answers to mainly 2 requests:
///    * a GET request to retrieve the application
///    * POST requests to record coverage data.
///
/// It is intended to be used as follows:
///    * generate an app by running dart2js with the environment value
///      -DtraceCalls=post provided to the vm, and the --dump-info
///      flag provided to dart2js.
///    * start this server, and proxy requests from your normal frontend
///      server to this one.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf;

import 'usage_exception.dart';

class CoverageLogServerCommand extends Command<void> with PrintUsageException {
  @override
  final String name = 'coverage_server';
  @override
  final String description = 'Server to gather code coverage data';

  CoverageLogServerCommand() {
    argParser
      ..addOption('port', abbr: 'p', help: 'port number', defaultsTo: "8080")
      ..addOption('host',
          help: 'host name (use 0.0.0.0 for all interfaces)',
          defaultsTo: 'localhost')
      ..addOption('uri-prefix',
          help:
              'uri path prefix that will hit this server. This will be injected'
              ' into the .js file',
          defaultsTo: '')
      ..addOption('out',
          abbr: 'o', help: 'output log file', defaultsTo: _defaultOutTemplate);
  }

  @override
  void run() async {
    final args = argResults!;
    if (args.rest.isEmpty) {
      usageException('Missing arguments: <dart2js-out-file> [<html-file>]');
    }

    var jsPath = args.rest[0];
    String? htmlPath;
    if (args.rest.length > 1) {
      htmlPath = args.rest[1];
    }
    var outPath = args['out'];
    if (outPath == _defaultOutTemplate) outPath = '$jsPath.coverage.json';
    var server = _Server(args['host'], int.parse(args['port']), jsPath,
        htmlPath, outPath, args['uri-prefix']);
    await server.run();
  }
}

const _defaultOutTemplate = '<dart2js-out-file>.coverage.json';

class _Server {
  /// Server hostname, typically `localhost`,  but can be `0.0.0.0`.
  final String hostname;

  /// Port the server will listen to.
  final int port;

  /// JS file (previously generated by dart2js) to serve.
  final String jsPath;

  /// HTML file to serve, if any.
  final String? htmlPath;

  /// Contents of jsPath, adjusted to use the appropriate server url.
  String jsCode;

  /// Location where we'll dump the coverage data.
  final String outPath;

  /// Uri prefix used on all requests to this server. This will be injected into
  /// the .js file.
  final String prefix;

  // TODO(sigmund): add support to load also simple HTML files to test small
  // simple apps.

  /// Data received so far. The data is just an array of pairs, showing the
  /// hashCode and name of the element used. This can be later cross-checked
  /// against dump-info data.
  Map data = {};

  String get _serializedData => JsonEncoder.withIndent(' ').convert(data);

  _Server(this.hostname, this.port, this.jsPath, this.htmlPath, this.outPath,
      String prefix)
      : jsCode = _adjustRequestUrl(File(jsPath).readAsStringSync(), prefix),
        prefix = _normalize(prefix);

  Future<void> run() async {
    await shelf.serve(_handler, hostname, port);
    var urlBase = "http://$hostname:$port${prefix == '' ? '/' : '/$prefix/'}";
    var htmlFilename = htmlPath == null ? '' : path.basename(htmlPath!);
    print("Server is listening\n"
        "  - html page: $urlBase$htmlFilename\n"
        "  - js code: $urlBase${path.basename(jsPath)}\n"
        "  - coverage reporting: ${urlBase}coverage\n");
  }

  String _expectedPath(String tail) => prefix == '' ? tail : '$prefix/$tail';

  FutureOr<shelf.Response> _handler(shelf.Request request) async {
    var urlPath = request.url.path;
    print('received request: $urlPath');
    var baseJsName = path.basename(jsPath);
    var baseHtmlName = htmlPath == null ? '' : path.basename(htmlPath!);

    // Serve an HTML file at the default prefix, or a path matching the HTML
    // file name
    if (urlPath == prefix ||
        urlPath == '$prefix/' ||
        urlPath == _expectedPath(baseHtmlName)) {
      var contents = htmlPath == null
          ? '<html><script src="$baseJsName"></script>'
          : await File(htmlPath!).readAsString();
      return shelf.Response.ok(contents, headers: _htmlHeaders);
    }

    if (urlPath == _expectedPath(baseJsName)) {
      return shelf.Response.ok(jsCode, headers: _jsHeaders);
    }

    // Handle POST requests to record coverage data, and GET requests to display
    // the currently coverage results.
    if (urlPath == _expectedPath('coverage')) {
      if (request.method == 'GET') {
        return shelf.Response.ok(_serializedData, headers: _textHeaders);
      }

      if (request.method == 'POST') {
        _record(jsonDecode(await request.readAsString()));
        return shelf.Response.ok("Thanks!");
      }
    }

    // Any other request is not supported.
    return shelf.Response.notFound('Not found: "$urlPath"');
  }

  void _record(List entries) {
    for (var entry in entries) {
      var id = entry[0];
      data.putIfAbsent('$id', () => {'name': entry[1], 'count': 0});
      data['$id']['count']++;
    }
    _enqueueSave();
  }

  bool _savePending = false;
  int _total = 0;
  Future<void> _enqueueSave() async {
    if (!_savePending) {
      _savePending = true;
      await Future.delayed(Duration(seconds: 3));
      await File(outPath).writeAsString(_serializedData);
      var diff = data.length - _total;
      print(diff == 0
          ? ' - no new element covered'
          : ' - $diff new elements covered');
      _savePending = false;
      _total = data.length;
    }
  }
}

/// Removes leading and trailing slashes of [uriPath].
String _normalize(String uriPath) {
  if (uriPath.startsWith('/')) uriPath = uriPath.substring(1);
  if (uriPath.endsWith('/')) uriPath = uriPath.substring(0, uriPath.length - 1);
  return uriPath;
}

String _adjustRequestUrl(String code, String prefix) {
  var url = prefix == '' ? 'coverage' : '$prefix/coverage';
  var hook = '''
      self.dartCallInstrumentation = function(id, name) {
        if (!this.traceBuffer) {
          this.traceBuffer = [];
        }
        var buffer = this.traceBuffer;
        if (buffer.length == 0) {
          window.setTimeout(function() {
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "/$url");
              xhr.send(JSON.stringify(buffer));
              buffer.length = 0;
            }, 1000);
        }
        buffer.push([id, name]);
     };
     ''';
  return '$hook$code';
}

const _htmlHeaders = {'content-type': 'text/html'};
const _jsHeaders = {'content-type': 'text/javascript'};
const _textHeaders = {'content-type': 'text/plain'};
