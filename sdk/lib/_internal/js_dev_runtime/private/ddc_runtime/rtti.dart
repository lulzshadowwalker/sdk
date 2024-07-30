// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This library defines the association between runtime objects and
/// runtime types.
part of dart._runtime;

/// Runtime type information.  This module defines the mapping from
/// runtime objects to their runtime type information.  See the types
/// module for the definition of how type information is represented.
///
/// There are two kinds of objects that represent "types" at runtime. A
/// "runtime type" contains all of the data needed to implement the runtime
/// type checking inserted by the compiler. These objects fall into four
/// categories:
///
///   - Things represented by javascript primitives, such as
///     null, numbers, booleans, strings, and symbols.  For these
///     we map directly from the javascript type (given by typeof)
///     to the appropriate class type from core, which serves as their
///     rtti.
///
///   - Functions, which are represented by javascript functions.
///     Representations of Dart functions always have a
///     _runtimeType property attached to them with the appropriate
///     rtti.
///
///   - Objects (instances) which are represented by instances of
///     javascript (ES6) classes.  Their types are given by their
///     classes, and the rtti is accessed by projecting out their
///     constructor field.
///
///   - Types objects, which are represented as described in the types
///     module.  Types always have a _runtimeType property attached to
///     them with the appropriate rtti.  The rtti for these is always
///     core.Type.  TODO(leafp): consider the possibility that we can
///     reliably recognize type objects and map directly to core.Type
///     rather than attaching this property everywhere.
///
/// The other kind of object representing a "type" is the instances of the
/// dart:core Type class. These are the user visible objects you get by calling
/// "runtimeType" on an object or using a class literal expression. These are
/// different from the above objects, and are created by calling `wrapType()`
/// on a runtime type.

/// Tag a closure with a type.
///
/// `dart.fn(closure, type)` marks [closure] with the provided runtime [type].
fn(closure, type) {
  JS('', '#[#] = #', closure, JS_GET_NAME(JsGetName.SIGNATURE_NAME), type);
  return closure;
}

/// Tag a generic [closure] with a [type] and the [defaultTypeArgs] values.
///
/// Only called from generated code when running with the new type system.
gFn(Object closure, Object type, JSArray<Object> defaultTypeArgs) {
  JS('', '#[#] = #', closure, JS_GET_NAME(JsGetName.SIGNATURE_NAME), type);
  JS('', '#._defaultTypeArgs = #', closure, defaultTypeArgs);
  return closure;
}

/// Tag a closure with a type that's computed lazily.
///
/// `dart.fn(closure, type)` marks [closure] with a getter that uses
/// [computeType] to return the runtime type.
///
/// The getter/setter replaces the property with a value property, so the
/// resulting function is compatible with [fn] and the type can be set again
/// safely.
lazyFn(closure, Object Function() computeType) {
  defineAccessor(closure, _runtimeType,
      get: () => defineValue(closure, _runtimeType, computeType()),
      set: (value) => defineValue(closure, _runtimeType, value),
      configurable: true);
  return closure;
}

final Object _runtimeType = JS('!', 'Symbol("_runtimeType")');

final Object _moduleName = JS('!', 'Symbol("_moduleName")');

/// Returns the interceptor for [obj] as needed by the dart:rti library.
///
/// Calls to this method are generated by the compiler.
@notNull
Object getInterceptorForRti(obj) {
  var classRef;
  if (obj == null) {
    classRef = JS_CLASS_REF(Null);
  } else {
    switch (JS<String>('!', 'typeof #', obj)) {
      case 'number':
        classRef = JS('', 'Math.floor(#) == # ? # : #', obj, obj,
            JS_CLASS_REF(JSInt), JS_CLASS_REF(JSNumNotInt));
        break;
      case 'function':
        var signature =
            JS('', '#[#]', obj, JS_GET_NAME(JsGetName.SIGNATURE_NAME));
        classRef = signature != null
            ? JS_CLASS_REF(Function)
            // Dart functions should always be tagged with a signature, assume
            // this must be a JavaScript function.
            : JS_CLASS_REF(JavaScriptFunction);
        break;
      default:
        // The interceptors for native JavaScript types like bool, string, etc.
        // (excluding number and function, see above) are stored as a symbolized
        // property and can be accessed from the prototype of native value.
        // Avoid reading this field when `obj` has the property itself which
        // means that `obj` must be a native prototype and should be treated as
        // an interop object.
        if (!JS('', '#.call(#, #)', hOP, obj, _extensionType)) {
          classRef = JS('', '#[#]', obj, _extensionType);
        }
        // If there is no extension type then this object must not be from Dart.
        if (classRef == null) classRef = JS_CLASS_REF(LegacyJavaScriptObject);
    }
  }
  if (classRef == null) throw 'Unknown interceptor for object: ($obj)';
  return JS<Object>('!', '#.prototype', classRef);
}

