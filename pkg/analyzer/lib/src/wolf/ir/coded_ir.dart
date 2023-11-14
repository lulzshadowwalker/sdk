// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/wolf/ir/ir.dart';

/// Container for a sequence of IR instructions, along with auxiliary tables
/// representing types, literal values, etc. that those instructions refer to.
///
/// See [BaseIRContainer] for additional information.
///
/// To construct a sequence of IR instructions, see [CodedIRWriter].
class CodedIRContainer extends BaseIRContainer {
  final List<Object?> _literalTable;
  final List<DartType> _typeTable;

  CodedIRContainer(CodedIRWriter super.writer)
      : _literalTable = writer._literalTable,
        _typeTable = writer._typeTable;

  @override
  int countParameters(TypeRef type) =>
      (decodeType(type) as FunctionType).parameters.length;

  Object? decodeLiteral(LiteralRef literal) => _literalTable[literal.index];

  DartType decodeType(TypeRef type) => _typeTable[type.index];

  @override
  String literalRefToString(LiteralRef value) =>
      json.encode(decodeLiteral(value));

  @override
  String typeRefToString(TypeRef type) => decodeType(type).toString();
}

/// Writer of an IR instruction stream, which can encode types, literal values,
/// etc. into auxiliary tables.
///
/// See [RawIRWriter] for more information.
class CodedIRWriter extends RawIRWriter {
  final _literalTable = <Object?>[];
  final _typeTable = <DartType>[];
  final _literalToRef = <Object?, LiteralRef>{};
  final _typeToRef = <DartType, TypeRef>{};

  LiteralRef encodeLiteral(Object? value) =>
      // TODO(paulberry): is `putIfAbsent` the best-performing way to do this?
      _literalToRef.putIfAbsent(value, () {
        var encoding = LiteralRef(_literalTable.length);
        _literalTable.add(value);
        return encoding;
      });

  TypeRef encodeType(DartType type) =>
      // TODO(paulberry): is `putIfAbsent` the best-performing way to do this?
      _typeToRef.putIfAbsent(type, () {
        var encoding = TypeRef(_typeTable.length);
        _typeTable.add(type);
        return encoding;
      });
}
