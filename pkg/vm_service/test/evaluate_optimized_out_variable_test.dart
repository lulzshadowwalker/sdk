// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Regression test for https://dartbug.com/53996.

import 'package:test/test.dart';
import 'package:vm_service/vm_service.dart';

import 'common/service_test_common.dart';
import 'common/test_helper.dart';

// AUTOGENERATED START
//
// Update these constants by running:
//
// dart pkg/vm_service/test/update_line_numbers.dart <test.dart>
//
const LINE_A = 27;
// AUTOGENERATED END

bool debug = false;

bool bar(int i) {
  if (i == 2) {
    if (debug) {
      print('woke up'); // LINE_A
    }
    return true;
  }
  return false;
}

void foo() {
  final List<int> data = [1, 2, 3];
  for (int i in data) {
    if (bar(i)) {
      break;
    }
  }
}

void testeeMain() {
  // Trigger optimization of [foo].
  for (int i = 0; i < 20; i++) {
    foo();
  }
  debug = true;
  foo();
}

final tests = <IsolateTest>[
  hasPausedAtStart,
  setBreakpointAtLine(LINE_A),
  resumeIsolate,
  hasStoppedAtBreakpoint,
  stoppedAtLine(LINE_A),
  (VmService service, IsolateRef isolateRef) async {
    final isolateId = isolateRef.id!;
    try {
      await service.evaluateInFrame(
        isolateId,
        1,
        'data.length',
      );
      fail('Expected evaluateInFrame to throw an RPCError');
    } on RPCError catch (e) {
      expect(e.code, RPCErrorKind.kExpressionCompilationError.code);
      expect(e.message, 'Expression compilation error');
    }
  },
];

void main([args = const <String>[]]) => runIsolateTests(
      args,
      tests,
      'evaluate_optimized_out_variable_test.dart',
      testeeConcurrent: testeeMain,
      pauseOnStart: true,
      extraArgs: const [
        '--deterministic',
        '--prune-dead-locals',
        '--optimization-counter-threshold=10',
      ],
    );
