// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This file implements the AST of a Dart-like language suitable for testing
/// flow analysis.  Callers may use the top level methods in this file to create
/// AST nodes and then feed them to [Harness.run] to run them through flow
/// analysis testing.
import 'package:_fe_analyzer_shared/src/flow_analysis/flow_analysis.dart'
    show EqualityInfo, FlowAnalysis, Operations;
import 'package:_fe_analyzer_shared/src/type_inference/assigned_variables.dart';
import 'package:_fe_analyzer_shared/src/type_inference/type_analysis_result.dart';
import 'package:_fe_analyzer_shared/src/type_inference/type_analyzer.dart';
import 'package:_fe_analyzer_shared/src/type_inference/type_operations.dart';
import 'package:test/test.dart';

import 'mini_ir.dart';
import 'mini_types.dart';

/// Regular expression used by [computeLocation] to extract file locations from
/// a stack trace.
final RegExp _locationRegExp = RegExp('[a-zA-Z_.]+:[0-9]+:[0-9]+');

Literal get nullLiteral => new _NullLiteral(location: computeLocation());

Expression get this_ => new _This(location: computeLocation());

Statement assert_(Expression condition, [Expression? message]) =>
    new _Assert(condition, message, location: computeLocation());

Statement block(List<Statement> statements) =>
    new _Block(statements, location: computeLocation());

Expression booleanLiteral(bool value) =>
    _BooleanLiteral(value, location: computeLocation());

Statement break_([Label? target]) =>
    new _Break(target, location: computeLocation());

StatementCase case_(Pattern pattern,
    {Expression? when, required List<Statement> body}) {
  var location = computeLocation();
  return StatementCase._(pattern, when, _Block(body, location: location),
      location: location);
}

ExpressionCase caseExpr(Pattern pattern,
        {Expression? when, required Expression body}) =>
    ExpressionCase._(pattern, when, body, location: computeLocation());

/// Creates a pseudo-statement whose function is to verify that flow analysis
/// considers [variable]'s assigned state to be [expectedAssignedState].
Statement checkAssigned(Var variable, bool expectedAssignedState) =>
    new _CheckAssigned(variable, expectedAssignedState,
        location: computeLocation());

/// Creates a pseudo-statement whose function is to verify that flow analysis
/// considers [promotable] to be un-promoted.
Statement checkNotPromoted(Promotable promotable) =>
    new _CheckPromoted(promotable, null, location: computeLocation());

/// Creates a pseudo-statement whose function is to verify that flow analysis
/// considers [promotable]'s assigned state to be promoted to [expectedTypeStr].
Statement checkPromoted(Promotable promotable, String? expectedTypeStr) =>
    new _CheckPromoted(promotable, expectedTypeStr,
        location: computeLocation());

/// Creates a pseudo-statement whose function is to verify that flow analysis
/// considers the current location's reachability state to be
/// [expectedReachable].
Statement checkReachable(bool expectedReachable) =>
    new _CheckReachable(expectedReachable, location: computeLocation());

/// Creates a pseudo-statement whose function is to verify that flow analysis
/// considers [variable]'s unassigned state to be [expectedUnassignedState].
Statement checkUnassigned(Var variable, bool expectedUnassignedState) =>
    new _CheckUnassigned(variable, expectedUnassignedState,
        location: computeLocation());

/// Computes a "location" string using `StackTrace.current` to find the source
/// location of the caller's caller.
///
/// Note: this is highly dependent on the behavior of VM stack traces.  This
/// won't work in code compiled with dart2js for example.  That's fine, though,
/// since we only run these tests under the VM.
String computeLocation() {
  var callStack = StackTrace.current.toString().split('\n');
  assert(callStack[0].contains('mini_ast.dart'));
  assert(callStack[1].contains('mini_ast.dart'));
  assert(
      callStack[2].contains('type_inference_test.dart') ||
          callStack[2].contains('flow_analysis_test.dart'),
      'Unexpected file: ${callStack[2]}');
  var match = _locationRegExp.firstMatch(callStack[2]);
  if (match == null) {
    throw AssertionError(
        '_locationRegExp failed to match ${callStack[2]} in $callStack');
  }
  return match.group(0)!;
}

Statement continue_() => new _Continue(location: computeLocation());

Statement declare(Var variable,
    {bool isLate = false,
    bool isFinal = false,
    String? type,
    Expression? initializer,
    String? expectInferredType}) {
  var location = computeLocation();
  return new _Declare(
      new _VariablePattern(
          type == null ? null : Type(type), variable, expectInferredType,
          location: location),
      initializer,
      isLate: isLate,
      isFinal: isFinal,
      location: location);
}

StatementCase default_({required List<Statement> body}) {
  var location = computeLocation();
  return StatementCase._(null, null, _Block(body, location: location),
      location: location);
}

ExpressionCase defaultExpr({required Expression body}) =>
    ExpressionCase._(null, null, body, location: computeLocation());

Statement do_(List<Statement> body, Expression condition) {
  var location = computeLocation();
  return _Do(_Block(body, location: location), condition, location: location);
}

/// Creates a pseudo-expression having type [typeStr] that otherwise has no
/// effect on flow analysis.
Expression expr(String typeStr) =>
    new _PlaceholderExpression(new Type(typeStr), location: computeLocation());

/// Creates a conventional `for` statement.  Optional boolean [forCollection]
/// indicates that this `for` statement is actually a collection element, so
/// `null` should be passed to [for_bodyBegin].
Statement for_(Statement? initializer, Expression? condition,
    Expression? updater, List<Statement> body,
    {bool forCollection = false}) {
  var location = computeLocation();
  return new _For(initializer, condition, updater,
      _Block(body, location: location), forCollection,
      location: location);
}

/// Creates a "for each" statement where the identifier being assigned to by the
/// iteration is not a local variable.
///
/// This models code like:
///     var x; // Top level variable
///     f(Iterable iterable) {
///       for (x in iterable) { ... }
///     }
Statement forEachWithNonVariable(Expression iterable, List<Statement> body) {
  var location = computeLocation();
  return new _ForEach(null, iterable, _Block(body, location: location), false,
      location: location);
}

/// Creates a "for each" statement where the identifier being assigned to by the
/// iteration is a variable that is being declared by the "for each" statement.
///
/// This models code like:
///     f(Iterable iterable) {
///       for (var x in iterable) { ... }
///     }
Statement forEachWithVariableDecl(
    Var variable, Expression iterable, List<Statement> body) {
  // ignore: unnecessary_null_comparison
  assert(variable != null);
  return new _ForEach(variable, iterable, block(body), true,
      location: computeLocation());
}

/// Creates a "for each" statement where the identifier being assigned to by the
/// iteration is a local variable that is declared elsewhere in the function.
///
/// This models code like:
///     f(Iterable iterable) {
///       var x;
///       for (x in iterable) { ... }
///     }
Statement forEachWithVariableSet(
    Var variable, Expression iterable, List<Statement> body) {
  // ignore: unnecessary_null_comparison
  assert(variable != null);
  var location = computeLocation();
  return new _ForEach(
      variable, iterable, _Block(body, location: location), false,
      location: location);
}

Statement if_(Expression condition, List<Statement> ifTrue,
    [List<Statement>? ifFalse]) {
  var location = computeLocation();
  return new _If(condition, _Block(ifTrue, location: location),
      ifFalse == null ? null : _Block(ifFalse, location: location),
      location: location);
}

Literal intLiteral(int value, {bool? expectConversionToDouble}) =>
    new _IntLiteral(value,
        expectConversionToDouble: expectConversionToDouble,
        location: computeLocation());

Statement localFunction(List<Statement> body) {
  var location = computeLocation();
  return _LocalFunction(_Block(body, location: location), location: location);
}

Statement match(Pattern pattern, Expression initializer,
        {bool isLate = false, bool isFinal = false}) =>
    new _Declare(pattern, initializer,
        isLate: isLate, isFinal: isFinal, location: computeLocation());

Statement return_() => new _Return(location: computeLocation());

Statement switch_(Expression expression, List<StatementCase> cases,
        {required bool isExhaustive}) =>
    new _SwitchStatement(expression, cases, isExhaustive,
        location: computeLocation());

Expression switchExpr(Expression expression, List<ExpressionCase> cases) =>
    new _SwitchExpression(expression, cases, location: computeLocation());

PromotableLValue thisOrSuperProperty(String name) =>
    new _ThisOrSuperProperty(name, location: computeLocation());

Expression throw_(Expression operand) =>
    new _Throw(operand, location: computeLocation());

TryBuilder try_(List<Statement> body) {
  var location = computeLocation();
  return new _TryStatement(_Block(body, location: location), [], null,
      location: location);
}

Statement while_(Expression condition, List<Statement> body) {
  var location = computeLocation();
  return new _While(condition, _Block(body, location: location),
      location: location);
}

/// Representation of an expression in the pseudo-Dart language used for flow
/// analysis testing.  Methods in this class may be used to create more complex
/// expressions based on this one.
abstract class Expression extends Node {
  Expression({required super.location}) : super._();

  /// If `this` is an expression `x`, creates the expression `x!`.
  Expression get nonNullAssert =>
      new _NonNullAssert(this, location: computeLocation());

  /// If `this` is an expression `x`, creates the expression `!x`.
  Expression get not => new _Not(this, location: computeLocation());

  /// If `this` is an expression `x`, creates the expression `(x)`.
  Expression get parenthesized =>
      new _ParenthesizedExpression(this, location: computeLocation());

  /// If `this` is an expression `x`, creates the statement `x;`.
  Statement get stmt =>
      new _ExpressionStatement(this, location: computeLocation());

  /// If `this` is an expression `x`, creates the expression `x && other`.
  Expression and(Expression other) =>
      new _Logical(this, other, isAnd: true, location: computeLocation());

  /// If `this` is an expression `x`, creates the expression `x as typeStr`.
  Expression as_(String typeStr) =>
      new _As(this, Type(typeStr), location: computeLocation());

  /// Wraps `this` in such a way that, when the test is run, it will verify that
  /// the context provided when analyzing the expression matches
  /// [expectedContext].
  Expression checkContext(String expectedContext) =>
      _CheckExpressionContext(this, expectedContext,
          location: computeLocation());

  /// Wraps `this` in such a way that, when the test is run, it will verify that
  /// the IR produced matches [expectedIr].
  Expression checkIr(String expectedIr) =>
      _CheckExpressionIr(this, expectedIr, location: computeLocation());

