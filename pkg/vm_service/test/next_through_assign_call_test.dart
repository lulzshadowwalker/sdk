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

const file = 'next_through_assign_call_test.dart';

void code() {
  int? a; // LINE_A
  int? b;
  a = b = foo();
  print(a);
  print(b);
  a = foo();
  print(a);
  int? d = foo();
  print(d);
  int? e = foo(), f, g = foo();
  print(e);
  print(f);
  print(g);
}

int foo() {
  return 42;
}

final stops = <String>[];
const expected = <String>[
  '$file:${LINE_A + 0}:8', // on variable 'a'
  '$file:${LINE_A + 1}:8', // on variable 'b'
  '$file:${LINE_A + 2}:11', // on call to 'foo'
  '$file:${LINE_A + 3}:3', // on call to 'print'
  '$file:${LINE_A + 4}:3', // on call to 'print'
  '$file:${LINE_A + 5}:7', // on call to 'foo'
  '$file:${LINE_A + 6}:3', // on call to 'print'
  '$file:${LINE_A + 7}:12', // on call to 'foo'
  '$file:${LINE_A + 8}:3', // on call to 'print'
  '$file:${LINE_A + 9}:12', // on first call to 'foo'
  '$file:${LINE_A + 9}:19', // on variable 'f'
  '$file:${LINE_A + 9}:26', // on second call to 'foo'
  '$file:${LINE_A + 10}:3', // on call to 'print'
  '$file:${LINE_A + 11}:3', // on call to 'print'
  '$file:${LINE_A + 12}:3', // on call to 'print'
  '$file:${LINE_A + 13}:1' // on ending '}'
];

final tests = <IsolateTest>[
  hasPausedAtStart,
  setBreakpointAtLine(LINE_A),
  runStepThroughProgramRecordingStops(stops),
  checkRecordedStops(stops, expected)
];

void main([args = const <String>[]]) => runIsolateTests(
      args,
      tests,
      'next_through_assign_call_test.dart',
      testeeConcurrent: code,
      pauseOnStart: true,
      pauseOnExit: true,
    );
