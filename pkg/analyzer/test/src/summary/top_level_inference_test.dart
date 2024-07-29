// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/error/codes.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../dart/resolution/node_text_expectations.dart';
import 'elements_base.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(TopLevelInferenceTest);
    defineReflectiveTests(TopLevelInferenceErrorsTest);
    defineReflectiveTests(UpdateNodeTextExpectations);
  });
}

@reflectiveTest
class TopLevelInferenceErrorsTest extends ElementsBaseTest {
  @override
  bool get keepLinkingLibraries => true;

  test_initializer_additive() async {
    await _assertErrorOnlyLeft(['+', '-']);
  }

  test_initializer_assign() async {
    await assertNoErrorsInCode('''
var a = 1;
var t1 = a += 1;
var t2 = a = 2;
''');
  }

  test_initializer_binary_onlyLeft() async {
    await assertNoErrorsInCode('''
var a = 1;
var t = (a = 1) + (a = 2);
''');
  }

  test_initializer_bitwise() async {
    await _assertErrorOnlyLeft(['&', '|', '^']);
  }

  test_initializer_boolean() async {
    await assertNoErrorsInCode('''
var a = 1;
var t1 = ((a = 1) == 0) || ((a = 2) == 0);
var t2 = ((a = 1) == 0) && ((a = 2) == 0);
var t3 = !((a = 1) == 0);
''');
  }

  test_initializer_cascade() async {
    await assertNoErrorsInCode('''
var a = 0;
var t = (a = 1)..isEven;
''');
  }

  test_initializer_classField_instance_instanceCreation() async {
    await assertNoErrorsInCode('''
class A<T> {}
class B {
  var t1 = new A<int>();
  var t2 = new A();
}
''');
  }

  test_initializer_classField_static_instanceCreation() async {
    await assertNoErrorsInCode('''
class A<T> {}
class B {
  static var t1 = 1;
  static var t2 = new A();
}
''');
  }

  test_initializer_conditional() async {
    await assertNoErrorsInCode('''
var a = 1;
var b = true;
var t = b
    ? (a = 1)
    : (a = 2);
''');
  }

  test_initializer_dependencyCycle() async {
    await assertErrorsInCode('''
var a = b;
var b = a;
''', [
      error(CompileTimeErrorCode.TOP_LEVEL_CYCLE, 4, 1),
      error(CompileTimeErrorCode.TOP_LEVEL_CYCLE, 15, 1),
    ]);
  }

  test_initializer_equality() async {
    await assertNoErrorsInCode('''
var a = 1;
var t1 = ((a = 1) == 0) == ((a = 2) == 0);
var t2 = ((a = 1) == 0) != ((a = 2) == 0);
''');
  }

  test_initializer_extractIndex() async {
    await assertNoErrorsInCode('''
var a = [0, 1.2];
var b0 = a[0];
var b1 = a[1];
''');
  }

  test_initializer_functionLiteral_blockBody() async {
    await assertNoErrorsInCode('''
var t = (int p) {};
''');
    assertType(
      findElement.topVar('t').type,
      'Null Function(int)',
    );
  }

  test_initializer_functionLiteral_expressionBody() async {
    await assertNoErrorsInCode('''
var a = 0;
var t = (int p) => (a = 1);
''');
    assertType(
      findElement.topVar('t').type,
      'int Function(int)',
    );
  }

  test_initializer_functionLiteral_parameters_withoutType() async {
    await assertNoErrorsInCode('''
var t = (int a, b,int c, d) => 0;
''');
    assertType(
      findElement.topVar('t').type,
      'int Function(int, dynamic, int, dynamic)',
    );
  }

  test_initializer_hasTypeAnnotation() async {
    await assertNoErrorsInCode('''
var a = 1;
int t = (a = 1);
''');
  }

  test_initializer_identifier() async {
    await assertNoErrorsInCode('''
int top_function() => 0;
var top_variable = 0;
int get top_getter => 0;
class A {
  static var static_field = 0;
  static int get static_getter => 0;
  static int static_method() => 0;
  int instance_method() => 0;
}
var t1 = top_function;
var t2 = top_variable;
var t3 = top_getter;
var t4 = A.static_field;
var t5 = A.static_getter;
var t6 = A.static_method;
var t7 = new A().instance_method;
''');
  }

  test_initializer_identifier_error() async {
    await assertNoErrorsInCode('''
var a = 0;
var b = (a = 1);
var c = b;
''');
  }

  test_initializer_ifNull() async {
    await assertNoErrorsInCode('''
int? a = 1;
var t = a ?? 2;
''');
  }

  test_initializer_instanceCreation_withoutTypeParameters() async {
    await assertNoErrorsInCode('''
class A {}
var t = new A();
''');
  }

  test_initializer_instanceCreation_withTypeParameters() async {
    await assertNoErrorsInCode('''
class A<T> {}
var t1 = new A<int>();
var t2 = new A();
''');
  }

  test_initializer_instanceGetter() async {
    await assertNoErrorsInCode('''
class A {
  int f = 1;
}
var a = new A().f;
''');
  }

  test_initializer_methodInvocation_function() async {
    await assertNoErrorsInCode('''
int f1() => 0;
T f2<T>() => throw 0;
var t1 = f1();
var t2 = f2();
var t3 = f2<int>();
''');
  }

  test_initializer_methodInvocation_method() async {
    await assertNoErrorsInCode('''
class A {
  int m1() => 0;
  T m2<T>() => throw 0;
}
var a = new A();
var t1 = a.m1();
var t2 = a.m2();
var t3 = a.m2<int>();
''');
  }

  test_initializer_multiplicative() async {
    await _assertErrorOnlyLeft(['*', '/', '%', '~/']);
  }

  test_initializer_postfixIncDec() async {
    await assertNoErrorsInCode('''
var a = 1;
var t1 = a++;
var t2 = a--;
''');
  }

  test_initializer_prefixIncDec() async {
    await assertNoErrorsInCode('''
var a = 1;
var t1 = ++a;
var t2 = --a;
''');
  }

  test_initializer_relational() async {
    await _assertErrorOnlyLeft(['>', '>=', '<', '<=']);
  }

  test_initializer_shift() async {
    await _assertErrorOnlyLeft(['<<', '>>']);
  }

  test_initializer_typedList() async {
    await assertNoErrorsInCode('''
var a = 1;
var t = <int>[a = 1];
''');
  }

  test_initializer_typedMap() async {
    await assertNoErrorsInCode('''
var a = 1;
var t = <int, int>{(a = 1) : (a = 2)};
''');
  }

  test_initializer_untypedList() async {
    await assertNoErrorsInCode('''
var a = 1;
var t = [
    a = 1,
    2,
    3,
];
''');
  }

  test_initializer_untypedMap() async {
    await assertNoErrorsInCode('''
var a = 1;
var t = {
    (a = 1) :
        (a = 2),
};
''');
  }

  test_override_conflictFieldType() async {
    await assertErrorsInCode('''
abstract class A {
  int aaa = 0;
}
abstract class B {
  String aaa = '0';
}
class C implements A, B {
  var aaa;
}
''', [
      error(CompileTimeErrorCode.INVALID_OVERRIDE, 109, 3,
          contextMessages: [message(testFile, 64, 3)]),
      error(CompileTimeErrorCode.INVALID_OVERRIDE, 109, 3,
          contextMessages: [message(testFile, 25, 3)]),
    ]);
  }

  test_override_conflictParameterType_method() async {
    await assertErrorsInCode('''
abstract class A {
  void mmm(int a);
}
abstract class B {
  void mmm(String a);
}
class C implements A, B {
  void mmm(a) {}
}
''', [
      error(CompileTimeErrorCode.NO_COMBINED_SUPER_SIGNATURE, 116, 3),
    ]);
  }

  Future<void> _assertErrorOnlyLeft(List<String> operators) async {
    String code = 'var a = 1;\n';
    for (var i = 0; i < operators.length; i++) {
      String operator = operators[i];
      code += 'var t$i = (a = 1) $operator (a = 2);\n';
    }
    await assertNoErrorsInCode(code);
  }
}

@reflectiveTest
class TopLevelInferenceTest extends ElementsBaseTest {
  @override
  bool get keepLinkingLibraries => true;

  test_initializer_additive() async {
    var library = await _encodeDecodeLibrary(r'''
var vPlusIntInt = 1 + 2;
var vPlusIntDouble = 1 + 2.0;
var vPlusDoubleInt = 1.0 + 2;
var vPlusDoubleDouble = 1.0 + 2.0;
var vMinusIntInt = 1 - 2;
var vMinusIntDouble = 1 - 2.0;
var vMinusDoubleInt = 1.0 - 2;
var vMinusDoubleDouble = 1.0 - 2.0;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static vPlusIntInt @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vPlusIntInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vPlusIntDouble @29
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vPlusIntDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vPlusDoubleInt @59
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vPlusDoubleInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vPlusDoubleDouble @89
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vPlusDoubleDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vMinusIntInt @124
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vMinusIntInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vMinusIntDouble @150
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vMinusIntDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vMinusDoubleInt @181
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vMinusDoubleInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vMinusDoubleDouble @212
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vMinusDoubleDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vPlusIntInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vPlusIntInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vPlusIntInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vPlusIntInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vPlusIntInt @-1
            type: int
        returnType: void
      synthetic static get vPlusIntDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vPlusIntDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vPlusIntDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vPlusIntDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vPlusIntDouble @-1
            type: double
        returnType: void
      synthetic static get vPlusDoubleInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vPlusDoubleInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vPlusDoubleInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vPlusDoubleInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vPlusDoubleInt @-1
            type: double
        returnType: void
      synthetic static get vPlusDoubleDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vPlusDoubleDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vPlusDoubleDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vPlusDoubleDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vPlusDoubleDouble @-1
            type: double
        returnType: void
      synthetic static get vMinusIntInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vMinusIntInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vMinusIntInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vMinusIntInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vMinusIntInt @-1
            type: int
        returnType: void
      synthetic static get vMinusIntDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vMinusIntDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vMinusIntDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vMinusIntDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vMinusIntDouble @-1
            type: double
        returnType: void
      synthetic static get vMinusDoubleInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vMinusDoubleInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vMinusDoubleInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vMinusDoubleInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vMinusDoubleInt @-1
            type: double
        returnType: void
      synthetic static get vMinusDoubleDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vMinusDoubleDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vMinusDoubleDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vMinusDoubleDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vMinusDoubleDouble @-1
            type: double
        returnType: void
''');
  }

  test_initializer_as() async {
    var library = await _encodeDecodeLibrary(r'''
var V = 1 as num;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static V @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::V
        enclosingElement: <thisLibrary>::<definingUnit>
        type: num
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get V @-1
        reference: <thisLibrary>::<definingUnit>::@getter::V
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: num
      synthetic static set V= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::V
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _V @-1
            type: num
        returnType: void
''');
  }

  test_initializer_assign() async {
    var library = await _encodeDecodeLibrary(r'''
var a = 1;
var t1 = (a = 2);
var t2 = (a += 2);
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static a @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::a
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static t1 @15
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::t1
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static t2 @33
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::t2
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get a @-1
        reference: <thisLibrary>::<definingUnit>::@getter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set a= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _a @-1
            type: int
        returnType: void
      synthetic static get t1 @-1
        reference: <thisLibrary>::<definingUnit>::@getter::t1
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set t1= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::t1
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _t1 @-1
            type: int
        returnType: void
      synthetic static get t2 @-1
        reference: <thisLibrary>::<definingUnit>::@getter::t2
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set t2= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::t2
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _t2 @-1
            type: int
        returnType: void
''');
  }

  test_initializer_assign_indexed() async {
    var library = await _encodeDecodeLibrary(r'''
var a = [0];
var t1 = (a[0] = 2);
var t2 = (a[0] += 2);
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static a @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::a
        enclosingElement: <thisLibrary>::<definingUnit>
        type: List<int>
        shouldUseTypeForInitializerInference: false
      static t1 @17
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::t1
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static t2 @38
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::t2
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get a @-1
        reference: <thisLibrary>::<definingUnit>::@getter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: List<int>
      synthetic static set a= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _a @-1
            type: List<int>
        returnType: void
      synthetic static get t1 @-1
        reference: <thisLibrary>::<definingUnit>::@getter::t1
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set t1= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::t1
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _t1 @-1
            type: int
        returnType: void
      synthetic static get t2 @-1
        reference: <thisLibrary>::<definingUnit>::@getter::t2
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set t2= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::t2
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _t2 @-1
            type: int
        returnType: void
''');
  }

  test_initializer_assign_prefixed() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  int f;
}
var a = new A();
var t1 = (a.f = 1);
var t2 = (a.f += 2);
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          f @16
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          synthetic get f @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
          synthetic set f= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _f @-1
                type: int
            returnType: void
    topLevelVariables
      static a @25
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::a
        enclosingElement: <thisLibrary>::<definingUnit>
        type: A
        shouldUseTypeForInitializerInference: false
      static t1 @42
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::t1
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static t2 @62
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::t2
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get a @-1
        reference: <thisLibrary>::<definingUnit>::@getter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: A
      synthetic static set a= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _a @-1
            type: A
        returnType: void
      synthetic static get t1 @-1
        reference: <thisLibrary>::<definingUnit>::@getter::t1
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set t1= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::t1
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _t1 @-1
            type: int
        returnType: void
      synthetic static get t2 @-1
        reference: <thisLibrary>::<definingUnit>::@getter::t2
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set t2= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::t2
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _t2 @-1
            type: int
        returnType: void
''');
  }

  test_initializer_assign_prefixed_viaInterface() async {
    var library = await _encodeDecodeLibrary(r'''
class I {
  int f;
}
abstract class C implements I {}
C c;
var t1 = (c.f = 1);
var t2 = (c.f += 2);
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class I @6
        reference: <thisLibrary>::<definingUnit>::@class::I
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          f @16
            reference: <thisLibrary>::<definingUnit>::@class::I::@field::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::I
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::I::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::I
        accessors
          synthetic get f @-1
            reference: <thisLibrary>::<definingUnit>::@class::I::@getter::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::I
            returnType: int
          synthetic set f= @-1
            reference: <thisLibrary>::<definingUnit>::@class::I::@setter::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::I
            parameters
              requiredPositional _f @-1
                type: int
            returnType: void
      abstract class C @36
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          I
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
    topLevelVariables
      static c @56
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::c
        enclosingElement: <thisLibrary>::<definingUnit>
        type: C
      static t1 @63
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::t1
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static t2 @83
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::t2
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get c @-1
        reference: <thisLibrary>::<definingUnit>::@getter::c
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: C
      synthetic static set c= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::c
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _c @-1
            type: C
        returnType: void
      synthetic static get t1 @-1
        reference: <thisLibrary>::<definingUnit>::@getter::t1
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set t1= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::t1
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _t1 @-1
            type: int
        returnType: void
      synthetic static get t2 @-1
        reference: <thisLibrary>::<definingUnit>::@getter::t2
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set t2= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::t2
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _t2 @-1
            type: int
        returnType: void
