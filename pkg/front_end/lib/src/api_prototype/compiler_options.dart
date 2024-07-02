// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library front_end.compiler_options;

import 'package:_fe_analyzer_shared/src/messages/diagnostic_message.dart'
    show DiagnosticMessage, DiagnosticMessageHandler;
import 'package:_fe_analyzer_shared/src/messages/severity.dart' show Severity;
import 'package:kernel/ast.dart' show Component, Version;
import 'package:kernel/default_language_version.dart' as kernel
    show defaultLanguageVersion;
import 'package:kernel/target/targets.dart' show Target;
import 'package:macros/src/executor/multi_executor.dart';
import 'package:macros/src/executor/serialization.dart' as macros
    show SerializationMode;

import '../api_unstable/util.dart';
import '../base/nnbd_mode.dart';
import '../macros/macro_serializer.dart';
import 'experimental_flags.dart'
    show
        AllowedExperimentalFlags,
        ExperimentalFlag,
        GlobalFeatures,
        parseExperimentalFlag;
import 'experimental_flags.dart' as flags
    show
        getExperimentEnabledVersionInLibrary,
        isExperimentEnabledInLibraryByVersion;
import 'file_system.dart' show FileSystem;
import 'standard_file_system.dart' show StandardFileSystem;

export 'package:_fe_analyzer_shared/src/messages/diagnostic_message.dart'
    show DiagnosticMessage;

/// Front-end options relevant to compiler back ends.
///
/// Not intended to be implemented or extended by clients.
class CompilerOptions {
  /// The URI of the root of the Dart SDK (typically a "file:" URI).
  ///
  /// If `null`, the SDK will be searched for using
  /// [Platform.resolvedExecutable] as a starting point.
  Uri? sdkRoot;

  /// Uri to a platform libraries specification file.
  ///
  /// A libraries specification file is a JSON file that describes how to map
  /// `dart:*` libraries to URIs in the underlying [fileSystem].  See
  /// `package:_fe_analyzer_shared/src/util/libraries_specification.dart` for
  /// details on the format.
  ///
  /// If a value is not specified and `compileSdk = true`, the compiler will
  /// infer at a default location under [sdkRoot], typically under
  /// `lib/libraries.json`.
  Uri? librariesSpecificationUri;

  DiagnosticMessageHandler? onDiagnostic;

  /// URI of the ".dart_tool/package_config.json" file
  /// (typically a "file:" URI).
  ///
  /// If `null`, the file will be found via the standard package_config search
  /// algorithm.
  ///
  /// If the URI's path component is empty (e.g. `new Uri()`), no packages file
  /// will be used.
  ///
  /// If an old ".packages" file is given an error is issued.
  Uri? packagesFileUri;

  /// URIs of additional dill files.
  ///
  /// These will be loaded and linked into the output.
  ///
  /// The components provided here should be closed: any libraries that they
  /// reference should be defined in a component in [additionalDills] or
  /// [sdkSummary].
  List<Uri> additionalDills = [];

  /// URI of the SDK summary file (typically a "file:" URI).
  ///
  /// This should be a summary previously generated by this package (and
  /// not the similarly named summary files from `package:analyzer`.)
  ///
  /// If `null` and [compileSdk] is false, the SDK summary will be searched for
  /// at a default location within [sdkRoot].
  Uri? sdkSummary;

  /// The declared variables for use by configurable imports and constant
  /// evaluation.
  Map<String, String>? declaredVariables;

  /// The [FileSystem] which should be used by the front end to access files.
  ///
  /// All file system access performed by the front end goes through this
  /// mechanism, with one exception: if no value is specified for
  /// [packagesFileUri], the packages file is located using the actual physical
  /// file system.  TODO(paulberry): fix this.
  FileSystem fileSystem = StandardFileSystem.instance;

  /// The [MultiMacroExecutor] for loading and executing macros if supported.
  ///
  /// This is part of the experimental macro feature.
  MultiMacroExecutor? macroExecutor;

