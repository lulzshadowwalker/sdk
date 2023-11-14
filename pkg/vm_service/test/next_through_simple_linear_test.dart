// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'common/service_test_common.dart';
import 'common/test_helper.dart';

// AUTOGENERATED START
//
// Update these constants by running:
//
// dart pkg/vm_service/test/update_line_numbers.dart <test.dart>
//
const LINE_A = 20;
// AUTOGENERATED END

const file = 'next_through_simple_linear_test.dart';

void code() {
  print('Hello, World!'); // LINE_A
  print('Stop here too!');
  print('Goodbye, world!');
}

final stops = <String>[];
const expected = <String>[
  '$file:${LINE_A + 0}:3', // on call to 'print'
  '$file:${LINE_A + 1}:3', // on call to 'print'
  '$file:${LINE_A + 2}:3', // on call to 'print'
  '$file:${LINE_A + 3}:1' // on ending '}'
];

final tests = <IsolateTest>[
  hasPausedAtStart,
  setBreakpointAtLine(LINE_A),
  runStepThroughProgramRecordingStops(stops),
  checkRecordedStops(stops, expected),
];

void main([args = const <String>[]]) => runIsolateTests(
      args,
      tests,
      'next_through_simple_linear_test.dart',
      testeeConcurrent: code,
      pauseOnStart: true,
      pauseOnExit: true,
    );