''');
  }

  test_initializer_assign_viaInterface() async {
    var library = await _encodeDecodeLibrary(r'''
class I {
  int f;
}
abstract class C implements I {}
C getC() => null;
var t1 = (getC().f = 1);
var t2 = (getC().f += 2);
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class I @6
        reference: <thisLibrary>::<definingUnit>::@class::I
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          f @16
            reference: <thisLibrary>::<definingUnit>::@class::I::@field::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::I
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::I::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::I
        accessors
          synthetic get f @-1
            reference: <thisLibrary>::<definingUnit>::@class::I::@getter::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::I
            returnType: int
          synthetic set f= @-1
            reference: <thisLibrary>::<definingUnit>::@class::I::@setter::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::I
            parameters
              requiredPositional _f @-1
                type: int
            returnType: void
      abstract class C @36
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          I
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
    topLevelVariables
      static t1 @76
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::t1
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static t2 @101
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::t2
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get t1 @-1
        reference: <thisLibrary>::<definingUnit>::@getter::t1
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set t1= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::t1
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _t1 @-1
            type: int
        returnType: void
      synthetic static get t2 @-1
        reference: <thisLibrary>::<definingUnit>::@getter::t2
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set t2= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::t2
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _t2 @-1
            type: int
        returnType: void
    functions
      getC @56
        reference: <thisLibrary>::<definingUnit>::@function::getC
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: C
''');
  }

  test_initializer_await() async {
    var library = await _encodeDecodeLibrary(r'''
import 'dart:async';
int fValue() => 42;
Future<int> fFuture() async => 42;
var uValue = () async => await fValue();
var uFuture = () async => await fFuture();
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  libraryImports
    dart:async
      enclosingElement: <thisLibrary>
      enclosingElement3: <thisLibrary>::<definingUnit>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    libraryImports
      dart:async
        enclosingElement: <thisLibrary>
        enclosingElement3: <thisLibrary>::<definingUnit>
    topLevelVariables
      static uValue @80
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::uValue
        enclosingElement: <thisLibrary>::<definingUnit>
        type: Future<int> Function()
        shouldUseTypeForInitializerInference: false
      static uFuture @121
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::uFuture
        enclosingElement: <thisLibrary>::<definingUnit>
        type: Future<int> Function()
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get uValue @-1
        reference: <thisLibrary>::<definingUnit>::@getter::uValue
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: Future<int> Function()
      synthetic static set uValue= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::uValue
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _uValue @-1
            type: Future<int> Function()
        returnType: void
      synthetic static get uFuture @-1
        reference: <thisLibrary>::<definingUnit>::@getter::uFuture
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: Future<int> Function()
      synthetic static set uFuture= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::uFuture
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _uFuture @-1
            type: Future<int> Function()
        returnType: void
    functions
      fValue @25
        reference: <thisLibrary>::<definingUnit>::@function::fValue
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      fFuture @53 async
        reference: <thisLibrary>::<definingUnit>::@function::fFuture
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: Future<int>
''');
  }

  test_initializer_bitwise() async {
    var library = await _encodeDecodeLibrary(r'''
var vBitXor = 1 ^ 2;
var vBitAnd = 1 & 2;
var vBitOr = 1 | 2;
var vBitShiftLeft = 1 << 2;
var vBitShiftRight = 1 >> 2;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static vBitXor @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vBitXor
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vBitAnd @25
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vBitAnd
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vBitOr @46
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vBitOr
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vBitShiftLeft @66
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vBitShiftLeft
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vBitShiftRight @94
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vBitShiftRight
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vBitXor @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vBitXor
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vBitXor= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vBitXor
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vBitXor @-1
            type: int
        returnType: void
      synthetic static get vBitAnd @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vBitAnd
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vBitAnd= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vBitAnd
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vBitAnd @-1
            type: int
        returnType: void
      synthetic static get vBitOr @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vBitOr
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vBitOr= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vBitOr
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vBitOr @-1
            type: int
        returnType: void
      synthetic static get vBitShiftLeft @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vBitShiftLeft
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vBitShiftLeft= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vBitShiftLeft
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vBitShiftLeft @-1
            type: int
        returnType: void
      synthetic static get vBitShiftRight @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vBitShiftRight
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vBitShiftRight= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vBitShiftRight
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vBitShiftRight @-1
            type: int
        returnType: void
''');
  }

  test_initializer_cascade() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  int a;
  void m() {}
}
var vSetField = new A()..a = 1;
var vInvokeMethod = new A()..m();
var vBoth = new A()..a = 1..m();
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          a @16
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::a
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          synthetic get a @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::a
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
          synthetic set a= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::a
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _a @-1
                type: int
            returnType: void
        methods
          m @26
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: void
    topLevelVariables
      static vSetField @39
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vSetField
        enclosingElement: <thisLibrary>::<definingUnit>
        type: A
        shouldUseTypeForInitializerInference: false
      static vInvokeMethod @71
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vInvokeMethod
        enclosingElement: <thisLibrary>::<definingUnit>
        type: A
        shouldUseTypeForInitializerInference: false
      static vBoth @105
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vBoth
        enclosingElement: <thisLibrary>::<definingUnit>
        type: A
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vSetField @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vSetField
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: A
      synthetic static set vSetField= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vSetField
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vSetField @-1
            type: A
        returnType: void
      synthetic static get vInvokeMethod @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vInvokeMethod
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: A
      synthetic static set vInvokeMethod= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vInvokeMethod
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vInvokeMethod @-1
            type: A
        returnType: void
      synthetic static get vBoth @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vBoth
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: A
      synthetic static set vBoth= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vBoth
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vBoth @-1
            type: A
        returnType: void
''');
  }

  /// A simple or qualified identifier referring to a top level function, static
  /// variable, field, getter; or a static class variable, static getter or
  /// method; or an instance method; has the inferred type of the identifier.
  ///
  test_initializer_classField_useInstanceGetter() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  int f = 1;
}
class B {
  A a;
}
class C {
  B b;
}
class X {
  A a = new A();
  B b = new B();
  C c = new C();
  var t01 = a.f;
  var t02 = b.a.f;
  var t03 = c.b.a.f;
  var t11 = new A().f;
  var t12 = new B().a.f;
  var t13 = new C().b.a.f;
  var t21 = newA().f;
  var t22 = newB().a.f;
  var t23 = newC().b.a.f;
}
A newA() => new A();
B newB() => new B();
C newC() => new C();
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          f @16
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
            shouldUseTypeForInitializerInference: true
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          synthetic get f @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
          synthetic set f= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _f @-1
                type: int
            returnType: void
      class B @31
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          a @39
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::a
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: A
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          synthetic get a @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::a
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: A
          synthetic set a= @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::a
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _a @-1
                type: A
            returnType: void
      class C @50
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          b @58
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::b
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: B
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        accessors
          synthetic get b @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@getter::b
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            returnType: B
          synthetic set b= @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@setter::b
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            parameters
              requiredPositional _b @-1
                type: B
            returnType: void
      class X @69
        reference: <thisLibrary>::<definingUnit>::@class::X
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          a @77
            reference: <thisLibrary>::<definingUnit>::@class::X::@field::a
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            type: A
            shouldUseTypeForInitializerInference: true
          b @94
            reference: <thisLibrary>::<definingUnit>::@class::X::@field::b
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            type: B
            shouldUseTypeForInitializerInference: true
          c @111
            reference: <thisLibrary>::<definingUnit>::@class::X::@field::c
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            type: C
            shouldUseTypeForInitializerInference: true
          t01 @130
            reference: <thisLibrary>::<definingUnit>::@class::X::@field::t01
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            type: int
            shouldUseTypeForInitializerInference: false
          t02 @147
            reference: <thisLibrary>::<definingUnit>::@class::X::@field::t02
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            type: int
            shouldUseTypeForInitializerInference: false
          t03 @166
            reference: <thisLibrary>::<definingUnit>::@class::X::@field::t03
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            type: int
            shouldUseTypeForInitializerInference: false
          t11 @187
            reference: <thisLibrary>::<definingUnit>::@class::X::@field::t11
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            type: int
            shouldUseTypeForInitializerInference: false
          t12 @210
            reference: <thisLibrary>::<definingUnit>::@class::X::@field::t12
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            type: int
            shouldUseTypeForInitializerInference: false
          t13 @235
            reference: <thisLibrary>::<definingUnit>::@class::X::@field::t13
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            type: int
            shouldUseTypeForInitializerInference: false
          t21 @262
            reference: <thisLibrary>::<definingUnit>::@class::X::@field::t21
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            type: int
            shouldUseTypeForInitializerInference: false
          t22 @284
            reference: <thisLibrary>::<definingUnit>::@class::X::@field::t22
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            type: int
            shouldUseTypeForInitializerInference: false
          t23 @308
            reference: <thisLibrary>::<definingUnit>::@class::X::@field::t23
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            type: int
            shouldUseTypeForInitializerInference: false
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
        accessors
          synthetic get a @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@getter::a
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            returnType: A
          synthetic set a= @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@setter::a
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            parameters
              requiredPositional _a @-1
                type: A
            returnType: void
          synthetic get b @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@getter::b
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            returnType: B
          synthetic set b= @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@setter::b
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            parameters
              requiredPositional _b @-1
                type: B
            returnType: void
          synthetic get c @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@getter::c
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            returnType: C
          synthetic set c= @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@setter::c
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            parameters
              requiredPositional _c @-1
                type: C
            returnType: void
          synthetic get t01 @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@getter::t01
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            returnType: int
          synthetic set t01= @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@setter::t01
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            parameters
              requiredPositional _t01 @-1
                type: int
            returnType: void
          synthetic get t02 @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@getter::t02
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            returnType: int
          synthetic set t02= @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@setter::t02
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            parameters
              requiredPositional _t02 @-1
                type: int
            returnType: void
          synthetic get t03 @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@getter::t03
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            returnType: int
          synthetic set t03= @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@setter::t03
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            parameters
              requiredPositional _t03 @-1
                type: int
            returnType: void
          synthetic get t11 @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@getter::t11
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            returnType: int
          synthetic set t11= @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@setter::t11
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            parameters
              requiredPositional _t11 @-1
                type: int
            returnType: void
          synthetic get t12 @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@getter::t12
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            returnType: int
          synthetic set t12= @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@setter::t12
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            parameters
              requiredPositional _t12 @-1
                type: int
            returnType: void
          synthetic get t13 @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@getter::t13
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            returnType: int
          synthetic set t13= @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@setter::t13
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            parameters
              requiredPositional _t13 @-1
                type: int
            returnType: void
          synthetic get t21 @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@getter::t21
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            returnType: int
          synthetic set t21= @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@setter::t21
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            parameters
              requiredPositional _t21 @-1
                type: int
            returnType: void
          synthetic get t22 @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@getter::t22
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            returnType: int
          synthetic set t22= @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@setter::t22
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            parameters
              requiredPositional _t22 @-1
                type: int
            returnType: void
          synthetic get t23 @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@getter::t23
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            returnType: int
          synthetic set t23= @-1
            reference: <thisLibrary>::<definingUnit>::@class::X::@setter::t23
            enclosingElement: <thisLibrary>::<definingUnit>::@class::X
            parameters
              requiredPositional _t23 @-1
                type: int
            returnType: void
    functions
      newA @332
        reference: <thisLibrary>::<definingUnit>::@function::newA
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: A
      newB @353
        reference: <thisLibrary>::<definingUnit>::@function::newB
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: B
      newC @374
        reference: <thisLibrary>::<definingUnit>::@function::newC
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: C
''');
  }

  test_initializer_conditional() async {
    var library = await _encodeDecodeLibrary(r'''
var V = true ? 1 : 2.3;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static V @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::V
        enclosingElement: <thisLibrary>::<definingUnit>
        type: num
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get V @-1
        reference: <thisLibrary>::<definingUnit>::@getter::V
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: num
      synthetic static set V= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::V
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _V @-1
            type: num
        returnType: void
''');
  }

  test_initializer_equality() async {
    var library = await _encodeDecodeLibrary(r'''
var vEq = 1 == 2;
var vNotEq = 1 != 2;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static vEq @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vEq
        enclosingElement: <thisLibrary>::<definingUnit>
        type: bool
        shouldUseTypeForInitializerInference: false
      static vNotEq @22
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vNotEq
        enclosingElement: <thisLibrary>::<definingUnit>
        type: bool
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vEq @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vEq
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: bool
      synthetic static set vEq= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vEq
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vEq @-1
            type: bool
        returnType: void
      synthetic static get vNotEq @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vNotEq
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: bool
      synthetic static set vNotEq= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vNotEq
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vNotEq @-1
            type: bool
        returnType: void
''');
  }

  test_initializer_error_methodInvocation_cycle_topLevel() async {
    var library = await _encodeDecodeLibrary(r'''
var a = b.foo();
var b = a.foo();
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static a @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::a
        enclosingElement: <thisLibrary>::<definingUnit>
        typeInferenceError: dependencyCycle
          arguments: [a, b]
        type: dynamic
        shouldUseTypeForInitializerInference: false
      static b @21
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::b
        enclosingElement: <thisLibrary>::<definingUnit>
        typeInferenceError: dependencyCycle
          arguments: [a, b]
        type: dynamic
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get a @-1
        reference: <thisLibrary>::<definingUnit>::@getter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: dynamic
      synthetic static set a= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _a @-1
            type: dynamic
        returnType: void
      synthetic static get b @-1
        reference: <thisLibrary>::<definingUnit>::@getter::b
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: dynamic
      synthetic static set b= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::b
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _b @-1
            type: dynamic
        returnType: void
''');
  }

  test_initializer_error_methodInvocation_cycle_topLevel_self() async {
    var library = await _encodeDecodeLibrary(r'''
var a = a.foo();
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static a @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::a
        enclosingElement: <thisLibrary>::<definingUnit>
        typeInferenceError: dependencyCycle
          arguments: [a]
        type: dynamic
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get a @-1
        reference: <thisLibrary>::<definingUnit>::@getter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: dynamic
      synthetic static set a= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _a @-1
            type: dynamic
        returnType: void
''');
  }

  test_initializer_extractIndex() async {
    var library = await _encodeDecodeLibrary(r'''