  /// If true, all macro applications must have a corresponding prebuilt macro
  /// supplied via `precompiledMacros`.
  ///
  /// Otherwise, that's an error.
  ///
  /// This is part of the experimental macro feature.
  bool requirePrebuiltMacros = false;

  /// Function that can create a [Uri] for the serialized result of a
  /// [Component].
  ///
  /// This is used to turn a precompiled macro into a [Uri] that can be loaded
  /// by the [macroExecutor].
  ///
  /// If `null` then an appropriate macro serializer will be created.
  ///
  /// [MacroSerializer.close] will be called when `Uri`s created are no longer
  /// needed.
  ///
  /// This is part of the experimental macro feature.
  MacroSerializer? macroSerializer;

  /// Raw precompiled macro options, each of the format
  /// `<program-uri>;<macro-library-uri>`.
  ///
  /// Multiple library URIs may be provided separated by additional semicolons.
  List<String>? precompiledMacros;

  /// The serialization mode to use for macro communication.
  macros.SerializationMode? macroSerializationMode;

  /// Whether to generate code for the SDK.
  ///
  /// By default the front end resolves components using a prebuilt SDK summary.
  /// When this option is `true`, [sdkSummary] must be null.
  bool compileSdk = false;

  /// Enable or disable experimental features. Features mapping to `true` are
  /// explicitly enabled. Features mapping to `false` are explicitly disabled.
  /// Features not mentioned in the map will have their default value.
  Map<ExperimentalFlag, bool> explicitExperimentalFlags =
      <ExperimentalFlag, bool>{};

  Map<ExperimentalFlag, bool>? defaultExperimentFlagsForTesting;
  AllowedExperimentalFlags? allowedExperimentalFlagsForTesting;
  Map<ExperimentalFlag, Version>? experimentEnabledVersionForTesting;
  Map<ExperimentalFlag, Version>? experimentReleasedVersionForTesting;

  bool enableUnscheduledExperiments = false;

  /// Environment map used when evaluating `bool.fromEnvironment`,
  /// `int.fromEnvironment` and `String.fromEnvironment` during constant
  /// evaluation. If the map is `null`, all environment constants will be left
  /// unevaluated and can be evaluated by a constant evaluator later.
  Map<String, String>? environmentDefines = null;

  /// Report an error if a constant could not be evaluated (either because it
  /// is an environment constant and no environment was specified, or because
  /// it refers to a constructor or variable initializer that is not available).
  bool errorOnUnevaluatedConstant = false;

  /// The target platform that will consume the compiled code.
  ///
  /// Used to provide platform-specific details to the compiler like:
  ///   * the set of libraries are part of a platform's SDK (e.g. dart:html for
  ///     dart2js, dart:ui for flutter).
  ///
  ///   * what kernel transformations should be applied to the component
  ///     (async/await, mixin inlining, etc).
  ///
  ///   * how to deal with non-standard features like `native` extensions.
  ///
  /// If not specified, the default target is the VM.
  Target? target;

  /// Whether to show verbose messages (mainly for debugging and performance
  /// tracking).
  ///
  /// Messages are printed on stdout.
  // TODO(sigmund): improve the diagnostics API to provide mechanism to
  // intercept verbose data (Issue #30056)
  bool verbose = false;

  /// Whether to run extra verification steps to validate that compiled
  /// components are well formed.
  ///
  /// Errors are reported via the [onDiagnostic] callback.
  bool verify = false;

  /// Whether to - if verifying - skip the platform.
  bool skipPlatformVerification = false;

  /// Whether to dump generated components in a text format (also mainly for
  /// debugging).
  ///
  /// Dumped data is printed in stdout.
  bool debugDump = false;

  /// Whether to show file offsets when [debugDump] is `true`.
  bool debugDumpShowOffsets = false;

  /// Whether to omit the platform when serializing the result from a `fasta
  /// compile` run.
  bool omitPlatform = false;

  /// Whether to set the exit code to non-zero if any problem (including
  /// warning, etc.) is encountered during compilation.
  bool setExitCodeOnProblem = false;

