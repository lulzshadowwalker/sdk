// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../../../../client/completion_driver_test.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PropertyAccessTest);
  });
}

@reflectiveTest
class PropertyAccessTest extends AbstractCompletionDriverTest
    with PropertyAccessTestCases {
  @failingTest
  Future<void> test_afterIdentifier_partial_if() async {
    allowedIdentifiers = {'always', 'ifPresent'};
    await computeSuggestions('''
enum E {
  always, ifPresent
}
void f() {
  E.if^;
}
''');
    assertResponse(r'''
replacement
  left: 2
suggestions
  ifPresent
    kind: enumConstant
''');
  }
}

mixin PropertyAccessTestCases on AbstractCompletionDriverTest {
  Future<void> test_afterGetter() async {
    await computeSuggestions('''
class A { int x; foo() {x.^}}
''');
    assertResponse(r'''
suggestions
''');
  }

  Future<void> test_afterIdentifier() async {
    await computeSuggestions('''
class A { foo() {bar.^}}
''');
    assertResponse(r'''
suggestions
''');
  }

  Future<void> test_afterIdentifier_beforeAwait() async {
    await computeSuggestions('''
void f(A a) async {
  a.^
  await a.foo();
}

class A {
  void m01() {}
}
''');
    assertResponse(r'''
suggestions
  m01
    kind: methodInvocation
''');
  }

  Future<void> test_afterIdentifier_beforeAwait_partial() async {
    await computeSuggestions('''
void f(A a) async {
  a.m0^ 
  await 0;
}

class A {
  void m01() {}
}
''');
    assertResponse(r'''
replacement
  left: 2
suggestions
  m01
    kind: methodInvocation
''');
  }

  Future<void> test_afterIdentifier_beforeIdentifier_partial() async {
    allowedIdentifiers = {'length'};
    await computeSuggestions('''
void f(String x) {
  x.len^
  foo();
}
''');
    assertResponse(r'''
replacement
  left: 3
suggestions
  length
    kind: getter
''');
  }

  Future<void>
      test_afterIdentifier_beforeIdentifier_partial_importPrefix() async {
    newFile('$testPackageLibPath/a.dart', r'''
void v01() {}
void g01() {}
''');

    // There should be no `void`, we use `v` to verify this.
    await computeSuggestions('''
import 'a.dart' as prefix;

void f() {
  prefix.v^
  print(0);
}
''');

    assertResponse(r'''
replacement
  left: 1
suggestions
  v01
    kind: functionInvocation
''');
  }

  Future<void> test_afterIdentifier_partial() async {
    await computeSuggestions('''
class A { foo() {bar.as^}}
''');
    assertResponse(r'''
replacement
  left: 2
suggestions
''');
  }

  Future<void> test_afterInstanceCreation() async {
    await computeSuggestions('''
class A { get x => 7; foo() {new A().^}}
''');
    assertResponse(r'''
suggestions
''');
  }

  Future<void> test_afterLibraryPrefix() async {
    await computeSuggestions('''
import "b" as b; class A { foo() {b.^}}
''');
    assertResponse(r'''
suggestions
''');
  }

  Future<void> test_afterLocalVariable() async {
    await computeSuggestions('''
class A { foo() {int x; x.^}}
''');
    assertResponse(r'''
suggestions
''');
  }
}