var a = [0, 1.2];
var b0 = a[0];
var b1 = a[1];
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static a @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::a
        enclosingElement: <thisLibrary>::<definingUnit>
        type: List<num>
        shouldUseTypeForInitializerInference: false
      static b0 @22
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::b0
        enclosingElement: <thisLibrary>::<definingUnit>
        type: num
        shouldUseTypeForInitializerInference: false
      static b1 @37
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::b1
        enclosingElement: <thisLibrary>::<definingUnit>
        type: num
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get a @-1
        reference: <thisLibrary>::<definingUnit>::@getter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: List<num>
      synthetic static set a= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _a @-1
            type: List<num>
        returnType: void
      synthetic static get b0 @-1
        reference: <thisLibrary>::<definingUnit>::@getter::b0
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: num
      synthetic static set b0= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::b0
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _b0 @-1
            type: num
        returnType: void
      synthetic static get b1 @-1
        reference: <thisLibrary>::<definingUnit>::@getter::b1
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: num
      synthetic static set b1= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::b1
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _b1 @-1
            type: num
        returnType: void
''');
  }

  test_initializer_extractProperty_explicitlyTyped_differentLibraryCycle() async {
    newFile('$testPackageLibPath/a.dart', r'''
class C {
  int f = 0;
}
''');
    var library = await _encodeDecodeLibrary(r'''
import 'a.dart';
var x = new C().f;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  libraryImports
    package:test/a.dart
      enclosingElement: <thisLibrary>
      enclosingElement3: <thisLibrary>::<definingUnit>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    libraryImports
      package:test/a.dart
        enclosingElement: <thisLibrary>
        enclosingElement3: <thisLibrary>::<definingUnit>
    topLevelVariables
      static x @21
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::x
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get x @-1
        reference: <thisLibrary>::<definingUnit>::@getter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set x= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _x @-1
            type: int
        returnType: void
''');
  }

  test_initializer_extractProperty_explicitlyTyped_sameLibrary() async {
    var library = await _encodeDecodeLibrary(r'''
class C {
  int f = 0;
}
var x = new C().f;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class C @6
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          f @16
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: int
            shouldUseTypeForInitializerInference: true
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        accessors
          synthetic get f @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@getter::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            returnType: int
          synthetic set f= @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@setter::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            parameters
              requiredPositional _f @-1
                type: int
            returnType: void
    topLevelVariables
      static x @29
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::x
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get x @-1
        reference: <thisLibrary>::<definingUnit>::@getter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set x= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _x @-1
            type: int
        returnType: void
''');
  }

  test_initializer_extractProperty_explicitlyTyped_sameLibraryCycle() async {
    newFile('$testPackageLibPath/a.dart', r'''
import 'test.dart'; // just do make it part of the library cycle
class C {
  int f = 0;
}
''');
    var library = await _encodeDecodeLibrary(r'''
import 'a.dart';
var x = new C().f;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  libraryImports
    package:test/a.dart
      enclosingElement: <thisLibrary>
      enclosingElement3: <thisLibrary>::<definingUnit>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    libraryImports
      package:test/a.dart
        enclosingElement: <thisLibrary>
        enclosingElement3: <thisLibrary>::<definingUnit>
    topLevelVariables
      static x @21
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::x
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get x @-1
        reference: <thisLibrary>::<definingUnit>::@getter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set x= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _x @-1
            type: int
        returnType: void
''');
  }

  test_initializer_extractProperty_implicitlyTyped_differentLibraryCycle() async {
    newFile('$testPackageLibPath/a.dart', r'''
class C {
  var f = 0;
}
''');
    var library = await _encodeDecodeLibrary(r'''
import 'a.dart';
var x = new C().f;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  libraryImports
    package:test/a.dart
      enclosingElement: <thisLibrary>
      enclosingElement3: <thisLibrary>::<definingUnit>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    libraryImports
      package:test/a.dart
        enclosingElement: <thisLibrary>
        enclosingElement3: <thisLibrary>::<definingUnit>
    topLevelVariables
      static x @21
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::x
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get x @-1
        reference: <thisLibrary>::<definingUnit>::@getter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set x= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _x @-1
            type: int
        returnType: void
''');
  }

  test_initializer_extractProperty_implicitlyTyped_sameLibrary() async {
    var library = await _encodeDecodeLibrary(r'''
class C {
  var f = 0;
}
var x = new C().f;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class C @6
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          f @16
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: int
            shouldUseTypeForInitializerInference: false
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        accessors
          synthetic get f @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@getter::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            returnType: int
          synthetic set f= @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@setter::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            parameters
              requiredPositional _f @-1
                type: int
            returnType: void
    topLevelVariables
      static x @29
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::x
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get x @-1
        reference: <thisLibrary>::<definingUnit>::@getter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set x= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _x @-1
            type: int
        returnType: void
''');
  }

  test_initializer_extractProperty_implicitlyTyped_sameLibraryCycle() async {
    newFile('$testPackageLibPath/a.dart', r'''
import 'test.dart'; // just do make it part of the library cycle
class C {
  var f = 0;
}
''');
    var library = await _encodeDecodeLibrary(r'''
import 'a.dart';
var x = new C().f;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  libraryImports
    package:test/a.dart
      enclosingElement: <thisLibrary>
      enclosingElement3: <thisLibrary>::<definingUnit>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    libraryImports
      package:test/a.dart
        enclosingElement: <thisLibrary>
        enclosingElement3: <thisLibrary>::<definingUnit>
    topLevelVariables
      static x @21
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::x
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get x @-1
        reference: <thisLibrary>::<definingUnit>::@getter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set x= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _x @-1
            type: int
        returnType: void
''');
  }

  test_initializer_extractProperty_inStaticField() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  int f;
}
class B {
  static var t = new A().f;
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          f @16
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          synthetic get f @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
          synthetic set f= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _f @-1
                type: int
            returnType: void
      class B @27
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          static t @44
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::t
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: int
            shouldUseTypeForInitializerInference: false
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          synthetic static get t @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::t
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: int
          synthetic static set t= @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::t
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _t @-1
                type: int
            returnType: void
''');
  }

  test_initializer_extractProperty_prefixedIdentifier() async {
    var library = await _encodeDecodeLibrary(r'''
class C {
  bool b;
}
C c;
var x = c.b;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class C @6
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          b @17
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::b
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: bool
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        accessors
          synthetic get b @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@getter::b
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            returnType: bool
          synthetic set b= @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@setter::b
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            parameters
              requiredPositional _b @-1
                type: bool
            returnType: void
    topLevelVariables
      static c @24
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::c
        enclosingElement: <thisLibrary>::<definingUnit>
        type: C
      static x @31
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::x
        enclosingElement: <thisLibrary>::<definingUnit>
        type: bool
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get c @-1
        reference: <thisLibrary>::<definingUnit>::@getter::c
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: C
      synthetic static set c= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::c
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _c @-1
            type: C
        returnType: void
      synthetic static get x @-1
        reference: <thisLibrary>::<definingUnit>::@getter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: bool
      synthetic static set x= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _x @-1
            type: bool
        returnType: void
''');
  }

  test_initializer_extractProperty_prefixedIdentifier_viaInterface() async {
    var library = await _encodeDecodeLibrary(r'''
class I {
  bool b;
}
abstract class C implements I {}
C c;
var x = c.b;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class I @6
        reference: <thisLibrary>::<definingUnit>::@class::I
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          b @17
            reference: <thisLibrary>::<definingUnit>::@class::I::@field::b
            enclosingElement: <thisLibrary>::<definingUnit>::@class::I
            type: bool
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::I::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::I
        accessors
          synthetic get b @-1
            reference: <thisLibrary>::<definingUnit>::@class::I::@getter::b
            enclosingElement: <thisLibrary>::<definingUnit>::@class::I
            returnType: bool
          synthetic set b= @-1
            reference: <thisLibrary>::<definingUnit>::@class::I::@setter::b
            enclosingElement: <thisLibrary>::<definingUnit>::@class::I
            parameters
              requiredPositional _b @-1
                type: bool
            returnType: void
      abstract class C @37
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          I
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
    topLevelVariables
      static c @57
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::c
        enclosingElement: <thisLibrary>::<definingUnit>
        type: C
      static x @64
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::x
        enclosingElement: <thisLibrary>::<definingUnit>
        type: bool
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get c @-1
        reference: <thisLibrary>::<definingUnit>::@getter::c
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: C
      synthetic static set c= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::c
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _c @-1
            type: C
        returnType: void
      synthetic static get x @-1
        reference: <thisLibrary>::<definingUnit>::@getter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: bool
      synthetic static set x= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _x @-1
            type: bool
        returnType: void
''');
  }

  test_initializer_extractProperty_viaInterface() async {
    var library = await _encodeDecodeLibrary(r'''
class I {
  bool b;
}
abstract class C implements I {}
C f() => null;
var x = f().b;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class I @6
        reference: <thisLibrary>::<definingUnit>::@class::I
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          b @17
            reference: <thisLibrary>::<definingUnit>::@class::I::@field::b
            enclosingElement: <thisLibrary>::<definingUnit>::@class::I
            type: bool
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::I::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::I
        accessors
          synthetic get b @-1
            reference: <thisLibrary>::<definingUnit>::@class::I::@getter::b
            enclosingElement: <thisLibrary>::<definingUnit>::@class::I
            returnType: bool
          synthetic set b= @-1
            reference: <thisLibrary>::<definingUnit>::@class::I::@setter::b
            enclosingElement: <thisLibrary>::<definingUnit>::@class::I
            parameters
              requiredPositional _b @-1
                type: bool
            returnType: void
      abstract class C @37
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          I
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
    topLevelVariables
      static x @74
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::x
        enclosingElement: <thisLibrary>::<definingUnit>
        type: bool
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get x @-1
        reference: <thisLibrary>::<definingUnit>::@getter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: bool
      synthetic static set x= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _x @-1
            type: bool
        returnType: void
    functions
      f @57
        reference: <thisLibrary>::<definingUnit>::@function::f
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: C
''');
  }

  test_initializer_fromInstanceMethod() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  int foo() => 0;
}
class B extends A {
  foo() => 1;
}
var x = A().foo();
var y = B().foo();
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          foo @16
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::foo
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
      class B @36
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            superConstructor: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
        methods
          foo @52
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::foo
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: int
    topLevelVariables
      static x @70
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::x
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static y @89
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::y
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get x @-1
        reference: <thisLibrary>::<definingUnit>::@getter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set x= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _x @-1
            type: int
        returnType: void
      synthetic static get y @-1
        reference: <thisLibrary>::<definingUnit>::@getter::y
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set y= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::y
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _y @-1
            type: int
        returnType: void
''');
  }

  test_initializer_functionExpression() async {
    var library = await _encodeDecodeLibrary(r'''
import 'dart:async';
var vFuture = new Future<int>(42);
var v_noParameters_inferredReturnType = () => 42;
var v_hasParameter_withType_inferredReturnType = (String a) => 42;
var v_hasParameter_withType_returnParameter = (String a) => a;
var v_async_returnValue = () async => 42;
var v_async_returnFuture = () async => vFuture;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  libraryImports
    dart:async
      enclosingElement: <thisLibrary>
      enclosingElement3: <thisLibrary>::<definingUnit>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    libraryImports
      dart:async
        enclosingElement: <thisLibrary>
        enclosingElement3: <thisLibrary>::<definingUnit>
    topLevelVariables
      static vFuture @25
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vFuture
        enclosingElement: <thisLibrary>::<definingUnit>
        type: Future<int>
        shouldUseTypeForInitializerInference: false
      static v_noParameters_inferredReturnType @60
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::v_noParameters_inferredReturnType
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int Function()
        shouldUseTypeForInitializerInference: false
      static v_hasParameter_withType_inferredReturnType @110
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::v_hasParameter_withType_inferredReturnType
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int Function(String)
        shouldUseTypeForInitializerInference: false
      static v_hasParameter_withType_returnParameter @177
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::v_hasParameter_withType_returnParameter
        enclosingElement: <thisLibrary>::<definingUnit>
        type: String Function(String)
        shouldUseTypeForInitializerInference: false
      static v_async_returnValue @240
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::v_async_returnValue
        enclosingElement: <thisLibrary>::<definingUnit>
        type: Future<int> Function()
        shouldUseTypeForInitializerInference: false
      static v_async_returnFuture @282
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::v_async_returnFuture
        enclosingElement: <thisLibrary>::<definingUnit>
        type: Future<int> Function()
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vFuture @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vFuture
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: Future<int>
      synthetic static set vFuture= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vFuture
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vFuture @-1
            type: Future<int>
        returnType: void
      synthetic static get v_noParameters_inferredReturnType @-1
        reference: <thisLibrary>::<definingUnit>::@getter::v_noParameters_inferredReturnType
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int Function()
      synthetic static set v_noParameters_inferredReturnType= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::v_noParameters_inferredReturnType
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _v_noParameters_inferredReturnType @-1
            type: int Function()
        returnType: void
      synthetic static get v_hasParameter_withType_inferredReturnType @-1
        reference: <thisLibrary>::<definingUnit>::@getter::v_hasParameter_withType_inferredReturnType
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int Function(String)
      synthetic static set v_hasParameter_withType_inferredReturnType= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::v_hasParameter_withType_inferredReturnType
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _v_hasParameter_withType_inferredReturnType @-1
            type: int Function(String)
        returnType: void
      synthetic static get v_hasParameter_withType_returnParameter @-1
        reference: <thisLibrary>::<definingUnit>::@getter::v_hasParameter_withType_returnParameter
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: String Function(String)
      synthetic static set v_hasParameter_withType_returnParameter= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::v_hasParameter_withType_returnParameter
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _v_hasParameter_withType_returnParameter @-1
            type: String Function(String)
        returnType: void
      synthetic static get v_async_returnValue @-1
        reference: <thisLibrary>::<definingUnit>::@getter::v_async_returnValue
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: Future<int> Function()
      synthetic static set v_async_returnValue= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::v_async_returnValue
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _v_async_returnValue @-1
            type: Future<int> Function()
        returnType: void
      synthetic static get v_async_returnFuture @-1
        reference: <thisLibrary>::<definingUnit>::@getter::v_async_returnFuture
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: Future<int> Function()
      synthetic static set v_async_returnFuture= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::v_async_returnFuture
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _v_async_returnFuture @-1
            type: Future<int> Function()
        returnType: void
''');
  }

  test_initializer_functionExpressionInvocation_noTypeParameters() async {
    var library = await _encodeDecodeLibrary(r'''