  /// Whether to embed the input sources in generated kernel components.
  ///
  /// The kernel `Component` API includes a `uriToSource` map field that is used
  /// to embed the entire contents of the source files. This part of the kernel
  /// API is in flux and it is not necessary for some tools. Today it is used
  /// for translating error locations and stack traces in the VM.
  // TODO(sigmund): change the default.
  bool embedSourceText = true;

  /// Whether the compiler should throw as soon as it encounters a
  /// compilation error.
  ///
  /// Typically used by developers to debug internals of the compiler.
  bool throwOnErrorsForDebugging = false;

  /// Whether the compiler should throw as soon as it encounters a
  /// compilation warning.
  ///
  /// Typically used by developers to debug internals of the compiler.
  bool throwOnWarningsForDebugging = false;

  /// For the [throwOnErrorsForDebugging] or [throwOnWarningsForDebugging]
  /// options, skip this number of otherwise fatal diagnostics without throwing.
  /// I.e. the default value of 0 means throw on the first fatal diagnostic.
  ///
  /// If the value is negative, print a stack trace for every fatal
  /// diagnostic, but do not stop the compilation.
  int skipForDebugging = 0;

  /// If `true`, messages from the OS will be omitted from error messages in
  /// order to ensure a stable output for testing.
  bool omitOsMessageForTesting = false;

  /// If `true`, macro generated libraries will be printed during compilation.
  bool showGeneratedMacroSourcesForTesting = false;

  /// Object used for hooking into the compilation pipeline during testing.
  HooksForTesting? hooksForTesting;

  /// Whether to write a file (e.g. a dill file) when reporting a crash.
  bool writeFileOnCrashReport = true;

  /// Whether nnbd weak or strong mode is used.
  NnbdMode nnbdMode = NnbdMode.Strong;

  /// The current sdk version string, e.g. "2.6.0-edge.sha1hash".
  /// For instance used for language versioning (specifying the maximum
  /// version).
  String currentSdkVersion = "${kernel.defaultLanguageVersion.major}"
      "."
      "${kernel.defaultLanguageVersion.minor}";

  /// If `true`, a '.d' file with input dependencies is generated when
  /// compiling the platform dill.
  bool emitDeps = true;

  /// Set of invocation modes the describe how the compilation is performed.
  ///
  /// This used to selectively emit certain messages depending on how the
  /// CFE is invoked. For instance to emit a message about the null safety
  /// compilation mode when the modes includes [InvocationMode.compile].
  Set<InvocationMode> invocationModes = {};

  /// Verbosity level used for filtering emitted messages.
  Verbosity verbosity = Verbosity.all;

  GlobalFeatures? _globalFeatures;

  GlobalFeatures get globalFeatures => _globalFeatures ??= new GlobalFeatures(
      explicitExperimentalFlags,
      defaultExperimentFlagsForTesting: defaultExperimentFlagsForTesting,
      experimentEnabledVersionForTesting: experimentEnabledVersionForTesting,
      experimentReleasedVersionForTesting: experimentReleasedVersionForTesting,
      allowedExperimentalFlags: allowedExperimentalFlagsForTesting);

  /// The precompilations already in progress in an outer compile or that will
  /// be built in the current compile.
  ///
  /// When a compile discovers macros that are not prebuilt it launches a new
  /// nested compile to build them, a precompilation. That precompilation must
  /// itself launch more compilations if it encounters more macros. This set
  /// tracks what is running so that already-running precompilations are not
  /// launched again.
  Set<Uri> runningPrecompilations = {};

  // Coverage-ignore(suite): Not run.
  /// Returns the minimum language version needed for a library with the given
  /// [importUri] to opt into the experiment with the given [flag].
  ///
  /// Note that the experiment might not be enabled at all for the library, as
  /// computed by [isExperimentEnabledInLibrary].
  Version getExperimentEnabledVersionInLibrary(
      ExperimentalFlag flag, Uri importUri) {
    return flags.getExperimentEnabledVersionInLibrary(
        flag, importUri, explicitExperimentalFlags,
        defaultExperimentFlagsForTesting: defaultExperimentFlagsForTesting,
        allowedExperimentalFlags: allowedExperimentalFlagsForTesting,
        experimentEnabledVersionForTesting: experimentEnabledVersionForTesting,
        experimentReleasedVersionForTesting:
            experimentReleasedVersionForTesting);
  }