/// Returns the runtime representation of the type of obj.
///
/// The resulting object is used internally for runtime type checking. This is
/// different from the user-visible Type object returned by calling
/// `runtimeType` on some Dart object.
getReifiedType(obj) {
  switch (JS<String>('!', 'typeof #', obj)) {
    case "object":
      if (obj == null) return TYPE_REF<Null>();
      if (_jsInstanceOf(obj, RecordImpl)) return getRtiForRecord(obj);
      if (_jsInstanceOf(obj, Object) ||
          // Avoid reading this field when `obj` has the property itself which
          // means that `obj` must be a native prototype and should be treated
          // as an interop object.
          (JS('', '#[#]', obj, _extensionType) != null &&
              !JS('', '#.call(#, #)', hOP, obj, _extensionType))) {
        // The rti library can correctly extract the representation.
        return rti.instanceType(obj);
      }
      // Otherwise assume this is a JS interop object.
      return TYPE_REF<LegacyJavaScriptObject>();
    case "function":
      // Dart functions are tagged with a signature.
      var signature =
          JS('', '#[#]', obj, JS_GET_NAME(JsGetName.SIGNATURE_NAME));
      if (signature != null) return signature;
      return TYPE_REF<JavaScriptFunction>();
    case "undefined":
      return TYPE_REF<Null>();
    case "number":
      return JS('', 'Math.floor(#) == # ? # : #', obj, obj, TYPE_REF<int>(),
          TYPE_REF<double>());
    case "boolean":
      return TYPE_REF<bool>();
    case "string":
      return TYPE_REF<String>();
    case "symbol":
      return TYPE_REF<JavaScriptSymbol>();
    case "bigint":
      return TYPE_REF<JavaScriptBigInt>();
    default:
      return TYPE_REF<LegacyJavaScriptObject>();
  }
}

/// Return the module name for a raw library object.
String? getModuleName(Object module) => JS('', '#[#]', module, _moduleName);

final _loadedModules = JS('', 'new Map()');
final _loadedPartMaps = JS('', 'new Map()');
final _loadedSourceMaps = JS('', 'new Map()');

List<String> getModuleNames() {
  return JS<List<String>>('', 'Array.from(#.keys())', _loadedModules);
}

String? getSourceMap(String moduleName) {
  return JS('!', '#.get(#)', _loadedSourceMaps, moduleName);
}

/// Return all library objects in the specified module.
getModuleLibraries(String name) {
  var module = JS('', '#.get(#)', _loadedModules, name);
  if (module == null) return null;
  JS('', '#[#] = #', module, _moduleName, name);
  return module;
}

/// Return the part map for a specific module.
getModulePartMap(String name) => JS('', '#.get(#)', _loadedPartMaps, name);

/// Track all libraries
void trackLibraries(
    String moduleName, Object libraries, Object parts, String? sourceMap) {
  if (parts is String) {
    // Added for backwards compatibility.
    // package:build_web_compilers currently invokes this without [parts]
    // in its bootstrap code.
    sourceMap = parts;
    parts = JS('', '{}');
  }
  JS('', '#.set(#, #)', _loadedSourceMaps, moduleName, sourceMap);
  JS('', '#.set(#, #)', _loadedModules, moduleName, libraries);
  JS('', '#.set(#, #)', _loadedPartMaps, moduleName, parts);
  _libraries = null;
  _libraryObjects = null;
  _parts = null;
}

List<String>? _libraries;
Map<String, Object?>? _libraryObjects;
Map<String, List<String>?>? _parts;

_computeLibraryMetadata() {
  _libraries = [];
  _libraryObjects = {};
  _parts = {};
  var modules = getModuleNames();
  for (var name in modules) {
    // Add libraries from each module.
    var module = getModuleLibraries(name);
    // TODO(nshahan) Can we optimize this cast and the one below to use
    // JsArray.of() to be more efficient?
    var libraries = getOwnPropertyNames(module).cast<String>();
    _libraries!.addAll(libraries);
    for (var library in libraries) {
      _libraryObjects![library] = JS('', '#.#', module, library);
    }

    // Add parts from each module.
    var partMap = getModulePartMap(name);
    libraries = getOwnPropertyNames(partMap).cast<String>();
    for (var library in libraries) {
      _parts![library] = List.from(JS('List', '#.#', partMap, library));
    }
  }
}

/// Returns the JS library object for a given library [uri] or
/// undefined / null if it isn't loaded.  Top-level types and
/// methods are available on this object.
Object? getLibrary(String uri) {
  if (_libraryObjects == null) {
    _computeLibraryMetadata();
  }
  return _libraryObjects![uri];
}

/// Returns a JSArray of library uris (e.g,
/// ['dart:core', 'dart:_internal', ..., 'package:foo/bar.dart', ... 'main.dart'])
/// loaded in this application.
List<String> getLibraries() {
  if (_libraries == null) {
    _computeLibraryMetadata();
  }
  return _libraries!;
}

/// Returns a JSArray of part uris for a given [libraryUri].
/// The part uris will be relative to the [libraryUri].
///
/// E.g., invoking `getParts('package:intl/intl.dart')` returns (as of this
/// writing): ```
/// ["src/intl/bidi_formatter.dart", "src/intl/bidi_utils.dart",
///  "src/intl/compact_number_format.dart", "src/intl/date_format.dart",
///  "src/intl/date_format_field.dart", "src/intl/date_format_helpers.dart",
///  "src/intl/number_format.dart"]
/// ```
///
/// If [libraryUri] doesn't map to a library or maps to a library with no
/// parts, an empty list is returned.
List<String> getParts(String libraryUri) {
  if (_parts == null) {
    _computeLibraryMetadata();
  }
  return _parts![libraryUri] ?? [];
}