var v = (() => 42)();
''');
    // TODO(scheglov): add more function expression tests
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static v @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::v
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get v @-1
        reference: <thisLibrary>::<definingUnit>::@getter::v
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set v= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::v
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _v @-1
            type: int
        returnType: void
''');
  }

  test_initializer_functionInvocation_hasTypeParameters() async {
    var library = await _encodeDecodeLibrary(r'''
T f<T>() => null;
var vHasTypeArgument = f<int>();
var vNoTypeArgument = f();
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static vHasTypeArgument @22
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vHasTypeArgument
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vNoTypeArgument @55
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vNoTypeArgument
        enclosingElement: <thisLibrary>::<definingUnit>
        type: dynamic
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vHasTypeArgument @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vHasTypeArgument
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vHasTypeArgument= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vHasTypeArgument
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vHasTypeArgument @-1
            type: int
        returnType: void
      synthetic static get vNoTypeArgument @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vNoTypeArgument
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: dynamic
      synthetic static set vNoTypeArgument= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vNoTypeArgument
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vNoTypeArgument @-1
            type: dynamic
        returnType: void
    functions
      f @2
        reference: <thisLibrary>::<definingUnit>::@function::f
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant T @4
            defaultType: dynamic
        returnType: T
''');
  }

  test_initializer_functionInvocation_noTypeParameters() async {
    var library = await _encodeDecodeLibrary(r'''
String f(int p) => null;
var vOkArgumentType = f(1);
var vWrongArgumentType = f(2.0);
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static vOkArgumentType @29
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vOkArgumentType
        enclosingElement: <thisLibrary>::<definingUnit>
        type: String
        shouldUseTypeForInitializerInference: false
      static vWrongArgumentType @57
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vWrongArgumentType
        enclosingElement: <thisLibrary>::<definingUnit>
        type: String
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vOkArgumentType @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vOkArgumentType
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: String
      synthetic static set vOkArgumentType= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vOkArgumentType
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vOkArgumentType @-1
            type: String
        returnType: void
      synthetic static get vWrongArgumentType @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vWrongArgumentType
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: String
      synthetic static set vWrongArgumentType= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vWrongArgumentType
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vWrongArgumentType @-1
            type: String
        returnType: void
    functions
      f @7
        reference: <thisLibrary>::<definingUnit>::@function::f
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional p @13
            type: int
        returnType: String
''');
  }

  test_initializer_identifier() async {
    var library = await _encodeDecodeLibrary(r'''
String topLevelFunction(int p) => null;
var topLevelVariable = 0;
int get topLevelGetter => 0;
class A {
  static var staticClassVariable = 0;
  static int get staticGetter => 0;
  static String staticClassMethod(int p) => null;
  String instanceClassMethod(int p) => null;
}
var r_topLevelFunction = topLevelFunction;
var r_topLevelVariable = topLevelVariable;
var r_topLevelGetter = topLevelGetter;
var r_staticClassVariable = A.staticClassVariable;
var r_staticGetter = A.staticGetter;
var r_staticClassMethod = A.staticClassMethod;
var instanceOfA = new A();
var r_instanceClassMethod = instanceOfA.instanceClassMethod;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @101
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          static staticClassVariable @118
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::staticClassVariable
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
            shouldUseTypeForInitializerInference: false
          synthetic static staticGetter @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::staticGetter
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          synthetic static get staticClassVariable @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::staticClassVariable
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
          synthetic static set staticClassVariable= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::staticClassVariable
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _staticClassVariable @-1
                type: int
            returnType: void
          static get staticGetter @160
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::staticGetter
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
        methods
          static staticClassMethod @195
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::staticClassMethod
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional p @217
                type: int
            returnType: String
          instanceClassMethod @238
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::instanceClassMethod
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional p @262
                type: int
            returnType: String
    topLevelVariables
      static topLevelVariable @44
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::topLevelVariable
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static r_topLevelFunction @280
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::r_topLevelFunction
        enclosingElement: <thisLibrary>::<definingUnit>
        type: String Function(int)
        shouldUseTypeForInitializerInference: false
      static r_topLevelVariable @323
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::r_topLevelVariable
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static r_topLevelGetter @366
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::r_topLevelGetter
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static r_staticClassVariable @405
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::r_staticClassVariable
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static r_staticGetter @456
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::r_staticGetter
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static r_staticClassMethod @493
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::r_staticClassMethod
        enclosingElement: <thisLibrary>::<definingUnit>
        type: String Function(int)
        shouldUseTypeForInitializerInference: false
      static instanceOfA @540
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::instanceOfA
        enclosingElement: <thisLibrary>::<definingUnit>
        type: A
        shouldUseTypeForInitializerInference: false
      static r_instanceClassMethod @567
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::r_instanceClassMethod
        enclosingElement: <thisLibrary>::<definingUnit>
        type: String Function(int)
        shouldUseTypeForInitializerInference: false
      synthetic static topLevelGetter @-1
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::topLevelGetter
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
    accessors
      synthetic static get topLevelVariable @-1
        reference: <thisLibrary>::<definingUnit>::@getter::topLevelVariable
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set topLevelVariable= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::topLevelVariable
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _topLevelVariable @-1
            type: int
        returnType: void
      synthetic static get r_topLevelFunction @-1
        reference: <thisLibrary>::<definingUnit>::@getter::r_topLevelFunction
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: String Function(int)
      synthetic static set r_topLevelFunction= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::r_topLevelFunction
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _r_topLevelFunction @-1
            type: String Function(int)
        returnType: void
      synthetic static get r_topLevelVariable @-1
        reference: <thisLibrary>::<definingUnit>::@getter::r_topLevelVariable
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set r_topLevelVariable= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::r_topLevelVariable
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _r_topLevelVariable @-1
            type: int
        returnType: void
      synthetic static get r_topLevelGetter @-1
        reference: <thisLibrary>::<definingUnit>::@getter::r_topLevelGetter
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set r_topLevelGetter= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::r_topLevelGetter
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _r_topLevelGetter @-1
            type: int
        returnType: void
      synthetic static get r_staticClassVariable @-1
        reference: <thisLibrary>::<definingUnit>::@getter::r_staticClassVariable
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set r_staticClassVariable= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::r_staticClassVariable
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _r_staticClassVariable @-1
            type: int
        returnType: void
      synthetic static get r_staticGetter @-1
        reference: <thisLibrary>::<definingUnit>::@getter::r_staticGetter
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set r_staticGetter= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::r_staticGetter
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _r_staticGetter @-1
            type: int
        returnType: void
      synthetic static get r_staticClassMethod @-1
        reference: <thisLibrary>::<definingUnit>::@getter::r_staticClassMethod
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: String Function(int)
      synthetic static set r_staticClassMethod= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::r_staticClassMethod
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _r_staticClassMethod @-1
            type: String Function(int)
        returnType: void
      synthetic static get instanceOfA @-1
        reference: <thisLibrary>::<definingUnit>::@getter::instanceOfA
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: A
      synthetic static set instanceOfA= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::instanceOfA
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _instanceOfA @-1
            type: A
        returnType: void
      synthetic static get r_instanceClassMethod @-1
        reference: <thisLibrary>::<definingUnit>::@getter::r_instanceClassMethod
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: String Function(int)
      synthetic static set r_instanceClassMethod= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::r_instanceClassMethod
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _r_instanceClassMethod @-1
            type: String Function(int)
        returnType: void
      static get topLevelGetter @74
        reference: <thisLibrary>::<definingUnit>::@getter::topLevelGetter
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
    functions
      topLevelFunction @7
        reference: <thisLibrary>::<definingUnit>::@function::topLevelFunction
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional p @28
            type: int
        returnType: String
''');
  }

  test_initializer_identifier_error_cycle_classField() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  static var a = B.b;
}
class B {
  static var b = A.a;
}
var c = A.a;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          static a @23
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::a
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            typeInferenceError: dependencyCycle
              arguments: [a, b]
            type: dynamic
            shouldUseTypeForInitializerInference: false
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          synthetic static get a @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::a
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: dynamic
          synthetic static set a= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::a
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _a @-1
                type: dynamic
            returnType: void
      class B @40
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          static b @57
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::b
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            typeInferenceError: dependencyCycle
              arguments: [a, b]
            type: dynamic
            shouldUseTypeForInitializerInference: false
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          synthetic static get b @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::b
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: dynamic
          synthetic static set b= @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::b
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _b @-1
                type: dynamic
            returnType: void
    topLevelVariables
      static c @72
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::c
        enclosingElement: <thisLibrary>::<definingUnit>
        type: dynamic
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get c @-1
        reference: <thisLibrary>::<definingUnit>::@getter::c
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: dynamic
      synthetic static set c= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::c
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _c @-1
            type: dynamic
        returnType: void