  /// Creates an [Expression] that, when analyzed, will behave the same as
  /// `this`, but after visiting it, will verify that the type of the expression
  /// was [expectedType].
  Expression checkType(String expectedType) =>
      new _CheckExpressionType(this, expectedType, location: computeLocation());

  /// If `this` is an expression `x`, creates the expression
  /// `x ? ifTrue : ifFalse`.
  Expression conditional(Expression ifTrue, Expression ifFalse) =>
      new _Conditional(this, ifTrue, ifFalse, location: computeLocation());

  /// If `this` is an expression `x`, creates the expression `x == other`.
  Expression eq(Expression other) =>
      new _Equal(this, other, false, location: computeLocation());

  /// If `this` is an expression `x`, creates the expression `x ?? other`.
  Expression ifNull(Expression other) =>
      new _IfNull(this, other, location: computeLocation());

  /// Creates a [Statement] that, when analyzed, will analyze `this`, supplying
  /// a context type of [context].
  Statement inContext(String context) =>
      _ExpressionInContext(this, Type(context), location: computeLocation());

  /// If `this` is an expression `x`, creates the expression `x is typeStr`.
  ///
  /// With [isInverted] set to `true`, creates the expression `x is! typeStr`.
  Expression is_(String typeStr, {bool isInverted = false}) =>
      new _Is(this, Type(typeStr), isInverted, location: computeLocation());

  /// If `this` is an expression `x`, creates the expression `x is! typeStr`.
  Expression isNot(String typeStr) =>
      _Is(this, Type(typeStr), true, location: computeLocation());

  /// If `this` is an expression `x`, creates the expression `x != other`.
  Expression notEq(Expression other) =>
      _Equal(this, other, true, location: computeLocation());

  /// If `this` is an expression `x`, creates the expression `x?.other`.
  ///
  /// Note that in the real Dart language, the RHS of a null aware access isn't
  /// strictly speaking an expression.  However for flow analysis it suffices to
  /// model it as an expression.
  Expression nullAwareAccess(Expression other, {bool isCascaded = false}) =>
      _NullAwareAccess(this, other, isCascaded, location: computeLocation());

  /// If `this` is an expression `x`, creates the expression `x || other`.
  Expression or(Expression other) =>
      new _Logical(this, other, isAnd: false, location: computeLocation());

  void preVisit(AssignedVariables<Node, Var> assignedVariables);

  /// If `this` is an expression `x`, creates the L-value `x.name`.
  PromotableLValue property(String name) =>
      new _Property(this, name, location: computeLocation());

  /// If `this` is an expression `x`, creates a pseudo-expression that models
  /// evaluation of `x` followed by execution of [stmt].  This can be used to
  /// test that flow analysis is in the correct state after an expression is
  /// visited.
  Expression thenStmt(Statement stmt) =>
      new _WrappedExpression(null, this, stmt, location: computeLocation());

  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context);
}

/// Representation of a single case clause in a switch expression.  Use
/// [caseExpr] to create instances of this class.
class ExpressionCase extends Node
    implements ExpressionCaseInfo<Expression, Node> {
  @override
  final Pattern? pattern;

  @override
  final Expression? when;

  @override
  final Expression body;

  ExpressionCase._(this.pattern, this.when, this.body,
      {required super.location})
      : super._();

  String toString() => [
        pattern == null ? 'default' : 'case $pattern',
        if (when != null) ' when $when',
        ': $body'
      ].join('');

  void _preVisit(AssignedVariables<Node, Var> assignedVariables) {
    pattern?.preVisit(assignedVariables);
    body.preVisit(assignedVariables);
  }
}

class Harness
    with TypeOperations<Type>, TypeOperations2<Type>
    implements Operations<Var, Type> {
  static const Map<String, bool> _coreSubtypes = const {
    'bool <: int': false,
    'bool <: Object': true,
    'double <: double?': true,
    'double <: Object': true,
    'double <: Object?': true,
    'double <: Never': false,
    'double <: num': true,
    'double <: num?': true,
    'double <: int': false,
    'double <: int?': false,
    'double <: String': false,
    'int <: double': false,
    'int <: double?': false,
    'int <: int?': true,
    'int <: Iterable': false,
    'int <: List': false,
    'int <: Never': false,
    'int <: Null': false,
    'int <: num': true,
    'int <: num?': true,
    'int <: num*': true,
    'int <: Never?': false,
    'int <: Object': true,
    'int <: Object?': true,
    'int <: String': false,
    'int <: ?': true,
    'int? <: int': false,
    'int? <: Null': false,
    'int? <: num': false,
    'int? <: num?': true,
    'int? <: Object': false,
    'int? <: Object?': true,
    'Never <: Object?': true,
    'Null <: int': false,
    'Null <: Object': false,
    'Null <: Object?': true,
    'Null <: dynamic': true,
    'num <: int': false,
    'num <: Iterable': false,
    'num <: List': false,
    'num <: num?': true,
    'num <: num*': true,
    'num <: Object': true,
    'num <: Object?': true,
    'num? <: int?': false,
    'num? <: num': false,
    'num? <: num*': true,
    'num? <: Object': false,
    'num? <: Object?': true,
    'num* <: num': true,
    'num* <: num?': true,
    'num* <: Object': true,
    'num* <: Object?': true,
    'Iterable <: int': false,
    'Iterable <: num': false,
    'Iterable <: Object': true,
    'Iterable <: Object?': true,
    'List <: int': false,
    'List <: Iterable': true,
    'List <: Object': true,
    'Never <: int': true,
    'Never <: int?': true,
    'Never <: Null': true,
    'Never? <: int': false,
    'Never? <: int?': true,
    'Never? <: num?': true,
    'Never? <: Object?': true,
    'Null <: int?': true,
    'Object <: int': false,
    'Object <: int?': false,
    'Object <: List': false,
    'Object <: Null': false,
    'Object <: num': false,
    'Object <: num?': false,
    'Object <: Object?': true,
    'Object <: String': false,
    'Object? <: Object': false,
    'Object? <: int': false,
    'Object? <: int?': false,
    'Object? <: Null': false,
    'String <: int': false,
    'String <: int?': false,
    'String <: num': false,
    'String <: num?': false,
    'String <: Object': true,
    'String <: Object?': true,
    'String? <: Object?': true,
  };

  static final Map<String, Type> _coreFactors = {
    'Object? - double': Type('Object?'),
    'Object? - int': Type('Object?'),
    'Object? - int?': Type('Object'),
    'Object? - Never': Type('Object?'),
    'Object? - Null': Type('Object'),
    'Object? - num?': Type('Object'),
    'Object? - Object?': Type('Never?'),
    'Object? - String': Type('Object?'),
    'Object? - String?': Type('Object?'),
    'Object - bool': Type('Object'),
    'Object - int': Type('Object'),
    'Object - String': Type('Object'),
    'int - Object': Type('Never'),
    'int - String': Type('int'),
    'int - int': Type('Never'),
    'int - int?': Type('Never'),
    'int? - int': Type('Never?'),
    'int? - int?': Type('Never'),
    'int? - String': Type('int?'),
    'Null - int': Type('Null'),
    'num - int': Type('num'),
    'num? - num': Type('Never?'),
    'num? - int': Type('num?'),
    'num? - int?': Type('num'),
    'num? - Object': Type('Never?'),
    'num? - String': Type('num?'),
    'Object - int?': Type('Object'),
    'Object - num': Type('Object'),
    'Object - num?': Type('Object'),
    'Object - num*': Type('Object'),
    'Object - Iterable': Type('Object'),
    'Object? - Object': Type('Never?'),
    'Object? - Iterable': Type('Object?'),
    'Object? - num': Type('Object?'),
    'Iterable - List': Type('Iterable'),
    'num* - Object': Type('Never'),
  };

  static final Map<String, Type> _coreLubs = {
    'double, int': Type('num'),
    'Never, int': Type('int'),
  };

  bool _started = false;

  late final FlowAnalysis<Node, Statement, Expression, Var, Type> flow;

  bool _legacy = false;

  Type? _thisType;

  final Map<String, bool> _subtypes = Map.of(_coreSubtypes);

  final Map<String, Type> _factorResults = Map.of(_coreFactors);

  final Map<String, Type> _lubs = Map.of(_coreLubs);

  final Map<String, _PropertyElement> _members = {};

  Map<String, Map<String, String>> _promotionExceptions = {};

  late final typeAnalyzer = _MiniAstTypeAnalyzer(this);

  /// Indicates whether initializers of implicitly typed variables should be
  /// accounted for by SSA analysis.  (In an ideal world, they always would be,
  /// but due to https://github.com/dart-lang/language/issues/1785, they weren't
  /// always, and we need to be able to replicate the old behavior when
  /// analyzing old language versions).
  bool _respectImplicitlyTypedVarInitializers = true;

  final Set<_PropertyElement> promotableFields = {};

  MiniIrBuilder get irBuilder => typeAnalyzer._irBuilder;

  set legacy(bool value) {
    assert(!_started);
    _legacy = value;
  }

  set respectImplicitlyTypedVarInitializers(bool value) {
    assert(!_started);
    _respectImplicitlyTypedVarInitializers = value;
  }

  set thisType(String type) {
    assert(!_started);
    _thisType = Type(type);
  }

  /// Updates the harness so that when a [factor] query is invoked on types
  /// [from] and [what], [result] will be returned.
  void addFactor(String from, String what, String result) {
    var query = '$from - $what';
    _factorResults[query] = Type(result);
  }

  /// Updates the harness so that when member [memberName] is looked up on type
  /// [targetType], a member is found having the given [type].
  void addMember(String targetType, String memberName, String type,
      {bool promotable = false}) {
    var query = '$targetType.$memberName';
    var member = _PropertyElement(Type(type));
    _members[query] = member;
    if (promotable) {
      promotableFields.add(member);
    }
  }

  void addPromotionException(String from, String to, String result) {
    (_promotionExceptions[from] ??= {})[to] = result;
  }

  /// Updates the harness so that when an [isSubtypeOf] query is invoked on
  /// types [leftType] and [rightType], [isSubtype] will be returned.
  void addSubtype(String leftType, String rightType, bool isSubtype) {
    var query = '$leftType <: $rightType';
    _subtypes[query] = isSubtype;
  }

  @override
  TypeClassification classifyType(Type type) {
    if (isSubtypeOf(type, Type('Object'))) {
      return TypeClassification.nonNullable;
    } else if (isSubtypeOf(type, Type('Null'))) {
      return TypeClassification.nullOrEquivalent;
    } else {
      return TypeClassification.potentiallyNullable;
    }
  }

  @override
  Type factor(Type from, Type what) {
    var query = '$from - $what';
    return _factorResults[query] ?? fail('Unknown factor query: $query');
  }

  /// Attempts to look up a member named [memberName] in the given [type].  If
  /// a member is found, returns its [_PropertyElement] object.  Otherwise the
  /// test fails.
  _PropertyElement getMember(Type type, String memberName) {
    var query = '$type.$memberName';
    return _members[query] ?? fail('Unknown member query: $query');
  }

  @override
  bool isAssignableTo(Type leftType, Type rightType) {
    if (leftType.type == 'dynamic') return true;
    return isSubtypeOf(leftType, rightType);
  }

  @override
  bool isNever(Type type) {
    return type.type == 'Never';
  }

  @override
  bool isSameType(Type type1, Type type2) {
    return type1.type == type2.type;
  }

  @override
  bool isSubtypeOf(Type leftType, Type rightType) {
    if (leftType.type == rightType.type) return true;
    var query = '$leftType <: $rightType';
    return _subtypes[query] ?? fail('Unknown subtype query: $query');
  }

  @override
  bool isTypeParameterType(Type type) => type is PromotedTypeVariableType;

  @override
  Type lub(Type type1, Type type2) {
    if (type1.type == type2.type) return type1;
    var typeNames = [type1.type, type2.type];
    typeNames.sort();
    var query = typeNames.join(', ');
    return _lubs[query] ?? fail('Unknown lub query: $query');
  }

  @override
  Type promoteToNonNull(Type type) {
    if (type.type.endsWith('?')) {
      return Type(type.type.substring(0, type.type.length - 1));
    } else if (type.type == 'Null') {
      return Type('Never');
    } else {
      return type;
    }
  }

  /// Runs the given [statements] through flow analysis, checking any assertions
  /// they contain.
  void run(List<Statement> statements) {
    _started = true;
    var assignedVariables = AssignedVariables<Node, Var>();
    var b = _Block(statements, location: computeLocation());
    b.preVisit(assignedVariables);
    flow = _legacy
        ? FlowAnalysis<Node, Statement, Expression, Var, Type>.legacy(
            this, assignedVariables)
        : FlowAnalysis<Node, Statement, Expression, Var, Type>(
            this, assignedVariables,
            respectImplicitlyTypedVarInitializers:
                _respectImplicitlyTypedVarInitializers,
            promotableFields: promotableFields);
    typeAnalyzer.dispatchStatement(b);
    typeAnalyzer.finish();
    expect(typeAnalyzer.errors._accumulatedErrors, isEmpty);
    var assertInErrorRecoveryStack =
        typeAnalyzer.errors._assertInErrorRecoveryStack;
    if (assertInErrorRecoveryStack != null) {
      fail('assertInErrorRecovery called but no errors reported: '
          '$assertInErrorRecoveryStack');
    }
  }

  @override
  Type? tryPromoteToType(Type to, Type from) {
    var exception = (_promotionExceptions[from.type] ?? {})[to.type];
    if (exception != null) {
      return Type(exception);
    }
    if (isSubtypeOf(to, from)) {
      return to;
    } else {
      return null;
    }
  }

  @override
  Type variableType(Var variable) {
    return variable.type;
  }

  Type _getIteratedType(Type iterableType) {
    var typeStr = iterableType.type;
    if (typeStr.startsWith('List<') && typeStr.endsWith('>')) {
      return Type(typeStr.substring(5, typeStr.length - 1));
    } else {
      throw UnimplementedError('TODO(paulberry): getIteratedType($typeStr)');
    }
  }

  Type _lub(Type type1, Type type2) {
    if (isSameType(type1, type2)) {
      return type1;
    } else if (isSameType(promoteToNonNull(type1), type2)) {
      return type1;
    } else if (isSameType(promoteToNonNull(type2), type1)) {
      return type2;
    } else if (type1.type == 'Null' &&
        !isSameType(promoteToNonNull(type2), type2)) {
      // type2 is already nullable
      return type2;
    } else if (type2.type == 'Null' &&
        !isSameType(promoteToNonNull(type1), type1)) {
      // type1 is already nullable
      return type1;
    } else if (type1.type == 'Never') {
      return type2;
    } else if (type2.type == 'Never') {
      return type1;
    } else {
      throw UnimplementedError(
          'TODO(paulberry): least upper bound of $type1 and $type2');
    }
  }
}