  /// Return `true` if the experiment with the given [flag] is enabled for the
  /// library with the given [importUri] and language [version].
  bool isExperimentEnabledInLibraryByVersion(
      ExperimentalFlag flag, Uri importUri, Version version) {
    return flags.isExperimentEnabledInLibraryByVersion(flag, importUri, version,
        explicitExperimentalFlags: explicitExperimentalFlags,
        defaultExperimentFlagsForTesting: defaultExperimentFlagsForTesting,
        allowedExperimentalFlags: allowedExperimentalFlagsForTesting,
        experimentEnabledVersionForTesting: experimentEnabledVersionForTesting,
        experimentReleasedVersionForTesting:
            experimentReleasedVersionForTesting);
  }

  // Coverage-ignore(suite): Not run.
  bool equivalent(CompilerOptions other,
      {bool ignoreOnDiagnostic = true,
      bool ignoreVerbose = true,
      bool ignoreVerify = true,
      bool ignoreDebugDump = true}) {
    if (sdkRoot != other.sdkRoot) return false;
    if (librariesSpecificationUri != other.librariesSpecificationUri) {
      return false;
    }
    if (!ignoreOnDiagnostic) {
      if (onDiagnostic != other.onDiagnostic) return false;
    }
    if (packagesFileUri != other.packagesFileUri) return false;
    if (!equalLists(additionalDills, other.additionalDills)) return false;
    if (sdkSummary != other.sdkSummary) return false;
    if (!equalMaps(declaredVariables, other.declaredVariables)) return false;
    if (fileSystem != other.fileSystem) return false;
    if (compileSdk != other.compileSdk) return false;
    // chaseDependencies aren't used anywhere, so ignored here.
    // targetPatches aren't used anywhere, so ignored here.
    if (!equalMaps(
        explicitExperimentalFlags, other.explicitExperimentalFlags)) {
      return false;
    }
    if (!equalMaps(environmentDefines, other.environmentDefines)) return false;
    if (errorOnUnevaluatedConstant != other.errorOnUnevaluatedConstant) {
      return false;
    }
    if (target != other.target) {
      if (target.runtimeType != other.target.runtimeType) return false;
      if (target?.name != other.target?.name) return false;
      if (target?.flags != other.target?.flags) return false;
    }
    // enableAsserts is not used anywhere, so ignored here.
    if (!ignoreVerbose) {
      if (verbose != other.verbose) return false;
    }
    if (!ignoreVerify) {
      if (verify != other.verify) return false;
      if (skipPlatformVerification != other.skipPlatformVerification) {
        return false;
      }
    }
    if (!ignoreDebugDump) {
      if (debugDump != other.debugDump) return false;
      if (debugDumpShowOffsets != other.debugDumpShowOffsets) return false;
    }
    if (omitPlatform != other.omitPlatform) return false;
    if (setExitCodeOnProblem != other.setExitCodeOnProblem) return false;
    if (embedSourceText != other.embedSourceText) return false;
    if (throwOnErrorsForDebugging != other.throwOnErrorsForDebugging) {
      return false;
    }
    if (throwOnWarningsForDebugging != other.throwOnWarningsForDebugging) {
      return false;
    }
    if (skipForDebugging != other.skipForDebugging) return false;
    if (writeFileOnCrashReport != other.writeFileOnCrashReport) return false;
    if (nnbdMode != other.nnbdMode) return false;
    if (currentSdkVersion != other.currentSdkVersion) return false;
    if (emitDeps != other.emitDeps) return false;
    if (!equalSets(invocationModes, other.invocationModes)) return false;
    if (enableUnscheduledExperiments != other.enableUnscheduledExperiments) {
      return false;
    }

    return true;
  }
}