''');
  }

  test_initializer_identifier_error_cycle_mix() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  static var a = b;
}
var b = A.a;
var c = b;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          static a @23
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::a
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            typeInferenceError: dependencyCycle
              arguments: [a, b]
            type: dynamic
            shouldUseTypeForInitializerInference: false
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          synthetic static get a @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::a
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: dynamic
          synthetic static set a= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::a
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _a @-1
                type: dynamic
            returnType: void
    topLevelVariables
      static b @36
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::b
        enclosingElement: <thisLibrary>::<definingUnit>
        typeInferenceError: dependencyCycle
          arguments: [a, b]
        type: dynamic
        shouldUseTypeForInitializerInference: false
      static c @49
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::c
        enclosingElement: <thisLibrary>::<definingUnit>
        type: dynamic
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get b @-1
        reference: <thisLibrary>::<definingUnit>::@getter::b
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: dynamic
      synthetic static set b= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::b
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _b @-1
            type: dynamic
        returnType: void
      synthetic static get c @-1
        reference: <thisLibrary>::<definingUnit>::@getter::c
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: dynamic
      synthetic static set c= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::c
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _c @-1
            type: dynamic
        returnType: void
''');
  }

  test_initializer_identifier_error_cycle_topLevel() async {
    var library = await _encodeDecodeLibrary(r'''
final a = b;
final b = c;
final c = a;
final d = a;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static final a @6
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::a
        enclosingElement: <thisLibrary>::<definingUnit>
        typeInferenceError: dependencyCycle
          arguments: [a, b, c]
        type: dynamic
        shouldUseTypeForInitializerInference: false
      static final b @19
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::b
        enclosingElement: <thisLibrary>::<definingUnit>
        typeInferenceError: dependencyCycle
          arguments: [a, b, c]
        type: dynamic
        shouldUseTypeForInitializerInference: false
      static final c @32
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::c
        enclosingElement: <thisLibrary>::<definingUnit>
        typeInferenceError: dependencyCycle
          arguments: [a, b, c]
        type: dynamic
        shouldUseTypeForInitializerInference: false
      static final d @45
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::d
        enclosingElement: <thisLibrary>::<definingUnit>
        type: dynamic
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get a @-1
        reference: <thisLibrary>::<definingUnit>::@getter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: dynamic
      synthetic static get b @-1
        reference: <thisLibrary>::<definingUnit>::@getter::b
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: dynamic
      synthetic static get c @-1
        reference: <thisLibrary>::<definingUnit>::@getter::c
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: dynamic
      synthetic static get d @-1
        reference: <thisLibrary>::<definingUnit>::@getter::d
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: dynamic
''');
  }

  test_initializer_identifier_formalParameter() async {
    // TODO(scheglov): I don't understand this yet
  }

  @skippedTest
  test_initializer_instanceCreation_hasTypeParameter() async {
    var library = await _encodeDecodeLibrary(r'''
class A<T> {}
var a = new A<int>();
var b = new A();
''');
    // TODO(scheglov): test for inference failure error
    checkElementText(library, r'''
class A<T> {
}
A<int> a;
dynamic b;
''');
  }

  test_initializer_instanceCreation_noTypeParameters() async {
    var library = await _encodeDecodeLibrary(r'''
class A {}
var a = new A();
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
    topLevelVariables
      static a @15
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::a
        enclosingElement: <thisLibrary>::<definingUnit>
        type: A
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get a @-1
        reference: <thisLibrary>::<definingUnit>::@getter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: A
      synthetic static set a= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _a @-1
            type: A
        returnType: void
''');
  }

  test_initializer_instanceGetterOfObject() async {
    var library = await _encodeDecodeLibrary(r'''
dynamic f() => null;
var s = f().toString();
var h = f().hashCode;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static s @25
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::s
        enclosingElement: <thisLibrary>::<definingUnit>
        type: String
        shouldUseTypeForInitializerInference: false
      static h @49
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::h
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get s @-1
        reference: <thisLibrary>::<definingUnit>::@getter::s
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: String
      synthetic static set s= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::s
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _s @-1
            type: String
        returnType: void
      synthetic static get h @-1
        reference: <thisLibrary>::<definingUnit>::@getter::h
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set h= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::h
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _h @-1
            type: int
        returnType: void
    functions
      f @8
        reference: <thisLibrary>::<definingUnit>::@function::f
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: dynamic
''');
  }

  test_initializer_instanceGetterOfObject_prefixed() async {
    var library = await _encodeDecodeLibrary(r'''
dynamic d;
var s = d.toString();
var h = d.hashCode;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static d @8
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::d
        enclosingElement: <thisLibrary>::<definingUnit>
        type: dynamic
      static s @15
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::s
        enclosingElement: <thisLibrary>::<definingUnit>
        type: String
        shouldUseTypeForInitializerInference: false
      static h @37
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::h
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get d @-1
        reference: <thisLibrary>::<definingUnit>::@getter::d
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: dynamic
      synthetic static set d= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::d
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _d @-1
            type: dynamic
        returnType: void
      synthetic static get s @-1
        reference: <thisLibrary>::<definingUnit>::@getter::s
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: String
      synthetic static set s= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::s
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _s @-1
            type: String
        returnType: void
      synthetic static get h @-1
        reference: <thisLibrary>::<definingUnit>::@getter::h
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set h= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::h
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _h @-1
            type: int
        returnType: void
''');
  }

  test_initializer_is() async {
    var library = await _encodeDecodeLibrary(r'''
var a = 1.2;
var b = a is int;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static a @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::a
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static b @17
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::b
        enclosingElement: <thisLibrary>::<definingUnit>
        type: bool
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get a @-1
        reference: <thisLibrary>::<definingUnit>::@getter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set a= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _a @-1
            type: double
        returnType: void
      synthetic static get b @-1
        reference: <thisLibrary>::<definingUnit>::@getter::b
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: bool
      synthetic static set b= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::b
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _b @-1
            type: bool
        returnType: void
''');
  }

  @skippedTest
  test_initializer_literal() async {
    var library = await _encodeDecodeLibrary(r'''
var vNull = null;
var vBoolFalse = false;
var vBoolTrue = true;
var vInt = 1;
var vIntLong = 0x9876543210987654321;
var vDouble = 2.3;
var vString = 'abc';
var vStringConcat = 'aaa' 'bbb';
var vStringInterpolation = 'aaa ${true} ${42} bbb';
var vSymbol = #aaa.bbb.ccc;
''');
    checkElementText(library, r'''
Null vNull;
bool vBoolFalse;
bool vBoolTrue;
int vInt;
int vIntLong;
double vDouble;
String vString;
String vStringConcat;
String vStringInterpolation;
Symbol vSymbol;
''');
  }

  test_initializer_literal_list_typed() async {
    var library = await _encodeDecodeLibrary(r'''
var vObject = <Object>[1, 2, 3];
var vNum = <num>[1, 2, 3];
var vNumEmpty = <num>[];
var vInt = <int>[1, 2, 3];
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static vObject @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vObject
        enclosingElement: <thisLibrary>::<definingUnit>
        type: List<Object>
        shouldUseTypeForInitializerInference: false
      static vNum @37
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vNum
        enclosingElement: <thisLibrary>::<definingUnit>
        type: List<num>
        shouldUseTypeForInitializerInference: false
      static vNumEmpty @64
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vNumEmpty
        enclosingElement: <thisLibrary>::<definingUnit>
        type: List<num>
        shouldUseTypeForInitializerInference: false
      static vInt @89
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: List<int>
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vObject @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vObject
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: List<Object>
      synthetic static set vObject= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vObject
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vObject @-1
            type: List<Object>
        returnType: void
      synthetic static get vNum @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vNum
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: List<num>
      synthetic static set vNum= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vNum
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vNum @-1
            type: List<num>
        returnType: void
      synthetic static get vNumEmpty @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vNumEmpty
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: List<num>
      synthetic static set vNumEmpty= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vNumEmpty
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vNumEmpty @-1
            type: List<num>
        returnType: void
      synthetic static get vInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: List<int>
      synthetic static set vInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vInt @-1
            type: List<int>
        returnType: void
''');
  }

  test_initializer_literal_list_untyped() async {
    var library = await _encodeDecodeLibrary(r'''
var vInt = [1, 2, 3];
var vNum = [1, 2.0];
var vObject = [1, 2.0, '333'];
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static vInt @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: List<int>
        shouldUseTypeForInitializerInference: false
      static vNum @26
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vNum
        enclosingElement: <thisLibrary>::<definingUnit>
        type: List<num>
        shouldUseTypeForInitializerInference: false
      static vObject @47
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vObject
        enclosingElement: <thisLibrary>::<definingUnit>
        type: List<Object>
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: List<int>
      synthetic static set vInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vInt @-1
            type: List<int>
        returnType: void
      synthetic static get vNum @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vNum
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: List<num>
      synthetic static set vNum= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vNum
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vNum @-1
            type: List<num>
        returnType: void
      synthetic static get vObject @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vObject
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: List<Object>
      synthetic static set vObject= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vObject
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vObject @-1
            type: List<Object>
        returnType: void
''');
  }

  @skippedTest
  test_initializer_literal_list_untyped_empty() async {
    var library = await _encodeDecodeLibrary(r'''
var vNonConst = [];
var vConst = const [];
''');
    checkElementText(library, r'''
List<dynamic> vNonConst;
List<Null> vConst;
''');
  }

  test_initializer_literal_map_typed() async {
    var library = await _encodeDecodeLibrary(r'''
var vObjectObject = <Object, Object>{1: 'a'};
var vComparableObject = <Comparable<int>, Object>{1: 'a'};
var vNumString = <num, String>{1: 'a'};
var vNumStringEmpty = <num, String>{};
var vIntString = <int, String>{};
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static vObjectObject @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vObjectObject
        enclosingElement: <thisLibrary>::<definingUnit>
        type: Map<Object, Object>
        shouldUseTypeForInitializerInference: false
      static vComparableObject @50
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vComparableObject
        enclosingElement: <thisLibrary>::<definingUnit>
        type: Map<Comparable<int>, Object>
        shouldUseTypeForInitializerInference: false
      static vNumString @109
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vNumString
        enclosingElement: <thisLibrary>::<definingUnit>
        type: Map<num, String>
        shouldUseTypeForInitializerInference: false
      static vNumStringEmpty @149
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vNumStringEmpty
        enclosingElement: <thisLibrary>::<definingUnit>
        type: Map<num, String>
        shouldUseTypeForInitializerInference: false
      static vIntString @188
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vIntString
        enclosingElement: <thisLibrary>::<definingUnit>
        type: Map<int, String>
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vObjectObject @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vObjectObject
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: Map<Object, Object>
      synthetic static set vObjectObject= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vObjectObject
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vObjectObject @-1
            type: Map<Object, Object>
        returnType: void
      synthetic static get vComparableObject @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vComparableObject
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: Map<Comparable<int>, Object>
      synthetic static set vComparableObject= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vComparableObject
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vComparableObject @-1
            type: Map<Comparable<int>, Object>
        returnType: void
      synthetic static get vNumString @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vNumString
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: Map<num, String>
      synthetic static set vNumString= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vNumString
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vNumString @-1
            type: Map<num, String>
        returnType: void
      synthetic static get vNumStringEmpty @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vNumStringEmpty
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: Map<num, String>
      synthetic static set vNumStringEmpty= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vNumStringEmpty
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vNumStringEmpty @-1
            type: Map<num, String>
        returnType: void
      synthetic static get vIntString @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vIntString
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: Map<int, String>
      synthetic static set vIntString= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vIntString
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vIntString @-1
            type: Map<int, String>
        returnType: void
''');
  }

  test_initializer_literal_map_untyped() async {
    var library = await _encodeDecodeLibrary(r'''
var vIntString = {1: 'a', 2: 'b'};
var vNumString = {1: 'a', 2.0: 'b'};
var vIntObject = {1: 'a', 2: 3.0};
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static vIntString @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vIntString
        enclosingElement: <thisLibrary>::<definingUnit>
        type: Map<int, String>
        shouldUseTypeForInitializerInference: false
      static vNumString @39
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vNumString
        enclosingElement: <thisLibrary>::<definingUnit>
        type: Map<num, String>
        shouldUseTypeForInitializerInference: false
      static vIntObject @76
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vIntObject
        enclosingElement: <thisLibrary>::<definingUnit>
        type: Map<int, Object>
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vIntString @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vIntString
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: Map<int, String>
      synthetic static set vIntString= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vIntString
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vIntString @-1
            type: Map<int, String>
        returnType: void
      synthetic static get vNumString @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vNumString
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: Map<num, String>
      synthetic static set vNumString= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vNumString
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vNumString @-1
            type: Map<num, String>
        returnType: void
      synthetic static get vIntObject @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vIntObject
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: Map<int, Object>
      synthetic static set vIntObject= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vIntObject
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vIntObject @-1
            type: Map<int, Object>
        returnType: void
''');
  }

  @skippedTest
  test_initializer_literal_map_untyped_empty() async {
    var library = await _encodeDecodeLibrary(r'''
var vNonConst = {};
var vConst = const {};
''');
    checkElementText(library, r'''
Map<dynamic, dynamic> vNonConst;
Map<Null, Null> vConst;
''');
  }

  test_initializer_logicalBool() async {
    var library = await _encodeDecodeLibrary(r'''
var a = true;
var b = true;
var vEq = 1 == 2;
var vAnd = a && b;
var vOr = a || b;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static a @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::a
        enclosingElement: <thisLibrary>::<definingUnit>
        type: bool
        shouldUseTypeForInitializerInference: false
      static b @18
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::b
        enclosingElement: <thisLibrary>::<definingUnit>
        type: bool
        shouldUseTypeForInitializerInference: false
      static vEq @32
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vEq
        enclosingElement: <thisLibrary>::<definingUnit>
        type: bool
        shouldUseTypeForInitializerInference: false
      static vAnd @50
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vAnd
        enclosingElement: <thisLibrary>::<definingUnit>
        type: bool
        shouldUseTypeForInitializerInference: false
      static vOr @69
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vOr
        enclosingElement: <thisLibrary>::<definingUnit>
        type: bool
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get a @-1
        reference: <thisLibrary>::<definingUnit>::@getter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: bool
      synthetic static set a= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _a @-1
            type: bool
        returnType: void
      synthetic static get b @-1
        reference: <thisLibrary>::<definingUnit>::@getter::b
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: bool
      synthetic static set b= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::b
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _b @-1
            type: bool
        returnType: void
      synthetic static get vEq @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vEq
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: bool
      synthetic static set vEq= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vEq
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vEq @-1
            type: bool
        returnType: void
      synthetic static get vAnd @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vAnd
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: bool
      synthetic static set vAnd= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vAnd
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vAnd @-1
            type: bool
        returnType: void
      synthetic static get vOr @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vOr
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: bool
      synthetic static set vOr= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vOr
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vOr @-1
            type: bool
        returnType: void
''');
  }

  @skippedTest
  test_initializer_methodInvocation_hasTypeParameters() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  List<T> m<T>() => null;
}
var vWithTypeArgument = new A().m<int>();
var vWithoutTypeArgument = new A().m();
''');
    // TODO(scheglov): test for inference failure error
    checkElementText(library, r'''
class A {
  List<T> m<T>(int p) {}
}
List<int> vWithTypeArgument;
dynamic vWithoutTypeArgument;
''');
  }

  test_initializer_methodInvocation_noTypeParameters() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  String m(int p) => null;
}
var instanceOfA = new A();
var v1 = instanceOfA.m();
var v2 = new A().m();
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @19
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional p @25
                type: int
            returnType: String
    topLevelVariables
      static instanceOfA @43
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::instanceOfA
        enclosingElement: <thisLibrary>::<definingUnit>
        type: A
        shouldUseTypeForInitializerInference: false
      static v1 @70
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::v1
        enclosingElement: <thisLibrary>::<definingUnit>
        type: String
        shouldUseTypeForInitializerInference: false
      static v2 @96
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::v2
        enclosingElement: <thisLibrary>::<definingUnit>
        type: String
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get instanceOfA @-1
        reference: <thisLibrary>::<definingUnit>::@getter::instanceOfA
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: A
      synthetic static set instanceOfA= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::instanceOfA
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _instanceOfA @-1
            type: A
        returnType: void
      synthetic static get v1 @-1
        reference: <thisLibrary>::<definingUnit>::@getter::v1
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: String
      synthetic static set v1= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::v1
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _v1 @-1
            type: String
        returnType: void
      synthetic static get v2 @-1
        reference: <thisLibrary>::<definingUnit>::@getter::v2
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: String
      synthetic static set v2= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::v2
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _v2 @-1
            type: String
        returnType: void
''');
  }

  test_initializer_multiplicative() async {
    var library = await _encodeDecodeLibrary(r'''
var vModuloIntInt = 1 % 2;
var vModuloIntDouble = 1 % 2.0;
var vMultiplyIntInt = 1 * 2;
var vMultiplyIntDouble = 1 * 2.0;
var vMultiplyDoubleInt = 1.0 * 2;
var vMultiplyDoubleDouble = 1.0 * 2.0;
var vDivideIntInt = 1 / 2;
var vDivideIntDouble = 1 / 2.0;
var vDivideDoubleInt = 1.0 / 2;
var vDivideDoubleDouble = 1.0 / 2.0;
var vFloorDivide = 1 ~/ 2;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static vModuloIntInt @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vModuloIntInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vModuloIntDouble @31
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vModuloIntDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vMultiplyIntInt @63
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vMultiplyIntInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vMultiplyIntDouble @92
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vMultiplyIntDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vMultiplyDoubleInt @126
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vMultiplyDoubleInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vMultiplyDoubleDouble @160
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vMultiplyDoubleDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vDivideIntInt @199
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vDivideIntInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vDivideIntDouble @226
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vDivideIntDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vDivideDoubleInt @258
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vDivideDoubleInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vDivideDoubleDouble @290
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vDivideDoubleDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vFloorDivide @327
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vFloorDivide
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vModuloIntInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vModuloIntInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vModuloIntInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vModuloIntInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vModuloIntInt @-1
            type: int
        returnType: void
      synthetic static get vModuloIntDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vModuloIntDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vModuloIntDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vModuloIntDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vModuloIntDouble @-1
            type: double
        returnType: void
      synthetic static get vMultiplyIntInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vMultiplyIntInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vMultiplyIntInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vMultiplyIntInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vMultiplyIntInt @-1
            type: int
        returnType: void
      synthetic static get vMultiplyIntDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vMultiplyIntDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vMultiplyIntDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vMultiplyIntDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vMultiplyIntDouble @-1
            type: double
        returnType: void
      synthetic static get vMultiplyDoubleInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vMultiplyDoubleInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vMultiplyDoubleInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vMultiplyDoubleInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vMultiplyDoubleInt @-1
            type: double
        returnType: void
      synthetic static get vMultiplyDoubleDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vMultiplyDoubleDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vMultiplyDoubleDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vMultiplyDoubleDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vMultiplyDoubleDouble @-1
            type: double
        returnType: void
      synthetic static get vDivideIntInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vDivideIntInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vDivideIntInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vDivideIntInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vDivideIntInt @-1
            type: double
        returnType: void
      synthetic static get vDivideIntDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vDivideIntDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vDivideIntDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vDivideIntDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vDivideIntDouble @-1
            type: double
        returnType: void
      synthetic static get vDivideDoubleInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vDivideDoubleInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vDivideDoubleInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vDivideDoubleInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vDivideDoubleInt @-1
            type: double
        returnType: void
      synthetic static get vDivideDoubleDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vDivideDoubleDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vDivideDoubleDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vDivideDoubleDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vDivideDoubleDouble @-1
            type: double
        returnType: void
      synthetic static get vFloorDivide @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vFloorDivide
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vFloorDivide= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vFloorDivide
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vFloorDivide @-1
            type: int
        returnType: void
''');
  }

  test_initializer_onlyLeft() async {
    var library = await _encodeDecodeLibrary(r'''
var a = 1;
var vEq = a == ((a = 2) == 0);
var vNotEq = a != ((a = 2) == 0);
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static a @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::a
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vEq @15
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vEq
        enclosingElement: <thisLibrary>::<definingUnit>
        type: bool
        shouldUseTypeForInitializerInference: false
      static vNotEq @46
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vNotEq
        enclosingElement: <thisLibrary>::<definingUnit>
        type: bool
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get a @-1
        reference: <thisLibrary>::<definingUnit>::@getter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set a= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::a
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _a @-1
            type: int
        returnType: void
      synthetic static get vEq @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vEq
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: bool
      synthetic static set vEq= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vEq
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vEq @-1
            type: bool
        returnType: void
      synthetic static get vNotEq @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vNotEq
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: bool
      synthetic static set vNotEq= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vNotEq
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vNotEq @-1
            type: bool
        returnType: void
''');
  }

  test_initializer_parenthesized() async {
    var library = await _encodeDecodeLibrary(r'''
var V = (42);
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static V @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::V
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get V @-1
        reference: <thisLibrary>::<definingUnit>::@getter::V
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set V= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::V
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _V @-1
            type: int
        returnType: void
''');
  }

  test_initializer_postfix() async {
    var library = await _encodeDecodeLibrary(r'''
var vInt = 1;
var vDouble = 2.0;
var vIncInt = vInt++;
var vDecInt = vInt--;
var vIncDouble = vDouble++;
var vDecDouble = vDouble--;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static vInt @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vDouble @18
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vIncInt @37
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vIncInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vDecInt @59
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vDecInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vIncDouble @81
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vIncDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vDecDouble @109
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vDecDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vInt @-1
            type: int
        returnType: void
      synthetic static get vDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vDouble @-1
            type: double
        returnType: void
      synthetic static get vIncInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vIncInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vIncInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vIncInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vIncInt @-1
            type: int
        returnType: void
      synthetic static get vDecInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vDecInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vDecInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vDecInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vDecInt @-1
            type: int
        returnType: void
      synthetic static get vIncDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vIncDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vIncDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vIncDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vIncDouble @-1
            type: double
        returnType: void
      synthetic static get vDecDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vDecDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vDecDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vDecDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vDecDouble @-1
            type: double
        returnType: void
''');
  }

  test_initializer_postfix_indexed() async {
    var library = await _encodeDecodeLibrary(r'''
var vInt = [1];
var vDouble = [2.0];
var vIncInt = vInt[0]++;
var vDecInt = vInt[0]--;
var vIncDouble = vDouble[0]++;
var vDecDouble = vDouble[0]--;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static vInt @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: List<int>
        shouldUseTypeForInitializerInference: false
      static vDouble @20
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: List<double>
        shouldUseTypeForInitializerInference: false
      static vIncInt @41
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vIncInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vDecInt @66
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vDecInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vIncDouble @91
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vIncDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vDecDouble @122
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vDecDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: List<int>
      synthetic static set vInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vInt @-1
            type: List<int>
        returnType: void
      synthetic static get vDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: List<double>
      synthetic static set vDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vDouble @-1
            type: List<double>
        returnType: void
      synthetic static get vIncInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vIncInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vIncInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vIncInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vIncInt @-1
            type: int
        returnType: void
      synthetic static get vDecInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vDecInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vDecInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vDecInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vDecInt @-1
            type: int
        returnType: void
      synthetic static get vIncDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vIncDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vIncDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vIncDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vIncDouble @-1
            type: double
        returnType: void
      synthetic static get vDecDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vDecDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vDecDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vDecDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vDecDouble @-1
            type: double
        returnType: void
''');
  }

  test_initializer_prefix_incDec() async {
    var library = await _encodeDecodeLibrary(r'''
var vInt = 1;
var vDouble = 2.0;
var vIncInt = ++vInt;
var vDecInt = --vInt;
var vIncDouble = ++vDouble;
var vDecInt = --vDouble;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static vInt @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vDouble @18
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vIncInt @37
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vIncInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vDecInt @59
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vDecInt::@def::0
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vIncDouble @81
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vIncDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vDecInt @109
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vDecInt::@def::1
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vInt @-1
            type: int
        returnType: void
      synthetic static get vDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vDouble @-1
            type: double
        returnType: void
      synthetic static get vIncInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vIncInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vIncInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vIncInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vIncInt @-1
            type: int
        returnType: void
      synthetic static get vDecInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vDecInt::@def::0
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vDecInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vDecInt::@def::0
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vDecInt @-1
            type: int
        returnType: void
      synthetic static get vIncDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vIncDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vIncDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vIncDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vIncDouble @-1
            type: double
        returnType: void
      synthetic static get vDecInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vDecInt::@def::1
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vDecInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vDecInt::@def::1
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vDecInt @-1
            type: double
        returnType: void
''');
  }

  @skippedTest
  test_initializer_prefix_incDec_custom() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  B operator+(int v) => null;
}
class B {}
var a = new A();
var vInc = ++a;
var vDec = --a;
''');
    checkElementText(library, r'''