class Label extends Node {
  final String _name;

  late final Node _binding;

  Label(this._name) : super._(location: computeLocation());

  StatementCase thenCase(StatementCase case_) {
    case_.labels.insert(0, this);
    return case_;
  }

  Statement thenStmt(Statement statement) {
    if (statement is! _LabeledStatement) {
      statement = _LabeledStatement(statement, location: computeLocation());
    }
    statement._labels.insert(0, this);
    _binding = statement;
    return statement;
  }

  @override
  String toString() => _name;
}

abstract class Literal extends Expression {
  Literal({required super.location});

  Pattern get pattern => _ConstantPattern(this, location: computeLocation());
}

/// Representation of an expression that can appear on the left hand side of an
/// assignment (or as the target of `++` or `--`).  Methods in this class may be
/// used to create more complex expressions based on this one.
abstract class LValue extends Expression {
  LValue._({required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables,
      {_LValueDisposition disposition});

  /// Creates an expression representing a write to this L-value.
  Expression write(Expression? value) =>
      new _Write(this, value, location: computeLocation());

  void _visitWrite(Harness h, Expression assignmentExpression, Type writtenType,
      Expression? rhs);
}

/// Representation of an expression or statement in the pseudo-Dart language
/// used for flow analysis testing.
class Node {
  static int _nextId = 0;

  final int id;

  final String location;

  String? _errorId;

  Node._({required this.location}) : id = _nextId++;

  String get errorId {
    String? errorId = _errorId;
    if (errorId == null) {
      fail('No error ID assigned for $runtimeType $this');
    } else {
      return errorId;
    }
  }

  set errorId(String value) {
    _errorId = value;
  }

  String toString() => 'Node#$id';
}

abstract class Pattern extends Node {
  Pattern._({required super.location}) : super._();

  void preVisit(AssignedVariables<Node, Var> assignedVariables);

  @override
  String toString() => _debugString(needsKeywordOrType: true);

  PatternDispatchResult<Node, Expression, Var, Type> visit(Harness h);

  String _debugString({required bool needsKeywordOrType});
}

/// Base class for language constructs that, at a given point in flow analysis,
/// might or might not be promoted.
abstract class Promotable {
  /// Makes the appropriate calls to [assignedVariables] for this syntactic
  /// construct.
  void preVisit(AssignedVariables<Node, Var> assignedVariables);

  /// Queries the current promotion status of `this`.  Return value is either a
  /// type (if `this` is promoted), or `null` (if it isn't).
  Type? _getPromotedType(Harness h);
}

/// Base class for l-values that, at a given point in flow analysis, might or
/// might not be promoted.
abstract class PromotableLValue extends LValue implements Promotable {
  PromotableLValue._({required super.location}) : super._();
}

/// Representation of a statement in the pseudo-Dart language used for flow
/// analysis testing.
abstract class Statement extends Node {
  Statement({required super.location}) : super._();

  /// Wraps `this` in such a way that, when the test is run, it will verify that
  /// the IR produced matches [expectedIr].
  Statement checkIr(String expectedIr) =>
      _CheckStatementIr(this, expectedIr, location: computeLocation());

  Statement expectErrors(Set<String> expectedErrors) =>
      _ExpectStatementErrors(this, expectedErrors, location: computeLocation());

  void preVisit(AssignedVariables<Node, Var> assignedVariables);

  /// If `this` is a statement `x`, creates a pseudo-expression that models
  /// execution of `x` followed by evaluation of [expr].  This can be used to
  /// test that flow analysis is in the correct state before an expression is
  /// visited.
  Expression thenExpr(Expression expr) =>
      _WrappedExpression(this, expr, null, location: computeLocation());

  void visit(Harness h);
}

/// Representation of a single case clause in a switch statement.  Use [case_]
/// to create instances of this class.
class StatementCase extends Node
    implements StatementCaseInfo<Statement, Expression, Node> {
  @override
  final List<Label> labels = [];

  @override
  final Pattern? pattern;

  @override
  final Expression? when;

  final _Block _statements;

  StatementCase._(this.pattern, this.when, this._statements,
      {required super.location})
      : super._();

  @override
  List<Statement> get body => _statements.statements;

  @override
  Node get node => this;

  String toString() => [
        for (var label in labels) '$label:',
        pattern == null ? 'default:' : 'case $pattern:',
        ...body
      ].join(' ');

  void _preVisit(AssignedVariables<Node, Var> assignedVariables) {
    pattern?.preVisit(assignedVariables);
    _Block(body, location: location).preVisit(assignedVariables);
  }
}

abstract class TryBuilder {
  TryStatement catch_(
      {Var? exception, Var? stackTrace, required List<Statement> body});

  Statement finally_(List<Statement> statements);
}

abstract class TryStatement extends Statement implements TryBuilder {
  TryStatement._({required super.location});
}

/// Representation of a local variable in the pseudo-Dart language used for flow
/// analysis testing.
class Var extends Node implements Promotable {
  final String name;

  /// The type of the variable, or `null` if it is not yet known.
  Type? _type;

  Var(this.name) : super._(location: computeLocation());

  /// Creates an L-value representing a reference to this variable.
  LValue get expr =>
      new _VariableReference(this, null, location: computeLocation());

  /// Gets the type if known; otherwise throws an exception.
  Type get type {
    if (_type == null) {
      throw 'Type not yet known';
    } else {
      return _type!;
    }
  }

  set type(Type value) {
    if (_type != null) {
      throw 'Type already set';
    }
    _type = value;
  }

  Pattern pattern({String? type, String? expectInferredType}) =>
      new _VariablePattern(
          type == null ? null : Type(type), this, expectInferredType,
          location: computeLocation());

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {}

  /// Creates an expression representing a read of this variable, which as a
  /// side effect will call the given callback with the returned promoted type.
  Expression readAndCheckPromotedType(void Function(Type?) callback) =>
      new _VariableReference(this, callback, location: computeLocation());

  @override
  String toString() => 'var $name';

  /// Creates an expression representing a write to this variable.
  Expression write(Expression? value) {
    var location = computeLocation();
    return new _Write(
        new _VariableReference(this, null, location: location), value,
        location: location);
  }

