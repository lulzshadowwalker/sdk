// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:compiler/src/util/testing.dart';

main() {
  /*spec.checks=[$signature],instance*/
  /*prod.checks=[],instance*/ T id<T>(T t) => t;
  int Function(int) x = id;
  makeLive("${x.runtimeType}");
}