A a;
B vInc;
B vDec;
''');
  }

  test_initializer_prefix_incDec_indexed() async {
    var library = await _encodeDecodeLibrary(r'''
var vInt = [1];
var vDouble = [2.0];
var vIncInt = ++vInt[0];
var vDecInt = --vInt[0];
var vIncDouble = ++vDouble[0];
var vDecInt = --vDouble[0];
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static vInt @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: List<int>
        shouldUseTypeForInitializerInference: false
      static vDouble @20
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: List<double>
        shouldUseTypeForInitializerInference: false
      static vIncInt @41
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vIncInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vDecInt @66
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vDecInt::@def::0
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vIncDouble @91
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vIncDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vDecInt @122
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vDecInt::@def::1
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: List<int>
      synthetic static set vInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vInt @-1
            type: List<int>
        returnType: void
      synthetic static get vDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: List<double>
      synthetic static set vDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vDouble @-1
            type: List<double>
        returnType: void
      synthetic static get vIncInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vIncInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vIncInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vIncInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vIncInt @-1
            type: int
        returnType: void
      synthetic static get vDecInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vDecInt::@def::0
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vDecInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vDecInt::@def::0
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vDecInt @-1
            type: int
        returnType: void
      synthetic static get vIncDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vIncDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vIncDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vIncDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vIncDouble @-1
            type: double
        returnType: void
      synthetic static get vDecInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vDecInt::@def::1
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vDecInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vDecInt::@def::1
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vDecInt @-1
            type: double
        returnType: void
''');
  }

  test_initializer_prefix_not() async {
    var library = await _encodeDecodeLibrary(r'''
var vNot = !true;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static vNot @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vNot
        enclosingElement: <thisLibrary>::<definingUnit>
        type: bool
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vNot @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vNot
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: bool
      synthetic static set vNot= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vNot
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vNot @-1
            type: bool
        returnType: void
''');
  }

  test_initializer_prefix_other() async {
    var library = await _encodeDecodeLibrary(r'''
var vNegateInt = -1;
var vNegateDouble = -1.0;
var vComplement = ~1;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static vNegateInt @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vNegateInt
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
      static vNegateDouble @25
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vNegateDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        type: double
        shouldUseTypeForInitializerInference: false
      static vComplement @51
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vComplement
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vNegateInt @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vNegateInt
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vNegateInt= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vNegateInt
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vNegateInt @-1
            type: int
        returnType: void
      synthetic static get vNegateDouble @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vNegateDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: double
      synthetic static set vNegateDouble= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vNegateDouble
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vNegateDouble @-1
            type: double
        returnType: void
      synthetic static get vComplement @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vComplement
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set vComplement= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vComplement
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vComplement @-1
            type: int
        returnType: void
''');
  }

  test_initializer_referenceToFieldOfStaticField() async {
    var library = await _encodeDecodeLibrary(r'''
class C {
  static D d;
}
class D {
  int i;
}
final x = C.d.i;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class C @6
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          static d @21
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::d
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: D
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        accessors
          synthetic static get d @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@getter::d
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            returnType: D
          synthetic static set d= @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@setter::d
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            parameters
              requiredPositional _d @-1
                type: D
            returnType: void
      class D @32
        reference: <thisLibrary>::<definingUnit>::@class::D
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          i @42
            reference: <thisLibrary>::<definingUnit>::@class::D::@field::i
            enclosingElement: <thisLibrary>::<definingUnit>::@class::D
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::D::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::D
        accessors
          synthetic get i @-1
            reference: <thisLibrary>::<definingUnit>::@class::D::@getter::i
            enclosingElement: <thisLibrary>::<definingUnit>::@class::D
            returnType: int
          synthetic set i= @-1
            reference: <thisLibrary>::<definingUnit>::@class::D::@setter::i
            enclosingElement: <thisLibrary>::<definingUnit>::@class::D
            parameters
              requiredPositional _i @-1
                type: int
            returnType: void
    topLevelVariables
      static final x @53
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::x
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get x @-1
        reference: <thisLibrary>::<definingUnit>::@getter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
''');
  }

  test_initializer_referenceToFieldOfStaticGetter() async {
    var library = await _encodeDecodeLibrary(r'''
class C {
  static D get d => null;
}
class D {
  int i;
}
var x = C.d.i;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class C @6
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic static d @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::d
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: D
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        accessors
          static get d @25
            reference: <thisLibrary>::<definingUnit>::@class::C::@getter::d
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            returnType: D
      class D @44
        reference: <thisLibrary>::<definingUnit>::@class::D
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          i @54
            reference: <thisLibrary>::<definingUnit>::@class::D::@field::i
            enclosingElement: <thisLibrary>::<definingUnit>::@class::D
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::D::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::D
        accessors
          synthetic get i @-1
            reference: <thisLibrary>::<definingUnit>::@class::D::@getter::i
            enclosingElement: <thisLibrary>::<definingUnit>::@class::D
            returnType: int
          synthetic set i= @-1
            reference: <thisLibrary>::<definingUnit>::@class::D::@setter::i
            enclosingElement: <thisLibrary>::<definingUnit>::@class::D
            parameters
              requiredPositional _i @-1
                type: int
            returnType: void
    topLevelVariables
      static x @63
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::x
        enclosingElement: <thisLibrary>::<definingUnit>
        type: int
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get x @-1
        reference: <thisLibrary>::<definingUnit>::@getter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: int
      synthetic static set x= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::x
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _x @-1
            type: int
        returnType: void
''');
  }

  test_initializer_relational() async {
    var library = await _encodeDecodeLibrary(r'''
var vLess = 1 < 2;
var vLessOrEqual = 1 <= 2;
var vGreater = 1 > 2;
var vGreaterOrEqual = 1 >= 2;
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    topLevelVariables
      static vLess @4
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vLess
        enclosingElement: <thisLibrary>::<definingUnit>
        type: bool
        shouldUseTypeForInitializerInference: false
      static vLessOrEqual @23
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vLessOrEqual
        enclosingElement: <thisLibrary>::<definingUnit>
        type: bool
        shouldUseTypeForInitializerInference: false
      static vGreater @50
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vGreater
        enclosingElement: <thisLibrary>::<definingUnit>
        type: bool
        shouldUseTypeForInitializerInference: false
      static vGreaterOrEqual @72
        reference: <thisLibrary>::<definingUnit>::@topLevelVariable::vGreaterOrEqual
        enclosingElement: <thisLibrary>::<definingUnit>
        type: bool
        shouldUseTypeForInitializerInference: false
    accessors
      synthetic static get vLess @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vLess
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: bool
      synthetic static set vLess= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vLess
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vLess @-1
            type: bool
        returnType: void
      synthetic static get vLessOrEqual @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vLessOrEqual
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: bool
      synthetic static set vLessOrEqual= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vLessOrEqual
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vLessOrEqual @-1
            type: bool
        returnType: void
      synthetic static get vGreater @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vGreater
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: bool
      synthetic static set vGreater= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vGreater
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vGreater @-1
            type: bool
        returnType: void
      synthetic static get vGreaterOrEqual @-1
        reference: <thisLibrary>::<definingUnit>::@getter::vGreaterOrEqual
        enclosingElement: <thisLibrary>::<definingUnit>
        returnType: bool
      synthetic static set vGreaterOrEqual= @-1
        reference: <thisLibrary>::<definingUnit>::@setter::vGreaterOrEqual
        enclosingElement: <thisLibrary>::<definingUnit>
        parameters
          requiredPositional _vGreaterOrEqual @-1
            type: bool
        returnType: void
''');
  }

  @skippedTest
  test_initializer_throw() async {
    var library = await _encodeDecodeLibrary(r'''
var V = throw 42;
''');
    checkElementText(library, r'''
Null V;
''');
  }

  test_instanceField_error_noSetterParameter() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int x;
}
class B implements A {
  set x() {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          x @25
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          synthetic get x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
          synthetic set x= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _x @-1
                type: int
            returnType: void
      class B @36
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: dynamic
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          set x= @59
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: void
''');
  }

  test_instanceField_fieldFormal() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  var f = 0;
  A([this.f = 'hello']);
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          f @16
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
            shouldUseTypeForInitializerInference: false
        constructors
          @25
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              optionalPositional default final this.f @33
                type: int
                constantInitializer
                  SimpleStringLiteral
                    literal: 'hello' @37
                field: <thisLibrary>::<definingUnit>::@class::A::@field::f
        accessors
          synthetic get f @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
          synthetic set f= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::f
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _f @-1
                type: int
            returnType: void