  @override
  Type? _getPromotedType(Harness h) {
    h.irBuilder.atom(name, Kind.expression, location: location);
    return h.flow.promotedType(this);
  }
}

class _As extends Expression {
  final Expression target;
  final Type type;

  _As(this.target, this.type, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    target.preVisit(assignedVariables);
  }

  @override
  String toString() => '$target as $type';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    return h.typeAnalyzer.analyzeTypeCast(this, target, type);
  }
}

class _Assert extends Statement {
  final Expression condition;
  final Expression? message;

  _Assert(this.condition, this.message, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    condition.preVisit(assignedVariables);
    message?.preVisit(assignedVariables);
  }

  @override
  String toString() =>
      'assert($condition${message == null ? '' : ', $message'});';

  @override
  void visit(Harness h) {
    h.typeAnalyzer.analyzeAssertStatement(this, condition, message);
    h.irBuilder.apply(
        'assert', [Kind.expression, Kind.expression], Kind.statement,
        location: location);
  }
}

class _Block extends Statement {
  final List<Statement> statements;

  _Block(this.statements, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    for (var statement in statements) {
      statement.preVisit(assignedVariables);
    }
  }

  @override
  String toString() =>
      statements.isEmpty ? '{}' : '{ ${statements.join(' ')} }';

  @override
  void visit(Harness h) {
    h.typeAnalyzer.analyzeBlock(statements);
    h.irBuilder.apply(
        'block', List.filled(statements.length, Kind.statement), Kind.statement,
        location: location);
  }
}

class _BooleanLiteral extends Literal {
  final bool value;

  _BooleanLiteral(this.value, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {}

  @override
  String toString() => '$value';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    var type = h.typeAnalyzer.analyzeBoolLiteral(this, value);
    h.irBuilder.atom('$value', Kind.expression, location: location);
    return new SimpleTypeAnalysisResult<Type>(type: type);
  }
}

class _Break extends Statement {
  final Label? target;

  _Break(this.target, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {}

  @override
  String toString() => 'break;';

  @override
  void visit(Harness h) {
    h.typeAnalyzer.analyzeBreakStatement(target?._binding as Statement?);
    h.irBuilder.apply('break', [], Kind.statement, location: location);
  }
}

/// Representation of a single catch clause in a try/catch statement.  Use
/// [catch_] to create instances of this class.
class _CatchClause {
  final Statement _body;
  final Var? _exception;
  final Var? _stackTrace;

  _CatchClause(this._body, this._exception, this._stackTrace);

  String toString() {
    String initialPart;
    if (_stackTrace != null) {
      initialPart = 'catch (${_exception!.name}, ${_stackTrace!.name})';
    } else if (_exception != null) {
      initialPart = 'catch (${_exception!.name})';
    } else {
      initialPart = 'on ...';
    }
    return '$initialPart $_body';
  }

  void _preVisit(AssignedVariables<Node, Var> assignedVariables) {
    _body.preVisit(assignedVariables);
  }
}

class _CheckAssigned extends Statement {
  final Var variable;
  final bool expectedAssignedState;

  _CheckAssigned(this.variable, this.expectedAssignedState,
      {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {}

  @override
  String toString() {
    var verb = expectedAssignedState ? 'is' : 'is not';
    return 'check $variable $verb definitely assigned;';
  }

  @override
  void visit(Harness h) {
    expect(h.flow.isAssigned(variable), expectedAssignedState);
    h.irBuilder.atom('null', Kind.statement, location: location);
  }
}

class _CheckExpressionContext extends Expression {
  final Expression inner;

  final String expectedContext;

  _CheckExpressionContext(this.inner, this.expectedContext,
      {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    inner.preVisit(assignedVariables);
  }

  @override
  String toString() => '$inner (should be in context $expectedContext)';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    expect(context.type, expectedContext);
    var result =
        h.typeAnalyzer.analyzeParenthesizedExpression(this, inner, context);
    return result;
  }
}

class _CheckExpressionIr extends Expression {
  final Expression inner;

  final String expectedIr;

  _CheckExpressionIr(this.inner, this.expectedIr, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    inner.preVisit(assignedVariables);
  }

  @override
  String toString() => '$inner (should produce IR $expectedIr)';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    var result =
        h.typeAnalyzer.analyzeParenthesizedExpression(this, inner, context);
    h.irBuilder.check(expectedIr, Kind.expression, location: location);
    return result;
  }
}

class _CheckExpressionType extends Expression {
  final Expression target;
  final String expectedType;

  _CheckExpressionType(this.target, this.expectedType,
      {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    target.preVisit(assignedVariables);
  }

  @override
  String toString() => '$target (expected type: $expectedType)';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    var result =
        h.typeAnalyzer.analyzeParenthesizedExpression(this, target, context);
    expect(result.type.type, expectedType, reason: 'at $location');
    return result;
  }
}

class _CheckPromoted extends Statement {
  final Promotable promotable;
  final String? expectedTypeStr;

  _CheckPromoted(this.promotable, this.expectedTypeStr,
      {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    promotable.preVisit(assignedVariables);
  }

  @override
  String toString() {
    var predicate = expectedTypeStr == null
        ? 'not promoted'
        : 'promoted to $expectedTypeStr';
    return 'check $promotable $predicate;';
  }

  @override
  void visit(Harness h) {
    var promotedType = promotable._getPromotedType(h);
    expect(promotedType?.type, expectedTypeStr, reason: 'at $location');
    h.irBuilder
        .apply('stmt', [Kind.expression], Kind.statement, location: location);
  }
}

class _CheckReachable extends Statement {
  final bool expectedReachable;

  _CheckReachable(this.expectedReachable, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {}

  @override
  String toString() => 'check reachable;';

  @override
  void visit(Harness h) {
    expect(h.flow.isReachable, expectedReachable, reason: 'at $location');
    h.irBuilder.atom('null', Kind.statement, location: location);
  }
}

class _CheckStatementIr extends Statement {
  final Statement inner;

  final String expectedIr;

  _CheckStatementIr(this.inner, this.expectedIr, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    inner.preVisit(assignedVariables);
  }

  @override
  String toString() => '$inner (should produce IR $expectedIr)';

  @override
  void visit(Harness h) {
    h.typeAnalyzer.dispatchStatement(inner);
    h.irBuilder.check(expectedIr, Kind.statement, location: location);
  }
}

class _CheckUnassigned extends Statement {
  final Var variable;
  final bool expectedUnassignedState;

