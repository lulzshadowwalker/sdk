// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart' show ResourceIdentifier;

void main() {
  print(SomeClass.setMetadata(42));
}

class SomeClass {
  @ResourceIdentifier({'a set'})
  static setMetadata(int i) {
    return i + 1;
  }
}