''');
  }

  test_instanceField_fromField() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int x;
  int y;
  int z;
}
class B implements A {
  var x;
  get y => null;
  set z(_) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          x @25
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
          y @34
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
          z @43
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          synthetic get x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
          synthetic set x= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _x @-1
                type: int
            returnType: void
          synthetic get y @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
          synthetic set y= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _y @-1
                type: int
            returnType: void
          synthetic get z @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
          synthetic set z= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _z @-1
                type: int
            returnType: void
      class B @54
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
        fields
          x @77
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: int
          synthetic y @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: int
          synthetic z @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          synthetic get x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: int
          synthetic set x= @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _x @-1
                type: int
            returnType: void
          get y @86
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: int
          set z= @103
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _ @105
                type: int
            returnType: void
''');
  }

  test_instanceField_fromField_explicitDynamic() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  dynamic x;
}
class B implements A {
  var x = 1;
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          x @29
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: dynamic
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          synthetic get x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: dynamic
          synthetic set x= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _x @-1
                type: dynamic
            returnType: void
      class B @40
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
        fields
          x @63
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: dynamic
            shouldUseTypeForInitializerInference: true
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          synthetic get x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: dynamic
          synthetic set x= @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _x @-1
                type: dynamic
            returnType: void
''');
  }

  test_instanceField_fromField_generic() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A<E> {
  E x;
  E y;
  E z;
}
class B<T> implements A<T> {
  var x;
  get y => null;
  set z(_) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant E @17
            defaultType: dynamic
        fields
          x @26
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: E
          y @33
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: E
          z @40
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: E
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          synthetic get x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: E
          synthetic set x= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _x @-1
                type: E
            returnType: void
          synthetic get y @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: E
          synthetic set y= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _y @-1
                type: E
            returnType: void
          synthetic get z @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: E
          synthetic set z= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _z @-1
                type: E
            returnType: void
      class B @51
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant T @53
            defaultType: dynamic
        interfaces
          A<T>
        fields
          x @80
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: T
          synthetic y @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: T
          synthetic z @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: T
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          synthetic get x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: T
          synthetic set x= @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _x @-1
                type: T
            returnType: void
          get y @89
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: T
          set z= @106
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _ @108
                type: T
            returnType: void
''');
  }

  test_instanceField_fromField_implicitDynamic() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  var x;
}
class B implements A {
  var x = 1;
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          x @25
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: dynamic
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          synthetic get x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: dynamic
          synthetic set x= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _x @-1
                type: dynamic
            returnType: void
      class B @36
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
        fields
          x @59
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: dynamic
            shouldUseTypeForInitializerInference: true
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          synthetic get x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: dynamic
          synthetic set x= @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _x @-1
                type: dynamic
            returnType: void
''');
  }

  test_instanceField_fromField_narrowType() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  num x;
}
class B implements A {
  var x = 1;
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          x @25
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: num
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          synthetic get x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: num
          synthetic set x= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _x @-1
                type: num
            returnType: void
      class B @36
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
        fields
          x @59
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: num
            shouldUseTypeForInitializerInference: true
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          synthetic get x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: num
          synthetic set x= @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _x @-1
                type: num
            returnType: void
''');
  }

  test_instanceField_fromGetter() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
  int get y;
  int get z;
}
class B implements A {
  var x;
  get y => null;
  set z(_) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
          synthetic y @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
          synthetic z @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          abstract get x @29
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
          abstract get y @42
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
          abstract get z @55
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
      class B @66
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
        fields
          x @89
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: int
          synthetic y @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: int
          synthetic z @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          synthetic get x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: int
          synthetic set x= @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _x @-1
                type: int
            returnType: void
          get y @98
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: int
          set z= @115
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _ @117
                type: int
            returnType: void
''');
  }

  test_instanceField_fromGetter_generic() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A<E> {
  E get x;
  E get y;
  E get z;
}
class B<T> implements A<T> {
  var x;
  get y => null;
  set z(_) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant E @17
            defaultType: dynamic
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: E
          synthetic y @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: E
          synthetic z @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: E
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          abstract get x @30
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: E
          abstract get y @41
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: E
          abstract get z @52
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: E
      class B @63
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant T @65
            defaultType: dynamic
        interfaces
          A<T>
        fields
          x @92
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: T
          synthetic y @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: T
          synthetic z @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: T
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          synthetic get x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: T
          synthetic set x= @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _x @-1
                type: T
            returnType: void
          get y @101
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: T
          set z= @118
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _ @120
                type: T
            returnType: void
''');
  }

  test_instanceField_fromGetter_multiple_different() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
}
abstract class B {
  String get x;
}
class C implements A, B {
  get x => null;
}
''');
    // TODO(scheglov): test for inference failure error
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          abstract get x @29
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
      abstract class B @49
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: String
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          abstract get x @66
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: String
      class C @77
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
          B
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: dynamic
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        accessors
          get x @103
            reference: <thisLibrary>::<definingUnit>::@class::C::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            returnType: dynamic
''');
  }

  test_instanceField_fromGetter_multiple_different_dynamic() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
}
abstract class B {
  dynamic get x;
}
class C implements A, B {
  get x => null;
}
''');
    // TODO(scheglov): test for inference failure error
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          abstract get x @29
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
      abstract class B @49
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: dynamic
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          abstract get x @67
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: dynamic
      class C @78
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
          B
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        accessors
          get x @104
            reference: <thisLibrary>::<definingUnit>::@class::C::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            returnType: int
''');
  }

  test_instanceField_fromGetter_multiple_different_generic() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A<T> {
  T get x;
}
abstract class B<T> {
  T get x;
}
class C implements A<int>, B<String> {
  get x => null;
}
''');
    // TODO(scheglov): test for inference failure error
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant T @17
            defaultType: dynamic
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: T
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          abstract get x @30
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: T
      abstract class B @50
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant T @52
            defaultType: dynamic
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: T
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          abstract get x @65
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: T
      class C @76
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A<int>
          B<String>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: dynamic
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        accessors
          get x @115
            reference: <thisLibrary>::<definingUnit>::@class::C::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            returnType: dynamic
''');
  }

  test_instanceField_fromGetter_multiple_same() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
}
abstract class B {
  int get x;
}
class C implements A, B {
  get x => null;
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          abstract get x @29
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
      abstract class B @49
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          abstract get x @63
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: int
      class C @74
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
          B
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        accessors
          get x @100
            reference: <thisLibrary>::<definingUnit>::@class::C::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            returnType: int
''');
  }

  test_instanceField_fromGetterSetter_different_field() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
  int get y;
}
abstract class B {
  void set x(String _);
  void set y(String _);
}
class C implements A, B {
  var x;
  final y;
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
          synthetic y @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          abstract get x @29
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
          abstract get y @42
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
      abstract class B @62
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: String
          synthetic y @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: String
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          abstract set x= @77
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _ @86
                type: String
            returnType: void
          abstract set y= @101
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _ @110
                type: String
            returnType: void
      class C @122
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
          B
        fields
          x @148
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: dynamic
          final y @159
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        accessors
          synthetic get x @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            returnType: dynamic
          synthetic set x= @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            parameters
              requiredPositional _x @-1
                type: dynamic
            returnType: void
          synthetic get y @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@getter::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            returnType: int
''');
  }

  test_instanceField_fromGetterSetter_different_getter() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
}
abstract class B {
  void set x(String _);
}
class C implements A, B {
  get x => null;
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          abstract get x @29
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
      abstract class B @49
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: String
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          abstract set x= @64
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _ @73
                type: String
            returnType: void
      class C @85
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
          B
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        accessors
          get x @111
            reference: <thisLibrary>::<definingUnit>::@class::C::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            returnType: int
''');
  }

  test_instanceField_fromGetterSetter_different_setter() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
}
abstract class B {
  void set x(String _);
}
class C implements A, B {
  set x(_);
}
''');
    // TODO(scheglov): test for inference failure error
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          abstract get x @29
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
      abstract class B @49
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: String
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          abstract set x= @64
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _ @73
                type: String
            returnType: void
      class C @85
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
          B
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: String
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        accessors
          abstract set x= @111
            reference: <thisLibrary>::<definingUnit>::@class::C::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            parameters
              requiredPositional _ @113
                type: String
            returnType: void