  _CheckUnassigned(this.variable, this.expectedUnassignedState,
      {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {}

  @override
  String toString() {
    var verb = expectedUnassignedState ? 'is' : 'is not';
    return 'check $variable $verb definitely unassigned;';
  }

  @override
  void visit(Harness h) {
    expect(h.flow.isUnassigned(variable), expectedUnassignedState,
        reason: 'at $location');
    h.irBuilder.atom('null', Kind.statement, location: location);
  }
}

class _Conditional extends Expression {
  final Expression condition;
  final Expression ifTrue;
  final Expression ifFalse;

  _Conditional(this.condition, this.ifTrue, this.ifFalse,
      {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    condition.preVisit(assignedVariables);
    assignedVariables.beginNode();
    ifTrue.preVisit(assignedVariables);
    assignedVariables.endNode(this);
    ifFalse.preVisit(assignedVariables);
  }

  @override
  String toString() => '$condition ? $ifTrue : $ifFalse';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    var result = h.typeAnalyzer
        .analyzeConditionalExpression(this, condition, ifTrue, ifFalse);
    h.irBuilder.apply('if', [Kind.expression, Kind.expression, Kind.expression],
        Kind.expression,
        location: location);
    return result;
  }
}

class _ConstantPattern extends Pattern {
  final Expression constant;

  _ConstantPattern(this.constant, {required super.location}) : super._();

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    constant.preVisit(assignedVariables);
  }

  @override
  PatternDispatchResult<Node, Expression, Var, Type> visit(Harness h) =>
      h.typeAnalyzer.analyzeConstOrLiteralPattern(this, constant);

  @override
  _debugString({required bool needsKeywordOrType}) => constant.toString();
}

class _Continue extends Statement {
  _Continue({required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {}

  @override
  String toString() => 'continue;';

  @override
  void visit(Harness h) {
    h.typeAnalyzer.analyzeContinueStatement();
    h.irBuilder.apply('continue', [], Kind.statement, location: location);
  }
}

class _Declare extends Statement {
  final bool isLate;
  final bool isFinal;
  final Pattern pattern;
  final Expression? initializer;

  _Declare(this.pattern, this.initializer,
      {required this.isLate, required this.isFinal, required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    pattern.preVisit(assignedVariables);
    if (isLate) {
      assignedVariables.beginNode();
    }
    initializer?.preVisit(assignedVariables);
    if (isLate) {
      assignedVariables.endNode(this);
    }
  }

  @override
  String toString() {
    var parts = <String>[
      if (isLate) 'late',
      if (isFinal) 'final',
      pattern._debugString(needsKeywordOrType: !isFinal),
      if (initializer != null) '= $initializer'
    ];
    return '${parts.join(' ')};';
  }

  @override
  void visit(Harness h) {
    String irName;
    List<Kind> argKinds;
    var initializer = this.initializer;
    if (initializer == null) {
      var pattern = this.pattern as _VariablePattern;
      var staticType = h.typeAnalyzer.analyzeUninitializedVariableDeclaration(
          this, pattern.variable, pattern.declaredType,
          isFinal: isFinal, isLate: isLate);
      h.typeAnalyzer.handleVariablePattern(pattern,
          matchedType: staticType, staticType: staticType);
      irName = 'declare';
      argKinds = [Kind.pattern];
    } else {
      h.typeAnalyzer.analyzeInitializedVariableDeclaration(
          this, pattern, initializer,
          isFinal: isFinal, isLate: isLate);
      irName = 'match';
      argKinds = [Kind.expression, Kind.pattern];
    }
    h.irBuilder.apply(
        [irName, if (isLate) 'late', if (isFinal) 'final'].join('_'),
        argKinds,
        Kind.statement,
        location: location);
  }
}

class _Do extends Statement {
  final Statement body;
  final Expression condition;

  _Do(this.body, this.condition, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    assignedVariables.beginNode();
    body.preVisit(assignedVariables);
    condition.preVisit(assignedVariables);
    assignedVariables.endNode(this);
  }

  @override
  String toString() => 'do $body while ($condition);';

  @override
  void visit(Harness h) {
    h.typeAnalyzer.analyzeDoLoop(this, body, condition);
    h.irBuilder.apply('do', [Kind.statement, Kind.expression], Kind.statement,
        location: location);
  }
}

class _Equal extends Expression {
  final Expression lhs;
  final Expression rhs;
  final bool isInverted;

  _Equal(this.lhs, this.rhs, this.isInverted, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    lhs.preVisit(assignedVariables);
    rhs.preVisit(assignedVariables);
  }

  @override
  String toString() => '$lhs ${isInverted ? '!=' : '=='} $rhs';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    var operatorName = isInverted ? '!=' : '==';
    var result =
        h.typeAnalyzer.analyzeBinaryExpression(this, lhs, operatorName, rhs);
    h.irBuilder.apply(
        operatorName, [Kind.expression, Kind.expression], Kind.expression,
        location: location);
    return result;
  }
}

class _ExpectStatementErrors extends Statement {
  final Statement _statement;

  final Set<String> _expectedErrors;

  _ExpectStatementErrors(this._statement, this._expectedErrors,
      {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    _statement.preVisit(assignedVariables);
  }

  @override
  void visit(Harness h) {
    var previousErrors = h.typeAnalyzer.errors;
    h.typeAnalyzer.errors = _MiniAstErrors();
    h.typeAnalyzer.dispatchStatement(_statement);
    expect(h.typeAnalyzer.errors._accumulatedErrors, _expectedErrors);
    h.typeAnalyzer.errors = previousErrors;
  }
}

class _ExpressionInContext extends Statement {
  final Expression expr;

  final Type context;

  _ExpressionInContext(this.expr, this.context, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    expr.preVisit(assignedVariables);
  }

  @override
  String toString() => '$expr (in context $context);';

  @override
  void visit(Harness h) {
    h.typeAnalyzer.analyzeExpression(expr, context);
    h.irBuilder
        .apply('stmt', [Kind.expression], Kind.statement, location: location);
  }
}

class _ExpressionStatement extends Statement {
  final Expression expr;

  _ExpressionStatement(this.expr, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    expr.preVisit(assignedVariables);
  }

  @override
  String toString() => '$expr;';

  @override
  void visit(Harness h) {
    h.typeAnalyzer.analyzeExpressionStatement(expr);
    h.irBuilder
        .apply('stmt', [Kind.expression], Kind.statement, location: location);
  }
}

class _For extends Statement {
  final Statement? initializer;
  final Expression? condition;
  final Expression? updater;
  final Statement body;
  final bool forCollection;

  _For(this.initializer, this.condition, this.updater, this.body,
      this.forCollection,
      {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    initializer?.preVisit(assignedVariables);
    assignedVariables.beginNode();
    condition?.preVisit(assignedVariables);
    body.preVisit(assignedVariables);
    updater?.preVisit(assignedVariables);
    assignedVariables.endNode(this);
  }

  @override
  String toString() {
    var buffer = StringBuffer('for (');
    if (initializer == null) {
      buffer.write(';');
    } else {
      buffer.write(initializer);
    }
    if (condition == null) {
      buffer.write(';');
    } else {
      buffer.write(' $condition;');
    }
    if (updater != null) {
      buffer.write(' $updater');
    }
    buffer.write(') $body');
    return buffer.toString();
  }

  @override
  void visit(Harness h) {
    if (initializer != null) {
      h.typeAnalyzer.dispatchStatement(initializer!);
    } else {
      h.typeAnalyzer.handleNoInitializer(this);
    }
    h.flow.for_conditionBegin(this);
    if (condition != null) {
      h.typeAnalyzer.analyzeExpression(condition!);
    } else {
      h.typeAnalyzer.handleNoCondition(this);
    }
    h.flow.for_bodyBegin(forCollection ? null : this, condition);
    h.typeAnalyzer._visitLoopBody(this, body);
    h.flow.for_updaterBegin();
    if (updater != null) {
      h.typeAnalyzer.analyzeExpression(updater!);
    } else {
      h.typeAnalyzer.handleNoCondition(this);
    }
    h.flow.for_end();
    h.irBuilder.apply(
        'for',
        [Kind.statement, Kind.expression, Kind.statement, Kind.expression],
        Kind.statement,
        location: location);
  }
}

class _ForEach extends Statement {
  final Var? variable;
  final Expression iterable;
  final Statement body;
  final bool declaresVariable;

  _ForEach(this.variable, this.iterable, this.body, this.declaresVariable,
      {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    iterable.preVisit(assignedVariables);
    if (variable != null) {
      if (declaresVariable) {
        assignedVariables.declare(variable!);
      } else {
        assignedVariables.write(variable!);
      }
    }
    assignedVariables.beginNode();
    body.preVisit(assignedVariables);
    assignedVariables.endNode(this);
  }

  @override
  String toString() {
    String declarationPart;
    if (variable == null) {
      declarationPart = '<identifier>';
    } else if (declaresVariable) {
      declarationPart = variable.toString();
    } else {
      declarationPart = variable!.name;
    }
    return 'for ($declarationPart in $iterable) $body';
  }

  @override
  void visit(Harness h) {
    var iteratedType =
        h._getIteratedType(h.typeAnalyzer.analyzeExpression(iterable));
    h.flow.forEach_bodyBegin(this);
    var variable = this.variable;
    if (variable != null && !declaresVariable) {
      h.flow.write(this, variable, iteratedType, null);
    }
    h.typeAnalyzer._visitLoopBody(this, body);
    h.flow.forEach_end();
    h.irBuilder.apply(
        'forEach', [Kind.expression, Kind.statement], Kind.statement,
        location: location);
  }
}

class _If extends Statement {
  final Expression condition;
  final Statement ifTrue;
  final Statement? ifFalse;

  _If(this.condition, this.ifTrue, this.ifFalse, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    condition.preVisit(assignedVariables);
    assignedVariables.beginNode();
    ifTrue.preVisit(assignedVariables);
    assignedVariables.endNode(this);
    ifFalse?.preVisit(assignedVariables);
  }

  @override
  String toString() =>
      'if ($condition) $ifTrue' + (ifFalse == null ? '' : 'else $ifFalse');

  @override
  void visit(Harness h) {
    h.typeAnalyzer.analyzeIfStatement(this, condition, ifTrue, ifFalse);
    h.irBuilder.apply(
        'if', [Kind.expression, Kind.statement, Kind.statement], Kind.statement,
        location: location);
  }
}

class _IfNull extends Expression {
  final Expression lhs;
  final Expression rhs;

  _IfNull(this.lhs, this.rhs, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    lhs.preVisit(assignedVariables);
    rhs.preVisit(assignedVariables);
  }

  @override
  String toString() => '$lhs ?? $rhs';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    var result = h.typeAnalyzer.analyzeIfNullExpression(this, lhs, rhs);
    h.irBuilder.apply(
        'ifNull', [Kind.expression, Kind.expression], Kind.expression,
        location: location);
    return result;
  }
}

class _IntLiteral extends Literal {
  final int value;

  /// `true` or `false` if we should assert that int->double conversion either
  /// does, or does not, happen.  `null` if no assertion should be done.
  final bool? expectConversionToDouble;

  _IntLiteral(this.value,
      {this.expectConversionToDouble, required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {}

  @override
  String toString() => '$value';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    var result = h.typeAnalyzer.analyzeIntLiteral(context);
    if (expectConversionToDouble != null) {
      expect(result.convertedToDouble, expectConversionToDouble);
    }
    h.irBuilder.atom(
        result.convertedToDouble ? '${value.toDouble()}f' : '$value',
        Kind.expression,
        location: location);
    return result;
  }
}

class _Is extends Expression {
  final Expression target;
  final Type type;
  final bool isInverted;

  _Is(this.target, this.type, this.isInverted, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    target.preVisit(assignedVariables);
  }

  @override
  String toString() => '$target is${isInverted ? '!' : ''} $type';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    return h.typeAnalyzer
        .analyzeTypeTest(this, target, type, isInverted: isInverted);
  }
}

class _LabeledStatement extends Statement {
  final List<Label> _labels = [];

  final Statement _body;

  _LabeledStatement(this._body, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    _body.preVisit(assignedVariables);
  }

  @override
  String toString() => [..._labels, _body].join(': ');

  @override
  void visit(Harness h) {
    h.typeAnalyzer.analyzeLabeledStatement(this, _body);
  }
}

class _LocalFunction extends Statement {
  final Statement body;

  _LocalFunction(this.body, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    assignedVariables.beginNode();
    body.preVisit(assignedVariables);
    assignedVariables.endNode(this, isClosureOrLateVariableInitializer: true);
  }

  @override
  String toString() => '() $body';

  @override
  void visit(Harness h) {
    h.flow.functionExpression_begin(this);
    h.typeAnalyzer.dispatchStatement(body);
    h.flow.functionExpression_end();
  }
}

class _Logical extends Expression {
  final Expression lhs;
  final Expression rhs;
  final bool isAnd;

  _Logical(this.lhs, this.rhs, {required this.isAnd, required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    lhs.preVisit(assignedVariables);
    assignedVariables.beginNode();
    rhs.preVisit(assignedVariables);
    assignedVariables.endNode(this);
  }

  @override
  String toString() => '$lhs ${isAnd ? '&&' : '||'} $rhs';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    var operatorName = isAnd ? '&&' : '||';
    var result =
        h.typeAnalyzer.analyzeBinaryExpression(this, lhs, operatorName, rhs);
    h.irBuilder.apply(
        operatorName, [Kind.expression, Kind.expression], Kind.expression,
        location: location);
    return result;
  }
}

/// Enum representing the different ways an [LValue] might be used.
enum _LValueDisposition {
  /// The [LValue] is being read from only, not written to.  This happens if it
  /// appears in a place where an ordinary expression is expected.
  read,

  /// The [LValue] is being written to only, not read from.  This happens if it
  /// appears on the left hand side of `=`.
  write,

  /// The [LValue] is being both read from and written to.  This happens if it
  /// appears on the left and side of `op=` (where `op` is some operator), or as
  /// the target of `++` or `--`.
  readWrite,
}

class _MiniAstErrors implements TypeAnalyzerErrors<Node, Var, Type> {
  final Set<String> _accumulatedErrors = {};

  /// If [assertInErrorRecovery] is called prior to any errors being reported,
  /// the stack trace is captured and stored in this variable, so that if no
  /// errors are reported by the end of running the test, we can use it to
  /// highlight the point of failure.
  StackTrace? _assertInErrorRecoveryStack;

  @override
  void assertInErrorRecovery() {
    if (_accumulatedErrors.isEmpty) {
      _assertInErrorRecoveryStack ??= StackTrace.current;
    }
  }

  @override
  void inconsistentMatchVar(
      {required Node pattern,
      required Type type,
      required Node previousPattern,
      required Type previousType}) {
    _recordError(
        'inconsistentMatchVar(pattern: ${pattern.errorId}, type: ${type.type}, '
        'previousPattern: ${previousPattern.errorId}, '
        'previousType: ${previousType.type})');
  }

  @override
  void inconsistentMatchVarExplicitness(
      {required Node pattern, required Node previousPattern}) {
    _recordError(
        'inconsistentMatchVarExplicitness(pattern: ${pattern.errorId}, '
        'previousPattern: ${previousPattern.errorId})');
  }

  @override
  void matchVarOverlap({required Node pattern, required Node previousPattern}) {
    _recordError('matchVarOverlap(pattern: ${pattern.errorId}, '
        'previousPattern: ${previousPattern.errorId})');
  }

  @override
  void missingMatchVar(Node alternative, Var variable) {
    _recordError('missingMatchVar(${alternative.errorId}, ${variable.name})');
  }

  @override
  void patternDoesNotAllowLate(Node pattern) {
    _recordError('patternDoesNotAllowLate(${pattern.errorId})');
  }

  @override
  void refutablePatternInIrrefutableContext(Node pattern, Node context) {
    _recordError('refutablePatternInIrrefutableContext(${pattern.errorId}, '
        '${context.errorId})');
  }

  void _recordError(String errorText) {
    _assertInErrorRecoveryStack = null;
    if (!_accumulatedErrors.add(errorText)) {
      fail('Same error reported twice: $errorText');
    }
  }
}

class _MiniAstTypeAnalyzer
    with TypeAnalyzer<Node, Statement, Expression, Var, Type> {
  final Harness _harness;

  @override
  late _MiniAstErrors errors = _MiniAstErrors();

  Statement? _currentBreakTarget;

  Statement? _currentContinueTarget;

  final _irBuilder = MiniIrBuilder();

  @override
  late final Type boolType = Type('bool');

  @override
  late final Type doubleType = Type('double');

  @override
  late final Type dynamicType = Type('dynamic');

  @override
  late final Type intType = Type('int');

  late final Type neverType = Type('Never');

  late final Type nullType = Type('Null');

  @override
  late final Type unknownType = Type('?');

  _MiniAstTypeAnalyzer(this._harness);

  @override
  FlowAnalysis<Node, Statement, Expression, Var, Type> get flow =>
      _harness.flow;

  Type get thisType => _harness._thisType!;

  @override
  TypeOperations2<Type> get typeOperations => _harness;

  void analyzeAssertStatement(
      Statement node, Expression condition, Expression? message) {
    flow.assert_begin();
    analyzeExpression(condition);
    flow.assert_afterCondition(condition);
    if (message != null) {
      analyzeExpression(message);
    } else {
      handleNoMessage(node);
    }
    flow.assert_end();
  }

  SimpleTypeAnalysisResult<Type> analyzeBinaryExpression(
      Expression node, Expression lhs, String operatorName, Expression rhs) {
    bool isEquals = false;
    bool isNot = false;
    bool isLogical = false;
    bool isAnd = false;
    switch (operatorName) {
      case '==':
        isEquals = true;
        break;
      case '!=':
        isEquals = true;
        isNot = true;
        operatorName = '==';
        break;
      case '&&':
        isLogical = true;
        isAnd = true;
        break;
      case '||':
        isLogical = true;
        break;
    }
    if (operatorName == '==') {
      isEquals = true;
    } else if (operatorName == '!=') {
      isEquals = true;
      isNot = true;
      operatorName = '==';
    }
    if (isLogical) {
      flow.logicalBinaryOp_begin();
    }
    var leftType = analyzeExpression(lhs);
    EqualityInfo<Type>? leftInfo;
    if (isEquals) {
      leftInfo = flow.equalityOperand_end(lhs, leftType);
    } else if (isLogical) {
      flow.logicalBinaryOp_rightBegin(lhs, node, isAnd: isAnd);
    }
    var rightType = analyzeExpression(rhs);
    if (isEquals) {
      flow.equalityOperation_end(
          node, leftInfo, flow.equalityOperand_end(rhs, rightType),
          notEqual: isNot);
    } else if (isLogical) {
      flow.logicalBinaryOp_end(node, rhs, isAnd: isAnd);
    }
    return new SimpleTypeAnalysisResult<Type>(type: boolType);
  }

  void analyzeBlock(Iterable<Statement> statements) {
    for (var statement in statements) {
      dispatchStatement(statement);
    }
  }

  Type analyzeBoolLiteral(Expression node, bool value) {
    flow.booleanLiteral(node, value);
    return boolType;
  }

  void analyzeBreakStatement(Statement? target) {
    flow.handleBreak(target ?? _currentBreakTarget!);
  }

  SimpleTypeAnalysisResult<Type> analyzeConditionalExpression(Expression node,
      Expression condition, Expression ifTrue, Expression ifFalse) {
    flow.conditional_conditionBegin();
    analyzeExpression(condition);
    flow.conditional_thenBegin(condition, node);
    var ifTrueType = analyzeExpression(ifTrue);
    flow.conditional_elseBegin(ifTrue);
    var ifFalseType = analyzeExpression(ifFalse);
    flow.conditional_end(node, ifFalse);
    return new SimpleTypeAnalysisResult<Type>(
        type: leastUpperBound(ifTrueType, ifFalseType));
  }

  void analyzeContinueStatement() {
    flow.handleContinue(_currentContinueTarget!);
  }

  void analyzeDoLoop(Statement node, Statement body, Expression condition) {
    flow.doStatement_bodyBegin(node);
    _visitLoopBody(node, body);
    flow.doStatement_conditionBegin();
    analyzeExpression(condition);
    flow.doStatement_end(condition);
  }

  @override
  Type analyzeExpression(Expression expression, [Type? context]) {
    // TODO(paulberry): make the [context] argument required.
    context ??= unknownType;
    return super.analyzeExpression(expression, context);
  }

  void analyzeExpressionStatement(Expression expression) {
    analyzeExpression(expression);
  }

  SimpleTypeAnalysisResult<Type> analyzeIfNullExpression(
      Expression node, Expression lhs, Expression rhs) {
    var leftType = analyzeExpression(lhs);
    flow.ifNullExpression_rightBegin(lhs, leftType);
    var rightType = analyzeExpression(rhs);
    flow.ifNullExpression_end();
    return new SimpleTypeAnalysisResult<Type>(
        type: leastUpperBound(
            flow.operations.promoteToNonNull(leftType), rightType));
  }

  void analyzeIfStatement(Statement node, Expression condition,
      Statement ifTrue, Statement? ifFalse) {
    flow.ifStatement_conditionBegin();
    analyzeExpression(condition);
    flow.ifStatement_thenBegin(condition, node);
    dispatchStatement(ifTrue);
    if (ifFalse == null) {
      handleNoStatement(node);
      flow.ifStatement_end(false);
    } else {
      flow.ifStatement_elseBegin();
      dispatchStatement(ifFalse);
      flow.ifStatement_end(true);
    }
  }

  void analyzeLabeledStatement(Statement node, Statement body) {
    flow.labeledStatement_begin(node);
    dispatchStatement(body);
    flow.labeledStatement_end();
  }

  SimpleTypeAnalysisResult<Type> analyzeLogicalNot(
      Expression node, Expression expression) {
    analyzeExpression(expression);
    flow.logicalNot_end(node, expression);
    return new SimpleTypeAnalysisResult<Type>(type: boolType);
  }

  SimpleTypeAnalysisResult<Type> analyzeNonNullAssert(
      Expression node, Expression expression) {
    var type = analyzeExpression(expression);
    flow.nonNullAssert_end(expression);
    return new SimpleTypeAnalysisResult<Type>(
        type: flow.operations.promoteToNonNull(type));
  }

  SimpleTypeAnalysisResult<Type> analyzeNullLiteral(Expression node) {
    flow.nullLiteral(node);
    return new SimpleTypeAnalysisResult<Type>(type: nullType);
  }

  SimpleTypeAnalysisResult<Type> analyzeParenthesizedExpression(
      Expression node, Expression expression, Type context) {
    var type = analyzeExpression(expression, context);
    flow.parenthesizedExpression(node, expression);
    return new SimpleTypeAnalysisResult<Type>(type: type);
  }

  ExpressionTypeAnalysisResult<Type> analyzePropertyGet(
      Expression node, Expression receiver, String propertyName) {
    var receiverType = analyzeExpression(receiver);
    var member = _lookupMember(node, receiverType, propertyName);
    var promotedType =
        flow.propertyGet(node, receiver, propertyName, member, member._type);
    // TODO(paulberry): handle null shorting
    return new SimpleTypeAnalysisResult<Type>(
        type: promotedType ?? member._type);
  }

  void analyzeReturnStatement() {
    flow.handleExit();
  }

  SimpleTypeAnalysisResult<Type> analyzeThis(Expression node) {
    var thisType = this.thisType;
    flow.thisOrSuper(node, thisType);
    return new SimpleTypeAnalysisResult<Type>(type: thisType);
  }

  SimpleTypeAnalysisResult<Type> analyzeThisPropertyGet(
      Expression node, String propertyName) {
    var member = _lookupMember(node, thisType, propertyName);
    var promotedType =
        flow.thisOrSuperPropertyGet(node, propertyName, member, member._type);
    return new SimpleTypeAnalysisResult<Type>(
        type: promotedType ?? member._type);
  }

  SimpleTypeAnalysisResult<Type> analyzeThrow(
      Expression node, Expression expression) {
    analyzeExpression(expression);
    flow.handleExit();
    return new SimpleTypeAnalysisResult<Type>(type: neverType);
  }

  void analyzeTryStatement(Statement node, Statement body,
      Iterable<_CatchClause> catchClauses, Statement? finallyBlock) {
    if (finallyBlock != null) {
      flow.tryFinallyStatement_bodyBegin();
    }
    if (catchClauses.isNotEmpty) {
      flow.tryCatchStatement_bodyBegin();
    }
    dispatchStatement(body);
    if (catchClauses.isNotEmpty) {
      flow.tryCatchStatement_bodyEnd(body);
      for (var catch_ in catchClauses) {
        flow.tryCatchStatement_catchBegin(
            catch_._exception, catch_._stackTrace);
        dispatchStatement(catch_._body);
        flow.tryCatchStatement_catchEnd();
      }
      flow.tryCatchStatement_end();
    }
    if (finallyBlock != null) {
      flow.tryFinallyStatement_finallyBegin(
          catchClauses.isNotEmpty ? node : body);
      dispatchStatement(finallyBlock);
      flow.tryFinallyStatement_end();
    } else {
      handleNoStatement(node);
    }
  }

  SimpleTypeAnalysisResult<Type> analyzeTypeCast(
      Expression node, Expression expression, Type type) {
    analyzeExpression(expression);
    flow.asExpression_end(expression, type);
    return new SimpleTypeAnalysisResult<Type>(type: type);
  }

  SimpleTypeAnalysisResult<Type> analyzeTypeTest(
      Expression node, Expression expression, Type type,
      {bool isInverted = false}) {
    analyzeExpression(expression);
    flow.isExpression_end(node, expression, isInverted, type);
    return new SimpleTypeAnalysisResult<Type>(type: boolType);
  }

  SimpleTypeAnalysisResult<Type> analyzeVariableGet(
      Expression node, Var variable, void Function(Type?)? callback) {
    var promotedType = flow.variableRead(node, variable);
    callback?.call(promotedType);
    return new SimpleTypeAnalysisResult<Type>(
        type: promotedType ?? variable.type);
  }

  void analyzeWhileLoop(Statement node, Expression condition, Statement body) {
    flow.whileStatement_conditionBegin(node);
    analyzeExpression(condition);
    flow.whileStatement_bodyBegin(node, condition);
    _visitLoopBody(node, body);
    flow.whileStatement_end();
  }

  @override
  ExpressionTypeAnalysisResult<Type> dispatchExpression(
          Expression expression, Type context) =>
      _irBuilder.guard(expression, () => expression.visit(_harness, context));

  @override
  PatternDispatchResult<Node, Expression, Var, Type> dispatchPattern(
      covariant Pattern node) {
    return node.visit(_harness);
  }

  @override
  void dispatchStatement(Statement statement) =>
      _irBuilder.guard(statement, () => statement.visit(_harness));

  void finish() {
    flow.finish();
  }

  @override
  void finishExpressionCase(Expression node, int caseIndex) {
    _irBuilder.apply(
        'case', [Kind.caseHead, Kind.expression], Kind.expressionCase,
        location: node.location);
  }

  @override
  void finishStatementCase(Statement node, int caseIndex, int numStatements) {
    _irBuilder.apply(
        'block', List.filled(numStatements, Kind.statement), Kind.statement,
        location: node.location);
    _irBuilder.apply(
        'case', [Kind.caseHeads, Kind.statement], Kind.statementCase,
        location: node.location);
  }

  @override
  void handleCase_afterCaseHeads(
      Statement node, int caseIndex, List<Node> labels, int numHeads) {
    for (var label in labels) {
      _irBuilder.atom((label as Label)._name, Kind.caseHead,
          location: node.location);
    }
    _irBuilder.apply('heads',
        List.filled(numHeads + labels.length, Kind.caseHead), Kind.caseHeads,
        location: node.location);
  }

  @override
  void handleCaseHead(Node node, int caseIndex, {required bool hasWhen}) {
    _irBuilder.apply(
        'head',
        hasWhen ? [Kind.pattern, Kind.expression] : [Kind.pattern],
        Kind.caseHead,
        location: node.location);
  }

  @override
  void handleConstOrLiteralPattern(Node node, {required Type matchedType}) {
    _irBuilder.atom(matchedType.type, Kind.type, location: node.location);
    _irBuilder.apply('const', [Kind.expression, Kind.type], Kind.pattern,
        names: ['matchedType'], location: node.location);
  }

  @override
  void handleDefault(Node node, int caseIndex) {
    _irBuilder.atom('default', Kind.caseHead, location: node.location);
  }

  void handleNoCondition(Node node) {
    _irBuilder.atom('true', Kind.expression, location: node.location);
  }

  void handleNoInitializer(Node node) {
    _irBuilder.atom('uninitialized', Kind.statement, location: node.location);
  }

  void handleNoMessage(Node node) {
    _irBuilder.atom('failure', Kind.expression, location: node.location);
  }

  void handleNoStatement(Node node) {
    _irBuilder.atom('noop', Kind.statement, location: node.location);
  }

  @override
  void handleVariablePattern(covariant _VariablePattern node,
      {required Type matchedType, Type? staticType}) {
    _irBuilder.atom(node.variable.name, Kind.variable, location: node.location);
    _irBuilder.atom(matchedType.type, Kind.type, location: node.location);
    if (staticType == null) {
      _irBuilder.apply('varPattern', [Kind.variable, Kind.type], Kind.pattern,
          names: ['matchedType'], location: node.location);
    } else {
      _irBuilder.atom(staticType.type, Kind.type, location: node.location);
      _irBuilder.apply(
          'varPattern', [Kind.variable, Kind.type, Kind.type], Kind.pattern,
          names: ['matchedType', 'staticType'], location: node.location);
    }
    var expectInferredType = node.expectInferredType;
    if (expectInferredType != null) {
      expect(staticType?.type, expectInferredType);
    }
  }

  @override
  bool isSwitchExhaustive(
      covariant _SwitchStatement node, Type expressionType) {
    return node.isExhaustive;
  }

  Type leastUpperBound(Type t1, Type t2) => _harness._lub(t1, t2);

  _PropertyElement lookupInterfaceMember(
      Node node, Type receiverType, String memberName) {
    return _harness.getMember(receiverType, memberName);
  }

  @override
  void setVariableType(Var variable, Type type) {
    variable.type = type;
  }

  @override
  String toString() => _irBuilder.toString();

  @override
  Type variableTypeFromInitializerType(Type type) {
    // Variables whose initializer has type `Null` receive the inferred type
    // `dynamic`.
    if (_harness.classifyType(type) == TypeClassification.nullOrEquivalent) {
      type = dynamicType;
    }
    // Variables whose initializer type includes a promoted type variable
    // receive the nearest supertype that could be expressed in Dart source code
    // (e.g. `T&int` is demoted to `T`).
    // TODO(paulberry): add language tests to verify that the behavior of
    // `type.recursivelyDemote` matches what the analyzer and CFE do.
    return type.recursivelyDemote(covariant: true) ?? type;
  }

  _PropertyElement _lookupMember(
      Expression node, Type receiverType, String memberName) {
    return lookupInterfaceMember(node, receiverType, memberName);
  }

  void _visitLoopBody(Statement loop, Statement body) {
    var previousBreakTarget = _currentBreakTarget;
    var previousContinueTarget = _currentContinueTarget;
    _currentBreakTarget = loop;
    _currentContinueTarget = loop;
    dispatchStatement(body);
    _currentBreakTarget = previousBreakTarget;
    _currentContinueTarget = previousContinueTarget;
  }
}

class _NonNullAssert extends Expression {
  final Expression operand;

  _NonNullAssert(this.operand, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    operand.preVisit(assignedVariables);
  }

  @override
  String toString() => '$operand!';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    return h.typeAnalyzer.analyzeNonNullAssert(this, operand);
  }
}

class _Not extends Expression {
  final Expression operand;

  _Not(this.operand, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    operand.preVisit(assignedVariables);
  }

  @override
  String toString() => '!$operand';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    return h.typeAnalyzer.analyzeLogicalNot(this, operand);
  }
}

class _NullAwareAccess extends Expression {
  static String _fakeMethodName = 'm';

  final Expression lhs;
  final Expression rhs;
  final bool isCascaded;

  _NullAwareAccess(this.lhs, this.rhs, this.isCascaded,
      {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    lhs.preVisit(assignedVariables);
    rhs.preVisit(assignedVariables);
  }

  @override
  String toString() => '$lhs?.${isCascaded ? '.' : ''}($rhs)';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    var lhsType = h.typeAnalyzer.analyzeExpression(lhs);
    h.flow.nullAwareAccess_rightBegin(isCascaded ? null : lhs, lhsType);
    var rhsType = h.typeAnalyzer.analyzeExpression(rhs);
    h.flow.nullAwareAccess_end();
    var type = h._lub(rhsType, Type('Null'));
    h.irBuilder.apply(
        _fakeMethodName, [Kind.expression, Kind.expression], Kind.expression,
        location: location);
    return new SimpleTypeAnalysisResult<Type>(type: type);
  }
}

class _NullLiteral extends Literal {
  _NullLiteral({required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {}

  @override
  String toString() => 'null';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    var result = h.typeAnalyzer.analyzeNullLiteral(this);
    h.irBuilder.atom('null', Kind.expression, location: location);
    return result;
  }
}

class _ParenthesizedExpression extends Expression {
  final Expression expr;

  _ParenthesizedExpression(this.expr, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    expr.preVisit(assignedVariables);
  }

  @override
  String toString() => '($expr)';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    return h.typeAnalyzer.analyzeParenthesizedExpression(this, expr, context);
  }
}

class _PlaceholderExpression extends Expression {
  final Type type;

  _PlaceholderExpression(this.type, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {}

  @override
  String toString() => '(expr with type $type)';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    h.irBuilder.atom(type.type, Kind.type, location: location);
    h.irBuilder.apply('expr', [Kind.type], Kind.expression, location: location);
    return new SimpleTypeAnalysisResult<Type>(type: type);
  }
}

class _Property extends PromotableLValue {
  final Expression target;

  final String propertyName;

  _Property(this.target, this.propertyName, {required super.location})
      : super._();

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables,
      {_LValueDisposition disposition = _LValueDisposition.read}) {
    target.preVisit(assignedVariables);
  }

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    return h.typeAnalyzer.analyzePropertyGet(this, target, propertyName);
  }