/// Parse experimental flag arguments of the form 'flag' or 'no-flag' into a map
/// from 'flag' to `true` or `false`, respectively.
Map<String, bool> parseExperimentalArguments(Iterable<String>? arguments) {
  Map<String, bool> result = {};
  if (arguments != null) {
    for (String argument in arguments) {
      for (String feature in argument.split(',')) {
        if (feature.startsWith('no-')) {
          // Coverage-ignore-block(suite): Not run.
          result[feature.substring(3)] = false;
        } else {
          result[feature] = true;
        }
      }
    }
  }
  return result;
}

/// Parse a map of experimental flags to values that can be passed to
/// [CompilerOptions.explicitExperimentalFlags].
///
/// If an unknown flag is mentioned, or a flag is mentioned more than once,
/// the supplied error handler is called with an error message.
///
/// If an expired flag is set to its non-default value the supplied error
/// handler is called with an error message.
///
/// If an expired flag is set to its default value the supplied warning
/// handler is called with a warning message.
Map<ExperimentalFlag, bool> parseExperimentalFlags(
    Map<String, bool>? experiments,
    {required void Function(String message) onError,
    void Function(String message)? onWarning}) {
  Map<ExperimentalFlag, bool> flags = <ExperimentalFlag, bool>{};
  if (experiments != null) {
    for (String experiment in experiments.keys) {
      bool value = experiments[experiment]!;
      ExperimentalFlag? flag = parseExperimentalFlag(experiment);
      if (flag == null) {
        // Coverage-ignore-block(suite): Not run.
        onError("Unknown experiment: " + experiment);
      } else if (flags.containsKey(flag)) {
        // Coverage-ignore-block(suite): Not run.
        if (flags[flag] != value) {
          onError(
              "Experiment specified with conflicting values: " + experiment);
        }
      } else {
        if (flag.isExpired) {
          // Coverage-ignore-block(suite): Not run.
          if (value != flag.isEnabledByDefault) {
            /// Produce an error when the value is not the default value.
            if (value) {
              onError("Enabling experiment " +
                  experiment +
                  " is no longer supported.");
            } else {
              onError("Disabling experiment " +
                  experiment +
                  " is no longer supported.");
            }
            value = flag.isEnabledByDefault;
          } else if (onWarning != null) {
            /// Produce a warning when the value is the default value.
            if (value) {
              onWarning("Experiment " +
                  experiment +
                  " is enabled by default. "
                      "The use of the flag is deprecated.");
            } else {
              onWarning("Experiment " +
                  experiment +
                  " is disabled by default. "
                      "The use of the flag is deprecated.");
            }
          }
          flags[flag] = value;
        } else {
          flags[flag] = value;
        }
      }
    }
  }
  return flags;
}

class InvocationMode {
  /// This mode is used for when the CFE is invoked in order to compile an
  /// executable.
  ///
  /// If used, a message about the null safety compilation mode will be emitted.
  static const InvocationMode compile = const InvocationMode('compile');

  final String name;

  const InvocationMode(this.name);

  /// Returns the set of information modes from a comma-separated list of
  /// invocation mode names.
  ///
  /// If a name isn't recognized and [onError] is provided, [onError] is called
  /// with an error messages and an empty set of invocation modes is returned.
  ///
  /// If a name isn't recognized and [onError] isn't provided, an error is
  /// thrown.
  static Set<InvocationMode> parseArguments(String arg,
      {void Function(String)? onError}) {
    Set<InvocationMode> result = {};
    for (String name in arg.split(',')) {
      if (name.isNotEmpty) {
        // Coverage-ignore-block(suite): Not run.
        InvocationMode? mode = fromName(name);
        if (mode == null) {
          String message = "Unknown invocation mode '$name'.";
          if (onError != null) {
            onError(message);
          } else {
            throw new UnsupportedError(message);
          }
        } else {
          result.add(mode);
        }
      }
    }
    return result;
  }

  // Coverage-ignore(suite): Not run.
  /// Returns the [InvocationMode] with the given [name].
  static InvocationMode? fromName(String name) {
    for (InvocationMode invocationMode in values) {
      if (name == invocationMode.name) {
        return invocationMode;
      }
    }
    return null;
  }