''');
  }

  test_instanceField_fromGetterSetter_same_field() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
}
abstract class B {
  void set x(int _);
}
class C implements A, B {
  var x;
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          abstract get x @29
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
      abstract class B @49
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          abstract set x= @64
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _ @70
                type: int
            returnType: void
      class C @82
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
          B
        fields
          x @108
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        accessors
          synthetic get x @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            returnType: int
          synthetic set x= @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            parameters
              requiredPositional _x @-1
                type: int
            returnType: void
''');
  }

  test_instanceField_fromGetterSetter_same_getter() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
}
abstract class B {
  void set x(int _);
}
class C implements A, B {
  get x => null;
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          abstract get x @29
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
      abstract class B @49
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          abstract set x= @64
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _ @70
                type: int
            returnType: void
      class C @82
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
          B
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        accessors
          get x @108
            reference: <thisLibrary>::<definingUnit>::@class::C::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            returnType: int
''');
  }

  test_instanceField_fromGetterSetter_same_setter() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
}
abstract class B {
  void set x(int _);
}
class C implements A, B {
  set x(_);
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          abstract get x @29
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
      abstract class B @49
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          abstract set x= @64
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _ @70
                type: int
            returnType: void
      class C @82
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
          B
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        accessors
          abstract set x= @108
            reference: <thisLibrary>::<definingUnit>::@class::C::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            parameters
              requiredPositional _ @110
                type: int
            returnType: void
''');
  }

  test_instanceField_fromSetter() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  void set x(int _);
  void set y(int _);
  void set z(int _);
}
class B implements A {
  var x;
  get y => null;
  set z(_) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
          synthetic y @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
          synthetic z @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          abstract set x= @30
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _ @36
                type: int
            returnType: void
          abstract set y= @51
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _ @57
                type: int
            returnType: void
          abstract set z= @72
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _ @78
                type: int
            returnType: void
      class B @90
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
        fields
          x @113
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: int
          synthetic y @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: int
          synthetic z @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          synthetic get x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: int
          synthetic set x= @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _x @-1
                type: int
            returnType: void
          get y @122
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: int
          set z= @139
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::z
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _ @141
                type: int
            returnType: void
''');
  }

  test_instanceField_fromSetter_multiple_different() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  void set x(int _);
}
abstract class B {
  void set x(String _);
}
class C implements A, B {
  get x => null;
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          abstract set x= @30
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _ @36
                type: int
            returnType: void
      abstract class B @57
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: String
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          abstract set x= @72
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _ @81
                type: String
            returnType: void
      class C @93
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
          B
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: dynamic
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        accessors
          get x @119
            reference: <thisLibrary>::<definingUnit>::@class::C::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            returnType: dynamic
''');
  }

  test_instanceField_fromSetter_multiple_same() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  void set x(int _);
}
abstract class B {
  void set x(int _);
}
class C implements A, B {
  get x => null;
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          abstract set x= @30
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _ @36
                type: int
            returnType: void
      abstract class B @57
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          abstract set x= @72
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional _ @78
                type: int
            returnType: void
      class C @90
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
          B
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        accessors
          get x @116
            reference: <thisLibrary>::<definingUnit>::@class::C::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            returnType: int
''');
  }

  test_instanceField_functionTypeAlias_doesNotUseItsTypeParameter() async {
    var library = await _encodeDecodeLibrary(r'''
typedef F<T>();

class A<T> {
  F<T> get x => null;
  List<F<T>> get y => null;
}

class B extends A<int> {
  get x => null;
  get y => null;
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @23
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant T @25
            defaultType: dynamic
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: dynamic Function()
              alias: <thisLibrary>::<definingUnit>::@typeAlias::F
                typeArguments
                  T
          synthetic y @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: List<dynamic Function()>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          get x @41
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: dynamic Function()
              alias: <thisLibrary>::<definingUnit>::@typeAlias::F
                typeArguments
                  T
          get y @69
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: List<dynamic Function()>
      class B @89
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A<int>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: dynamic Function()
              alias: <thisLibrary>::<definingUnit>::@typeAlias::F
                typeArguments
                  int
          synthetic y @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: List<dynamic Function()>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            superConstructor: ConstructorMember
              base: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
              substitution: {T: int}
        accessors
          get x @114
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: dynamic Function()
              alias: <thisLibrary>::<definingUnit>::@typeAlias::F
                typeArguments
                  int
          get y @131
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::y
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: List<dynamic Function()>
    typeAliases
      functionTypeAliasBased F @8
        reference: <thisLibrary>::<definingUnit>::@typeAlias::F
        typeParameters
          unrelated T @10
            defaultType: dynamic
        aliasedType: dynamic Function()
        aliasedElement: GenericFunctionTypeElement
          returnType: dynamic
''');
  }

  test_instanceField_inheritsCovariant_fromSetter_field() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  num get x;
  void set x(covariant num _);
}
class B implements A {
  int x;
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: num
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          abstract get x @29
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: num
          abstract set x= @43
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional covariant _ @59
                type: num
            returnType: void
      class B @71
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
        fields
          x @94
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          synthetic get x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: int
          synthetic set x= @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional covariant _x @-1
                type: int
            returnType: void
''');
  }

  test_instanceField_inheritsCovariant_fromSetter_setter() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  num get x;
  void set x(covariant num _);
}
class B implements A {
  set x(int _) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: num
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          abstract get x @29
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: num
          abstract set x= @43
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional covariant _ @59
                type: num
            returnType: void
      class B @71
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
        fields
          synthetic x @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@field::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            type: int
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        accessors
          set x= @94
            reference: <thisLibrary>::<definingUnit>::@class::B::@setter::x
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional covariant _ @100
                type: int
            returnType: void
''');
  }

  test_instanceField_initializer() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  var t1 = 1;
  var t2 = 2.0;
  var t3 = null;
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          t1 @16
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::t1
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
            shouldUseTypeForInitializerInference: false
          t2 @30
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::t2
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: double
            shouldUseTypeForInitializerInference: false
          t3 @46
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::t3
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: dynamic
            shouldUseTypeForInitializerInference: false
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          synthetic get t1 @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::t1
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
          synthetic set t1= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::t1
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _t1 @-1
                type: int
            returnType: void
          synthetic get t2 @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::t2
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: double
          synthetic set t2= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::t2
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _t2 @-1
                type: double
            returnType: void
          synthetic get t3 @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::t3
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: dynamic
          synthetic set t3= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::t3
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _t3 @-1
                type: dynamic
            returnType: void
''');
  }

  test_method_error_hasMethod_noParameter_required() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  void m(int a) {}
}
class B extends A {
  void m(a, b) {}
}
''');
    // It's an error to add a new required parameter, but it is not a
    // top-level type inference error.
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @17
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @23
                type: int
            returnType: void
      class B @37
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            superConstructor: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
        methods
          m @58
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @60
                type: int
              requiredPositional b @63
                type: dynamic
            returnType: void
''');
  }

  test_method_error_noCombinedSuperSignature1() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  void m(int a) {}
}
class B {
  void m(String a) {}
}
class C extends A implements B {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @17
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @23
                type: int
            returnType: void
      class B @37
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        methods
          m @48
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @57
                type: String
            returnType: void
      class C @71
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A
        interfaces
          B
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            superConstructor: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
        methods
          m @100
            reference: <thisLibrary>::<definingUnit>::@class::C::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            typeInferenceError: overrideNoCombinedSuperSignature
            parameters
              requiredPositional a @102
                type: dynamic
            returnType: dynamic
''');
  }

  test_method_error_noCombinedSuperSignature2() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int foo(int x);
}

abstract class B {
  double foo(int x);
}

abstract class C implements A, B {
  Never foo(x);
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          abstract foo @25
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::foo
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional x @33
                type: int
            returnType: int
      abstract class B @55
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        methods
          abstract foo @68
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::foo
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional x @76
                type: int
            returnType: double
      abstract class C @98
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
          B
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        methods
          abstract foo @126
            reference: <thisLibrary>::<definingUnit>::@class::C::@method::foo
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            typeInferenceError: overrideNoCombinedSuperSignature
            parameters
              requiredPositional x @130
                type: dynamic
            returnType: Never
''');
  }

  test_method_error_noCombinedSuperSignature3() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  int m() {}
}
class B {
  String m() {}
}
class C extends A implements B {
  m() {}
}
''');
    // TODO(scheglov): test for inference failure error
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @16
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
      class B @31
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        methods
          m @44
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            returnType: String
      class C @59
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A
        interfaces
          B
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            superConstructor: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
        methods
          m @88
            reference: <thisLibrary>::<definingUnit>::@class::C::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            typeInferenceError: overrideNoCombinedSuperSignature
            returnType: dynamic
''');
  }

  test_method_error_noCombinedSuperSignature_generic1() async {
    var library = await _encodeDecodeLibrary(r'''
class A<T> {
  void m(T a) {}
}
class B<E> {
  void m(E a) {}
}
class C extends A<int> implements B<double> {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant T @8
            defaultType: dynamic
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @20
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @24
                type: T
            returnType: void
      class B @38
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant E @40
            defaultType: dynamic
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        methods
          m @52
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @56
                type: E
            returnType: void
      class C @70
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A<int>
        interfaces
          B<double>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            superConstructor: ConstructorMember
              base: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
              substitution: {T: int}
        methods
          m @112
            reference: <thisLibrary>::<definingUnit>::@class::C::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            typeInferenceError: overrideNoCombinedSuperSignature
            parameters
              requiredPositional a @114
                type: dynamic
            returnType: dynamic
''');
  }

  test_method_error_noCombinedSuperSignature_generic2() async {
    var library = await _encodeDecodeLibrary(r'''
class A<K, V> {
  V m(K a) {}
}
class B<T> {
  T m(int a) {}
}
class C extends A<int, String> implements B<double> {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant K @8
            defaultType: dynamic
          covariant V @11
            defaultType: dynamic
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @20
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @24
                type: K
            returnType: V
      class B @38
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant T @40
            defaultType: dynamic
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        methods
          m @49
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @55
                type: int
            returnType: T
      class C @69
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A<int, String>
        interfaces
          B<double>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            superConstructor: ConstructorMember
              base: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
              substitution: {K: int, V: String}
        methods
          m @119
            reference: <thisLibrary>::<definingUnit>::@class::C::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            typeInferenceError: overrideNoCombinedSuperSignature
            parameters
              requiredPositional a @121
                type: dynamic
            returnType: dynamic
''');
  }

  test_method_missing_hasMethod_noParameter_named() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  void m(int a) {}
}
class B extends A {
  m(a, {b}) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @17
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @23
                type: int
            returnType: void
      class B @37
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            superConstructor: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
        methods
          m @53
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @55
                type: int
              optionalNamed default b @59
                reference: <thisLibrary>::<definingUnit>::@class::B::@method::m::@parameter::b
                type: dynamic
            returnType: void
''');
  }

  test_method_missing_hasMethod_noParameter_optional() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  void m(int a) {}
}
class B extends A {
  m(a, [b]) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @17
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @23
                type: int
            returnType: void
      class B @37
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            superConstructor: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
        methods
          m @53
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @55
                type: int
              optionalPositional default b @59
                type: dynamic
            returnType: void
''');
  }

  test_method_missing_hasMethod_withoutTypes() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  m(a) {}
}
class B extends A {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @12
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @14
                type: dynamic
            returnType: dynamic
      class B @28
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            superConstructor: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
        methods
          m @44
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @46
                type: dynamic
            returnType: dynamic
''');
  }

  test_method_missing_noMember() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  int foo(String a) => null;
}
class B extends A {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          foo @16
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::foo
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @27
                type: String
            returnType: int
      class B @47
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            superConstructor: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
        methods
          m @63
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @65
                type: dynamic
            returnType: dynamic
''');
  }

  test_method_missing_notMethod() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  int m = 42;
}
class B extends A {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        fields
          m @16
            reference: <thisLibrary>::<definingUnit>::@class::A::@field::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            type: int
            shouldUseTypeForInitializerInference: true
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        accessors
          synthetic get m @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@getter::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            returnType: int
          synthetic set m= @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@setter::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional _m @-1
                type: int
            returnType: void
      class B @32
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            superConstructor: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
        methods
          m @48
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @50
                type: dynamic
            returnType: dynamic
''');
  }

  test_method_OK_sequence_extendsExtends_generic() async {
    var library = await _encodeDecodeLibrary(r'''
class A<K, V> {
  V m(K a) {}
}
class B<T> extends A<int, T> {}
class C extends B<String> {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant K @8
            defaultType: dynamic
          covariant V @11
            defaultType: dynamic
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @20
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @24
                type: K
            returnType: V
      class B @38
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant T @40
            defaultType: dynamic
        supertype: A<int, T>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            superConstructor: ConstructorMember
              base: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
              substitution: {K: int, V: T}
      class C @70
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: B<String>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            superConstructor: ConstructorMember
              base: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
              substitution: {T: String}
        methods
          m @94
            reference: <thisLibrary>::<definingUnit>::@class::C::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            parameters
              requiredPositional a @96
                type: int
            returnType: String
''');
  }

  test_method_OK_sequence_inferMiddle_extendsExtends() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  String m(int a) {}
}
class B extends A {
  m(a) {}
}
class C extends B {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @19
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @25
                type: int
            returnType: String
      class B @39
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            superConstructor: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
        methods
          m @55
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @57
                type: int
            returnType: String
      class C @71
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: B
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            superConstructor: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
        methods
          m @87
            reference: <thisLibrary>::<definingUnit>::@class::C::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            parameters
              requiredPositional a @89
                type: int
            returnType: String
''');
  }

  test_method_OK_sequence_inferMiddle_extendsImplements() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  String m(int a) {}
}
class B implements A {
  m(a) {}
}
class C extends B {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @19
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @25
                type: int
            returnType: String
      class B @39
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        methods
          m @58
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @60
                type: int
            returnType: String
      class C @74
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: B
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            superConstructor: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
        methods
          m @90
            reference: <thisLibrary>::<definingUnit>::@class::C::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            parameters
              requiredPositional a @92
                type: int
            returnType: String
''');
  }

  test_method_OK_sequence_inferMiddle_extendsWith() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  String m(int a) {}
}
class B extends Object with A {
  m(a) {}
}
class C extends B {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @19
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @25
                type: int
            returnType: String
      class B @39
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: Object
        mixins
          A
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        methods
          m @67
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @69
                type: int
            returnType: String
      class C @83
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: B
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            superConstructor: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
        methods
          m @99
            reference: <thisLibrary>::<definingUnit>::@class::C::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            parameters
              requiredPositional a @101
                type: int
            returnType: String
''');
  }

  test_method_OK_single_extends_direct_generic() async {
    var library = await _encodeDecodeLibrary(r'''
class A<K, V> {
  V m(K a, double b) {}
}
class B extends A<int, String> {
  m(a, b) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant K @8
            defaultType: dynamic
          covariant V @11
            defaultType: dynamic
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @20
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @24
                type: K
              requiredPositional b @34
                type: double
            returnType: V
      class B @48
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A<int, String>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            superConstructor: ConstructorMember
              base: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
              substitution: {K: int, V: String}
        methods
          m @77
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @79
                type: int
              requiredPositional b @82
                type: double
            returnType: String
''');
  }

  test_method_OK_single_extends_direct_notGeneric() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  String m(int a) {}
}
class B extends A {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @19
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @25
                type: int
            returnType: String
      class B @39
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            superConstructor: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
        methods
          m @55
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @57
                type: int
            returnType: String
''');
  }

  test_method_OK_single_extends_direct_notGeneric_named() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  String m(int a, {double b}) {}
}
class B extends A {
  m(a, {b}) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @19
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @25
                type: int
              optionalNamed default b @36
                reference: <thisLibrary>::<definingUnit>::@class::A::@method::m::@parameter::b
                type: double
            returnType: String
      class B @51
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            superConstructor: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
        methods
          m @67
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @69
                type: int
              optionalNamed default b @73
                reference: <thisLibrary>::<definingUnit>::@class::B::@method::m::@parameter::b
                type: double
            returnType: String
''');
  }

  test_method_OK_single_extends_direct_notGeneric_positional() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  String m(int a, [double b]) {}
}
class B extends A {
  m(a, [b]) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @19
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @25
                type: int
              optionalPositional default b @36
                type: double
            returnType: String
      class B @51
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            superConstructor: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
        methods
          m @67
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @69
                type: int
              optionalPositional default b @73
                type: double
            returnType: String
''');
  }

  test_method_OK_single_extends_indirect_generic() async {
    var library = await _encodeDecodeLibrary(r'''
class A<K, V> {
  V m(K a) {}
}
class B<T> extends A<int, T> {}
class C extends B<String> {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant K @8
            defaultType: dynamic
          covariant V @11
            defaultType: dynamic
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @20
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @24
                type: K
            returnType: V
      class B @38
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant T @40
            defaultType: dynamic
        supertype: A<int, T>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            superConstructor: ConstructorMember
              base: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
              substitution: {K: int, V: T}
      class C @70
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: B<String>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            superConstructor: ConstructorMember
              base: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
              substitution: {T: String}
        methods
          m @94
            reference: <thisLibrary>::<definingUnit>::@class::C::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            parameters
              requiredPositional a @96
                type: int
            returnType: String
''');
  }

  test_method_OK_single_implements_direct_generic() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A<K, V> {
  V m(K a);
}
class B implements A<int, String> {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant K @17
            defaultType: dynamic
          covariant V @20
            defaultType: dynamic
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          abstract m @29
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @33
                type: K
            returnType: V
      class B @45
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A<int, String>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        methods
          m @77
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @79
                type: int
            returnType: String
''');
  }

  test_method_OK_single_implements_direct_notGeneric() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  String m(int a);
}
class B implements A {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          abstract m @28
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @34
                type: int
            returnType: String
      class B @46
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          A
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        methods
          m @65
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @67
                type: int
            returnType: String
''');
  }

  test_method_OK_single_implements_indirect_generic() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A<K, V> {
  V m(K a);
}
abstract class B<T1, T2> extends A<T2, T1> {}
class C implements B<int, String> {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      abstract class A @15
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant K @17
            defaultType: dynamic
          covariant V @20
            defaultType: dynamic
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          abstract m @29
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @33
                type: K
            returnType: V
      abstract class B @54
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant T1 @56
            defaultType: dynamic
          covariant T2 @60
            defaultType: dynamic
        supertype: A<T2, T1>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            superConstructor: ConstructorMember
              base: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
              substitution: {K: T2, V: T1}
      class C @91
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        interfaces
          B<int, String>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
        methods
          m @123
            reference: <thisLibrary>::<definingUnit>::@class::C::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            parameters
              requiredPositional a @125
                type: String
            returnType: int
''');
  }

  test_method_OK_single_private_linkThroughOtherLibraryOfCycle() async {
    newFile('$testPackageLibPath/other.dart', r'''
import 'test.dart';
class B extends A2 {}
''');
    var library = await _encodeDecodeLibrary(r'''
import 'other.dart';
class A1 {
  int _foo() => 1;
}
class A2 extends A1 {
  _foo() => 2;
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  libraryImports
    package:test/other.dart
      enclosingElement: <thisLibrary>
      enclosingElement3: <thisLibrary>::<definingUnit>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    libraryImports
      package:test/other.dart
        enclosingElement: <thisLibrary>
        enclosingElement3: <thisLibrary>::<definingUnit>
    classes
      class A1 @27
        reference: <thisLibrary>::<definingUnit>::@class::A1
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A1::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A1
        methods
          _foo @38
            reference: <thisLibrary>::<definingUnit>::@class::A1::@method::_foo
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A1
            returnType: int
      class A2 @59
        reference: <thisLibrary>::<definingUnit>::@class::A2
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A1
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A2::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A2
            superConstructor: <thisLibrary>::<definingUnit>::@class::A1::@constructor::new
        methods
          _foo @77
            reference: <thisLibrary>::<definingUnit>::@class::A2::@method::_foo
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A2
            returnType: int
''');
  }

  test_method_OK_single_withExtends_notGeneric() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  String m(int a) {}
}
class B extends Object with A {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @19
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @25
                type: int
            returnType: String
      class B @39
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: Object
        mixins
          A
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        methods
          m @67
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @69
                type: int
            returnType: String
''');
  }

  test_method_OK_two_extendsImplements_generic() async {
    var library = await _encodeDecodeLibrary(r'''
class A<K, V> {
  V m(K a) {}
}
class B<T> {
  T m(int a) {}
}
class C extends A<int, String> implements B<String> {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant K @8
            defaultType: dynamic
          covariant V @11
            defaultType: dynamic
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @20
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @24
                type: K
            returnType: V
      class B @38
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        typeParameters
          covariant T @40
            defaultType: dynamic
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        methods
          m @49
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @55
                type: int
            returnType: T
      class C @69
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A<int, String>
        interfaces
          B<String>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            superConstructor: ConstructorMember
              base: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
              substitution: {K: int, V: String}
        methods
          m @119
            reference: <thisLibrary>::<definingUnit>::@class::C::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            parameters
              requiredPositional a @121
                type: int
            returnType: String
''');
  }

  test_method_OK_two_extendsImplements_notGeneric() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  String m(int a) {}
}
class B {
  String m(int a) {}
}
class C extends A implements B {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <thisLibrary>
  definingUnit
    reference: <thisLibrary>::<definingUnit>
    enclosingElement: <thisLibrary>
    classes
      class A @6
        reference: <thisLibrary>::<definingUnit>::@class::A
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
        methods
          m @19
            reference: <thisLibrary>::<definingUnit>::@class::A::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::A
            parameters
              requiredPositional a @25
                type: int
            returnType: String
      class B @39
        reference: <thisLibrary>::<definingUnit>::@class::B
        enclosingElement: <thisLibrary>::<definingUnit>
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::B::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
        methods
          m @52
            reference: <thisLibrary>::<definingUnit>::@class::B::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::B
            parameters
              requiredPositional a @58
                type: int
            returnType: String
      class C @72
        reference: <thisLibrary>::<definingUnit>::@class::C
        enclosingElement: <thisLibrary>::<definingUnit>
        supertype: A
        interfaces
          B
        constructors
          synthetic @-1
            reference: <thisLibrary>::<definingUnit>::@class::C::@constructor::new
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            superConstructor: <thisLibrary>::<definingUnit>::@class::A::@constructor::new
        methods
          m @101
            reference: <thisLibrary>::<definingUnit>::@class::C::@method::m
            enclosingElement: <thisLibrary>::<definingUnit>::@class::C
            parameters
              requiredPositional a @103
                type: int
            returnType: String
''');
  }

  Future<LibraryElementImpl> _encodeDecodeLibrary(String text) async {
    newFile(testFile.path, text);

    var analysisSession = contextFor(testFile).currentSession;
    var result = await analysisSession.getUnitElement(testFile.path);
    result as UnitElementResult;
    return result.element.library as LibraryElementImpl;
  }
}