  @override
  Type? _getPromotedType(Harness h) {
    var receiverType = h.typeAnalyzer.analyzeExpression(target);
    var member = h.typeAnalyzer._lookupMember(this, receiverType, propertyName);
    return h.flow
        .promotedPropertyType(target, propertyName, member, member._type);
  }

  @override
  void _visitWrite(Harness h, Expression assignmentExpression, Type writtenType,
      Expression? rhs) {
    // No flow analysis impact
  }
}

/// Mini-ast representation of a class property.  Instances of this class are
/// used to represent class members in the flow analysis `promotableFields` set.
class _PropertyElement {
  /// The type of the property.
  final Type _type;

  _PropertyElement(this._type);
}

class _Return extends Statement {
  _Return({required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {}

  @override
  String toString() => 'return;';

  @override
  void visit(Harness h) {
    h.typeAnalyzer.analyzeReturnStatement();
    h.irBuilder.apply('return', [], Kind.statement, location: location);
  }
}

class _SwitchExpression extends Expression {
  final Expression scrutinee;
  final List<ExpressionCase> cases;

  _SwitchExpression(this.scrutinee, this.cases, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    scrutinee.preVisit(assignedVariables);
    for (var case_ in cases) {
      case_._preVisit(assignedVariables);
    }
  }

  @override
  String toString() {
    String body;
    if (cases.isEmpty) {
      body = '{}';
    } else {
      var contents = cases.join(' ');
      body = '{ $contents }';
    }
    return 'switch ($scrutinee) $body';
  }

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    var result =
        h.typeAnalyzer.analyzeSwitchExpression(this, scrutinee, cases, context);
    h.irBuilder.apply(
        'switchExpr',
        [Kind.expression, ...List.filled(cases.length, Kind.expressionCase)],
        Kind.expression,
        location: location);
    return result;
  }
}

class _SwitchStatement extends Statement {
  final Expression scrutinee;
  final List<StatementCase> cases;
  final bool isExhaustive;

