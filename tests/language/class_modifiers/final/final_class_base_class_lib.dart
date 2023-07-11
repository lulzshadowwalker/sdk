// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Library for having a `final` subtype on a `base` superclass outside its
// library.

base class BaseClass {
  int foo = 0;
}

base mixin BaseMixin {
  int foo = 0;
}
