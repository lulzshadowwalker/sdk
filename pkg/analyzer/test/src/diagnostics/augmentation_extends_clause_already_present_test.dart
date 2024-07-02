// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/src/error/codes.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../dart/resolution/context_collection_resolution.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AugmentationExtendsClauseAlreadyPresentTest);
  });
}

@reflectiveTest
class AugmentationExtendsClauseAlreadyPresentTest
    extends PubPackageResolutionTest {
  test_alreadyPresent() async {
    var a = newFile('$testPackageLibPath/a.dart', r'''
import augment 'test.dart';

class A {}

class B extends A {};
''');

    await assertErrorsInCode(r'''
augment library 'a.dart';

augment class B extends A {}
''', [
      error(CompileTimeErrorCode.AUGMENTATION_EXTENDS_CLAUSE_ALREADY_PRESENT,
          43, 7,
          contextMessages: [message(a, 47, 1)]),
    ]);
  }

  test_alreadyPresent2() async {
    var a = newFile('$testPackageLibPath/a.dart', r'''
import augment 'b.dart';
import augment 'test.dart';

class A {}

class B extends A {};
''');

    newFile('$testPackageLibPath/b.dart', r'''
augment library 'a.dart';

augment class B {}
''');

    await assertErrorsInCode(r'''
augment library 'a.dart';

augment class B extends A {}
''', [
      error(CompileTimeErrorCode.AUGMENTATION_EXTENDS_CLAUSE_ALREADY_PRESENT,
          43, 7,
          contextMessages: [message(a, 72, 1)]),
    ]);
  }

  test_notPresent() async {
    newFile('$testPackageLibPath/a.dart', r'''
import augment 'test.dart';

class A {}

class B {};
''');

    await assertNoErrorsInCode(r'''
augment library 'a.dart';

augment class B extends A {}
''');
  }
}
