// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:analysis_server/lsp_protocol/protocol.dart';
import 'package:analysis_server/src/lsp/constants.dart';
import 'package:analyzer/src/test_utilities/test_code_format.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../lsp/request_helpers_mixin.dart';
import '../../tool/lsp_spec/matchers.dart';
import '../../utils/test_code_extensions.dart';
import '../support/integration_tests.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(LspOverLegacyTest);
  });
}

@reflectiveTest
class LspOverLegacyTest extends AbstractAnalysisServerIntegrationTest
    with LspRequestHelpersMixin {
  @override
  Future<T> expectSuccessfulResponseTo<T, R>(
    RequestMessage message,
    T Function(R) fromJson,
  ) async {
    final legacyResult = await sendLspHandle(message.toJson());
    final lspResponseJson = legacyResult.lspResponse as Map<String, Object?>;

    // Unwrap the LSP response.
    final lspResponse = ResponseMessage.fromJson(lspResponseJson);
    final error = lspResponse.error;
    if (error != null) {
      throw error;
    } else if (T == Null) {
      return lspResponse.result == null
          ? null as T
          : throw 'Expected Null response but got ${lspResponse.result}';
    } else {
      return fromJson(lspResponse.result as R);
    }
  }

  Future<void> test_error_invalidLspRequest() async {
    await standardAnalysisSetup();
    await analysisFinished;

    try {
      await sendLspHandle({'id': '1'});
      fail('expected INVALID_PARAMETER');
    } on ServerErrorMessage catch (message) {
      expect(message.error['code'], 'INVALID_PARAMETER');
      expect(
          message.error['message'],
          "The 'lspMessage' parameter was not a valid LSP request:\n"
          "jsonrpc must not be undefined");
    }
  }

  Future<void> test_error_lspHandlerError() async {
    // This file will not be created.
    final testFile = sourcePath('lib/test.dart');
    await standardAnalysisSetup();
    await analysisFinished;

    await expectLater(
      getHover(Uri.file(testFile), Position(character: 0, line: 0)),
      throwsA(isResponseError(ServerErrorCodes.InvalidFilePath,
          message: 'File does not exist')),
    );
  }

  Future<void> test_hover() async {
    final testFile = sourcePath('lib/test.dart');
    final code = TestCode.parse('''
/// This is my class.
class [!A^aa!] {}
''');

    writeFile(testFile, code.code);
    await standardAnalysisSetup();
    await analysisFinished;

    final result = await getHover(Uri.file(testFile), code.position.position);

    expect(result!.range, code.range.range);
    _expectMarkdown(
      result.contents,
      '''
```dart
class Aaa
```
*package:test/test.dart*

---
This is my class.
''',
    );
  }

  /// Tests the protocol using JSON instead of helpers.
  ///
  /// This is to verify (and document) the exact payloads for  `lsp.handle`
  /// in a way that is not abstracted by (or affected by refactors to) helper
  /// methods to ensure this never changes in a way that will affect clients.
  Future<void> test_hover_rawProtocol() async {
    final testFile = sourcePath('lib/test.dart');
    final code = TestCode.parse('''
/// This is my class.
class [!A^aa!] {}
''');

    const expectedHover = '''
```dart
class Aaa
```
*package:test/test.dart*

---
This is my class.''';

    writeFile(testFile, code.code);
    await standardAnalysisSetup();
    await analysisFinished;

    final response = await server.send('lsp.handle', {
      'lspMessage': {
        'jsonrpc': '2.0',
        'id': '12345',
        'method': Method.textDocument_hover.toString(),
        'params': {
          "textDocument": {"uri": Uri.file(testFile).toString()},
          "position": code.position.position.toJson(),
        },
      }
    });

    expect(response, {
      'lspResponse': {
        'id': '12345',
        'jsonrpc': '2.0',
        'result': {
          'contents': {'kind': 'markdown', 'value': expectedHover},
          'range': code.range.range.toJson()
        }
      }
    });
  }

  void _expectMarkdown(
    Either2<MarkupContent, String> contents,
    String expected,
  ) {
    final markup = contents.map(
      (t1) => t1,
      (t2) => throw 'Hover contents were String, not MarkupContent',
    );

    expect(markup.kind, MarkupKind.Markdown);
    expect(markup.value.trimRight(), expected.trimRight());
  }
}
