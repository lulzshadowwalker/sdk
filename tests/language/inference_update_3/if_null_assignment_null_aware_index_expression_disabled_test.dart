// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Tests the absence of the functionality proposed in
// https://github.com/dart-lang/language/issues/1618#issuecomment-1507241494
// when the `inference-update-3` language feature is not enabled, using if-null
// assignments whose target is a null-aware index expression.

// @dart=3.3

import '../static_type_helper.dart';

/// Ensures a context type of `Iterable<T>?` for the operand, or `Iterable<_>?`
/// if no type argument is supplied.
Object? contextIterableQuestion<T>(Iterable<T>? x) => x;

/// Class that can be the target of `[]` and `[]=` operations. [ReadType] and
/// [WriteType] are the read and write types of the `[]` and `[]=` operators,
/// respectively.
class Indexable<ReadType, WriteType> {
  final ReadType _value;

  Indexable(this._value);

  ReadType operator [](int index) => _value;

  operator []=(int index, WriteType value) {}
}

Indexable<ReadType, WriteType>? maybeIndexable<ReadType, WriteType>(
        ReadType value) =>
    Indexable<ReadType, WriteType>(value);

main() {
  // - An if-null assignment `E` of the form `lvalue ??= e` with context type
  //   `K` is analyzed as follows:
  //
  //   - Let `T1` be the read type of the lvalue.
  //   - Let `T2` be the type of `e` inferred with context type `J`, where:
  //     - If the lvalue is a local variable, `J` is the promoted type of the
  //       variable.
  //     - Otherwise, `J` is the write type of the lvalue.
  {
    // Check the context type of `e`.
    // ignore: dead_null_aware_expression
    maybeIndexable<String, Object?>('')?[0] ??= contextType('')
      ..expectStaticType<Exactly<Object?>>();

    maybeIndexable<String?, String?>(null)?[0] ??= contextType('')
      ..expectStaticType<Exactly<String?>>();
  }

  //   - Let `T` be `UP(NonNull(T1), T2)`.
  //   - Let `S` be the greatest closure of `K`.
  //   - If `T <: S`, then the type of `E` is `T`.
  {
    // K=Object?, T1=int?, and T2=double, therefore T=num and S=Object?, so T <:
    // S, and hence the type of E is num (which becomes num? after null shorting
    // completes).
    var d = 2.0;
    context<Object?>((maybeIndexable<int?, Object?>(null)?[0] ??= d)
      ..expectStaticType<Exactly<num?>>());

    // K=Iterable<_>?, T1=Iterable<int>?, and T2=Iterable<double>, therefore
    // T=Iterable<num> and S=Iterable<Object?>?, so T <: S, and hence the type
    // of E is Iterable<num> (which becomes Iterable<num>? after null shorting
    // completes).
    var iterableDouble = <double>[] as Iterable<double>;
    contextIterableQuestion(
        (maybeIndexable<Iterable<int>?, Object?>(null)?[0] ??= iterableDouble)
          ..expectStaticType<Exactly<Iterable<num>?>>());
  }

  //   - Otherwise, if `NonNull(T1) <: S` and `T2 <: S`, then the type of `E` is
  //     `S` if `inference-update-3` is enabled, else the type of `E` is `T`.
  {
    // K=Iterable<num>?, T1=Iterable<int>?, and T2=List<num>, therefore T=Object
    // and S=Iterable<num>?, so T is not <: S, but NonNull(T1) <: S and T2 <: S,
    // hence the type of E is Object (which becomes Object? after null shorting
    // completes).
    var listNum = <num>[];
    var o = [0] as Object?;
    if (o is Iterable<num>?) {
      // We avoid having a compile-time error because `o` can be demoted.
      o = (maybeIndexable<Iterable<int>?, Object?>(null)?[0] ??= listNum)
        ..expectStaticType<Exactly<Object?>>();
    }
  }

  //   - Otherwise, the type of `E` is `T`.
  {
    var d = 2.0;
    var o = 0 as Object?;
    var intQuestion = null as int?;
    if (o is int?) {
      // K=int?, T1=int?, and T2=double, therefore T=num and S=int?, so T is not
      // <: S. NonNull(T1) <: S, but T2 is not <: S. Hence the type of E is num
      // (which becomes num? after null shorting completes).
      // We avoid having a compile-time error because `o` can be demoted.
      o = (maybeIndexable<int?, Object?>(null)?[0] ??= d)
        ..expectStaticType<Exactly<num?>>();
    }
    o = 0 as Object?;
    if (o is int?) {
      // K=int?, T1=double?, and T2=int?, therefore T=num? and S=int?, so T is
      // not <: S. T2 <: S, but NonNull(T1) is not <: S. Hence the type of E is
      // num?.
      // We avoid having a compile-time error because `o` can be demoted.
      o = (maybeIndexable<double?, Object?>(null)?[0] ??= intQuestion)
        ..expectStaticType<Exactly<num?>>();
    }
    o = '' as Object?;
    if (o is String?) {
      // K=String?, T1=int?, and T2=double, therefore T=num and S=String?, so
      // none of T, NonNull(T1), nor T2 are <: S. Hence the type of E is num
      // (which becomes num? after null shorting completes).
      // We avoid having a compile-time error because `o` can be demoted.
      o = (maybeIndexable<int?, Object?>(null)?[0] ??= d)
        ..expectStaticType<Exactly<num?>>();
    }
  }
}