  _SwitchStatement(this.scrutinee, this.cases, this.isExhaustive,
      {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    scrutinee.preVisit(assignedVariables);
    assignedVariables.beginNode();
    for (var case_ in cases) {
      case_._preVisit(assignedVariables);
    }
    assignedVariables.endNode(this);
  }

  @override
  String toString() {
    var exhaustiveness = isExhaustive ? 'exhaustive' : 'non-exhaustive';
    String body;
    if (cases.isEmpty) {
      body = '{}';
    } else {
      var contents = cases.join(' ');
      body = '{ $contents }';
    }
    return 'switch<$exhaustiveness> ($scrutinee) $body';
  }

  @override
  void visit(Harness h) {
    var previousBreakTarget = h.typeAnalyzer._currentBreakTarget;
    h.typeAnalyzer._currentBreakTarget = this;
    var previousContinueTarget = h.typeAnalyzer._currentContinueTarget;
    h.typeAnalyzer._currentContinueTarget = this;
    var numExecutionPaths =
        h.typeAnalyzer.analyzeSwitchStatement(this, scrutinee, cases);
    h.irBuilder.apply(
        'switch',
        [
          Kind.expression,
          ...List.filled(numExecutionPaths, Kind.statementCase)
        ],
        Kind.statement,
        location: location);
    h.typeAnalyzer._currentBreakTarget = previousBreakTarget;
    h.typeAnalyzer._currentContinueTarget = previousContinueTarget;
  }
}

class _This extends Expression {
  _This({required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {}

  @override
  String toString() => 'this';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    var result = h.typeAnalyzer.analyzeThis(this);
    h.irBuilder.atom('this', Kind.expression, location: location);
    return result;
  }
}

class _ThisOrSuperProperty extends PromotableLValue {
  final String propertyName;

