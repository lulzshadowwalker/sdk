// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
//
// OtherResources=deferred_import_reload/v1/main.dart deferred_import_reload/v1/deferred.dart deferred_import_reload/v2/main.dart deferred_import_reload/v2/deferred.dart

import 'dart:async';
import 'dart:developer';
import 'dart:isolate' as I;
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:vm_service/vm_service.dart';
import 'package:test/test.dart';

import 'common/service_test_common.dart';
import 'common/test_helper.dart';

// AUTOGENERATED START
//
// Update these constants by running:
//
// dart pkg/vm_service/test/update_line_numbers.dart <test.dart>
//
const LINE_A = 40;
const LINE_B = 55;
// AUTOGENERATED END

// Chop off the file name.
String baseDirectory = path.dirname(Platform.script.path) + '/';

Uri baseUri = Platform.script.replace(path: baseDirectory);
Uri spawnUri =
    baseUri.resolveUri(Uri.parse('deferred_import_reload/v1/main.dart'));
Uri v2Uri =
    baseUri.resolveUri(Uri.parse('deferred_import_reload/v2/main.dart'));

Future<void> testMain() async {
  debugger(); // LINE_A

  final receivePort = I.ReceivePort();
  final completer = Completer<void>();
  late final StreamSubscription sub;
  sub = receivePort.listen((_) {
    completer.complete();
    sub.cancel();
    receivePort.close();
  });

  // Spawn the child isolate and wait for it to finish loading the deferred
  // library.
  await I.Isolate.spawnUri(spawnUri, [], receivePort.sendPort);
  await completer.future;
  debugger(); // LINE_B
}

Future<String> invokeTest(VmService service, IsolateRef isolateRef) async {
  final isolateId = isolateRef.id!;
  final isolate = await service.getIsolate(isolateId);
  final result = await service.evaluate(
      isolateId, isolate.rootLib!.id!, 'test()') as InstanceRef;
  expect(result.kind, InstanceKind.kString);
  return result.valueAsString!;
}

final tests = <IsolateTest>[
  // Stopped at 'debugger' statement.
  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_A),
  // Resume the isolate into the while loop.
  resumeIsolate,
  // Stop at 'debugger' statement.
  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_B),
  (VmService service, IsolateRef mainIsolate) async {
    // Grab the VM.
    final vm = await service.getVM();
    final isolates = vm.isolates!;
    expect(isolates.length, 2);

    // Find the spawned isolate.
    final spawnedIsolate = isolates.firstWhereOrNull(
      (IsolateRef i) => i != mainIsolate,
    );
    expect(spawnedIsolate, isNotNull);

    // Invoke test in v1.
    final v1 = await invokeTest(service, spawnedIsolate!);
    expect(v1, 'apple,error');

    // Reload to v2.
    final response = await service.reloadSources(
      spawnedIsolate.id!,
      rootLibUri: v2Uri.toString(),
    );
    // Observe that it succeed.
    expect(response.success, isTrue);

    final v2 = await invokeTest(service, spawnedIsolate);
    expect(v2, 'orange,error');
  }
];

void main(List<String> args) => runIsolateTests(
      args,
      tests,
      'deferred_import_reload_test.dart',
      testeeConcurrent: testMain,
    );
