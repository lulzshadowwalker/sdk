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

const file = 'next_through_multi_catch_test.dart';

void code() {
  try /* LINE_A */ {
    throw 'Boom!';
  } on StateError {
    print('StateError');
  } on ArgumentError catch (e) {
    print('ArgumentError: $e');
  } catch (e) {
    print(e);
  }
}

final stops = <String>[];
const expected = <String>[
  '$file:${LINE_A + 1}:5', // on 'throw'
  '$file:${LINE_A + 2}:5', // on 'on'
  '$file:${LINE_A + 4}:5', // on 'on'
  '$file:${LINE_A + 7}:5', // on 'print'
  '$file:${LINE_A + 9}:1', // on ending '}'
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
      'next_through_multi_catch_test.dart',
      testeeConcurrent: code,
      pauseOnStart: true,
      pauseOnExit: true,
    );