  _ThisOrSuperProperty(this.propertyName, {required super.location})
      : super._();

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables,
      {_LValueDisposition disposition = _LValueDisposition.read}) {}

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    var result = h.typeAnalyzer.analyzeThisPropertyGet(this, propertyName);
    h.irBuilder.atom('this.$propertyName', Kind.expression, location: location);
    return result;
  }

  @override
  Type? _getPromotedType(Harness h) {
    h.irBuilder.atom('this.$propertyName', Kind.expression, location: location);
    var member = h.typeAnalyzer._lookupMember(this, h._thisType!, propertyName);
    return h.flow
        .promotedPropertyType(null, propertyName, member, member._type);
  }

  @override
  void _visitWrite(Harness h, Expression assignmentExpression, Type writtenType,
      Expression? rhs) {
    // No flow analysis impact
  }
}

class _Throw extends Expression {
  final Expression operand;

  _Throw(this.operand, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    operand.preVisit(assignedVariables);
  }

  @override
  String toString() => 'throw ...';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    return h.typeAnalyzer.analyzeThrow(this, operand);
  }
}

class _TryStatement extends TryStatement {
  final Statement _body;
  final List<_CatchClause> _catches;
  final Statement? _finally;

  _TryStatement(this._body, this._catches, this._finally,
      {required super.location})
      : super._();

  @override
  TryStatement catch_(
      {Var? exception, Var? stackTrace, required List<Statement> body}) {
    assert(_finally == null, 'catch after finally');
    return _TryStatement(
        _body,
        [
          ..._catches,
          _CatchClause(
              _Block(body, location: computeLocation()), exception, stackTrace)
        ],
        null,
        location: location);
  }

  @override
  Statement finally_(List<Statement> statements) {
    assert(_finally == null, 'multiple finally clauses');
    return _TryStatement(
        _body, _catches, _Block(statements, location: computeLocation()),
        location: location);
  }

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    if (_finally != null) {
      assignedVariables.beginNode();
    }
    if (_catches.isNotEmpty) {
      assignedVariables.beginNode();
    }
    _body.preVisit(assignedVariables);
    assignedVariables.endNode(_body);
    for (var catch_ in _catches) {
      catch_._preVisit(assignedVariables);
    }
    if (_finally != null) {
      if (_catches.isNotEmpty) {
        assignedVariables.endNode(this);
      }
      _finally!.preVisit(assignedVariables);
    }
  }

  @override
  void visit(Harness h) {
    h.typeAnalyzer.analyzeTryStatement(this, _body, _catches, _finally);
    h.irBuilder.apply(
        'try',
        [
          Kind.statement,
          ...List.filled(_catches.length, Kind.statement),
          Kind.statement
        ],
        Kind.statement,
        location: location);
  }
}

class _VariablePattern extends Pattern {
  final Type? declaredType;

  final Var variable;

  final String? expectInferredType;

  _VariablePattern(this.declaredType, this.variable, this.expectInferredType,
      {required super.location})
      : super._();

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    assignedVariables.declare(variable);
  }

  @override
  PatternDispatchResult<Node, Expression, Var, Type> visit(Harness h) {
    return h.typeAnalyzer.analyzeVariablePattern(this, variable, declaredType);
  }

  @override
  _debugString({required bool needsKeywordOrType}) => [
        if (declaredType != null)
          declaredType!.type
        else if (needsKeywordOrType)
          'var',
        variable.name,
        if (expectInferredType != null) '(expected type $expectInferredType)'
      ].join(' ');
}

class _VariableReference extends LValue {
  final Var variable;

  final void Function(Type?)? callback;

  _VariableReference(this.variable, this.callback, {required super.location})
      : super._();

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables,
      {_LValueDisposition disposition = _LValueDisposition.read}) {
    if (disposition != _LValueDisposition.write) {
      assignedVariables.read(variable);
    }
    if (disposition != _LValueDisposition.read) {
      assignedVariables.write(variable);
    }
  }

  @override
  String toString() => variable.name;

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    var result = h.typeAnalyzer.analyzeVariableGet(this, variable, callback);
    h.irBuilder.atom(variable.name, Kind.expression, location: location);
    return result;
  }

  @override
  void _visitWrite(Harness h, Expression assignmentExpression, Type writtenType,
      Expression? rhs) {
    h.flow.write(assignmentExpression, variable, writtenType, rhs);
  }
}

class _While extends Statement {
  final Expression condition;
  final Statement body;

  _While(this.condition, this.body, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    assignedVariables.beginNode();
    condition.preVisit(assignedVariables);
    body.preVisit(assignedVariables);
    assignedVariables.endNode(this);
  }

  @override
  String toString() => 'while ($condition) $body';

  @override
  void visit(Harness h) {
    h.typeAnalyzer.analyzeWhileLoop(this, condition, body);
    h.irBuilder.apply(
        'while', [Kind.expression, Kind.statement], Kind.statement,
        location: location);
  }
}

class _WrappedExpression extends Expression {
  final Statement? before;
  final Expression expr;
  final Statement? after;

  _WrappedExpression(this.before, this.expr, this.after,
      {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    before?.preVisit(assignedVariables);
    expr.preVisit(assignedVariables);
    after?.preVisit(assignedVariables);
  }

  @override
  String toString() {
    var s = StringBuffer('(');
    if (before != null) {
      s.write('($before) ');
    }
    s.write(expr);
    if (after != null) {
      s.write(' ($after)');
    }
    s.write(')');
    return s.toString();
  }

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    late MiniIrTmp beforeTmp;
    if (before != null) {
      h.typeAnalyzer.dispatchStatement(before!);
      h.irBuilder
          .apply('expr', [Kind.statement], Kind.expression, location: location);
      beforeTmp = h.irBuilder.allocateTmp();
    }
    var type = h.typeAnalyzer.analyzeExpression(expr);
    if (after != null) {
      var exprTmp = h.irBuilder.allocateTmp();
      h.typeAnalyzer.dispatchStatement(after!);
      h.irBuilder
          .apply('expr', [Kind.statement], Kind.expression, location: location);
      var afterTmp = h.irBuilder.allocateTmp();
      h.irBuilder.readTmp(exprTmp, location: location);
      h.irBuilder.let(afterTmp, location: location);
      h.irBuilder.let(exprTmp, location: location);
    }
    h.flow.forwardExpression(this, expr);
    if (before != null) {
      h.irBuilder.let(beforeTmp, location: location);
    }
    return new SimpleTypeAnalysisResult<Type>(type: type);
  }
}

class _Write extends Expression {
  final LValue lhs;
  final Expression? rhs;

  _Write(this.lhs, this.rhs, {required super.location});

  @override
  void preVisit(AssignedVariables<Node, Var> assignedVariables) {
    lhs.preVisit(assignedVariables,
        disposition: rhs == null
            ? _LValueDisposition.readWrite
            : _LValueDisposition.write);
    rhs?.preVisit(assignedVariables);
  }

  @override
  String toString() => '$lhs = $rhs';

  @override
  ExpressionTypeAnalysisResult<Type> visit(Harness h, Type context) {
    var rhs = this.rhs;
    Type type;
    if (rhs == null) {
      // We are simulating an increment/decrement operation.
      // TODO(paulberry): Make a separate node type for this.
      type = h.typeAnalyzer.analyzeExpression(lhs);
    } else {
      type = h.typeAnalyzer.analyzeExpression(rhs);
    }
    lhs._visitWrite(h, this, type, rhs);
    // TODO(paulberry): null shorting
    return new SimpleTypeAnalysisResult<Type>(type: type);
  }
}