  static const List<InvocationMode> values = const [compile];
}

/// Verbosity level used for filtering messages during compilation.
class Verbosity {
  /// Only error messages are emitted.
  static const Verbosity error =
      const Verbosity('error', 'Show only error messages');

  /// Error and warning messages are emitted.
  static const Verbosity warning =
      const Verbosity('warning', 'Show only error and warning messages');

  /// Error, warning, and info messages are emitted.
  static const Verbosity info =
      const Verbosity('info', 'Show error, warning, and info messages');

  /// All messages are emitted.
  static const Verbosity all = const Verbosity('all', 'Show all messages');

  static const List<Verbosity> values = const [error, warning, info, all];

  // Coverage-ignore(suite): Not run.
  /// Returns the names of all options.
  static List<String> get allowedValues =>
      [for (Verbosity value in values) value.name];

  // Coverage-ignore(suite): Not run.
  /// Returns a map from option name to option help messages.
  static Map<String, String> get allowedValuesHelp =>
      {for (Verbosity value in values) value.name: value.help};

  /// Returns the verbosity corresponding to the given [name].
  ///
  /// If [name] isn't recognized and [onError] is provided, [onError] is called
  /// with an error messages and [defaultValue] is returned.
  ///
  /// If [name] isn't recognized and [onError] isn't provided, an error is
  /// thrown.
  static Verbosity parseArgument(String name,
      {void Function(String)? onError,
      Verbosity defaultValue = Verbosity.all}) {
    for (Verbosity verbosity in values) {
      if (name == verbosity.name) {
        return verbosity;
      }
    }
    // Coverage-ignore-block(suite): Not run.
    String message = "Unknown verbosity '$name'.";
    if (onError != null) {
      onError(message);
      return defaultValue;
    }
    throw new UnsupportedError(message);
  }

  // Coverage-ignore(suite): Not run.
  static bool shouldPrint(Verbosity verbosity, DiagnosticMessage message) {
    Severity severity = message.severity;
    switch (verbosity) {
      case Verbosity.error:
        switch (severity) {
          case Severity.internalProblem:
          case Severity.error:
            return true;
          case Severity.warning:
          case Severity.info:
          case Severity.context:
          case Severity.ignored:
            return false;
        }
      case Verbosity.warning:
        switch (severity) {
          case Severity.internalProblem:
          case Severity.error:
          case Severity.warning:
            return true;
          case Severity.info:
          case Severity.context:
          case Severity.ignored:
            return false;
        }
      case Verbosity.info:
        switch (severity) {
          case Severity.internalProblem:
          case Severity.error:
          case Severity.warning:
          case Severity.info:
            return true;
          case Severity.context:
          case Severity.ignored:
            return false;
        }
      case Verbosity.all:
        return true;
    }
    throw new UnsupportedError(
        "Unsupported verbosity $verbosity and severity $severity.");
  }

  static const String defaultValue = 'all';

  final String name;
  final String help;

  const Verbosity(this.name, this.help);

  @override
  String toString() => 'Verbosity($name)';
}

// Coverage-ignore(suite): Not run.
/// Interface for hooking into the compilation pipeline for testing.
class HooksForTesting {
  /// Called before the intermediate macro augmentation libraries have been
  /// replaced by the merged macro augmentation libraries.
  ///
  /// [Component] is the fully built component at this stage of the compilation.
  ///
  /// If macros are not applied, this is not called.
  void beforeMergingMacroAugmentations(Component component) {}

  /// Called after the intermediate macro augmentation libraries have been
  /// replaced by the merged macro augmentation libraries.
  ///
  /// [Component] is the fully built component at this stage of the compilation.
  ///
  /// If macros are not applied, this is not called.
  void afterMergingMacroAugmentations(Component component) {}

  /// Called at the end of full compilation in the `KernelTarget.buildComponent`
  /// method.
  ///
  /// [Component] is the fully built component as returned from
  /// `KernelTarget.buildComponent`.
  void onBuildComponentComplete(Component component) {}
}
