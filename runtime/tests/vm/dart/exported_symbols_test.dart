// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "dart:io";
import "package:expect/expect.dart";

import "use_flag_test_helper.dart";

main() {
  if (Platform.isWindows) return;
  if (Platform.isAndroid) return; // no nm available on test device

  var nm;
  for (var path in [
    if (Platform.isLinux) ...[
      "buildtools/linux-arm64/clang/bin/llvm-nm",
      "buildtools/linux-x64/clang/bin/llvm-nm",
    ],
    if (Platform.isMacOS) ...[
      "buildtools/mac-arm64/clang/bin/llvm-nm",
      "buildtools/mac-x64/clang/bin/llvm-nm",
    ],
  ]) {
    if (new File(path).existsSync()) {
      nm = path;
      break;
    }
  }
  if (nm == null) {
    throw "Could not find nm";
  }

  var result = Process.runSync(nm, [
    Platform.isMacOS ? "--extern-only" : "--dynamic",
    "--defined-only",
    "--format=just-symbols",
    Platform.executable
  ]);
  if (result.exitCode != 0) {
    print("nm failed");
    print(result.stdout);
    print(result.stderr);
    throw "nm failed";
  }

  var symbols = result.stdout.split("\n")..remove("");
  if (Platform.isMacOS) {
    // Remove leading underscores.
    for (var i = 0; i < symbols.length; i++) {
      symbols[i] = symbols[i].substring(1);
    }
  }
  symbols.remove("_IO_stdin_used"); // Only on IA32 for libc.
  print(symbols);

  var expectedSymbols = [
    "Dart_AddSymbols",
    "Dart_Allocate",
    "Dart_AllocateWithNativeFields",
    "Dart_BooleanValue",
    "Dart_ClassLibrary",
    "Dart_ClassName",
    "Dart_Cleanup",
    "Dart_CloseNativePort",
    "Dart_ClosureFunction",
    "Dart_CompileAll",
    "Dart_CompileToKernel",
    "Dart_CreateAppAOTSnapshotAsAssemblies",
    "Dart_CreateAppAOTSnapshotAsAssembly",
    "Dart_CreateAppAOTSnapshotAsElf",
    "Dart_CreateAppAOTSnapshotAsElfs",
    "Dart_CreateAppJITSnapshotAsBlobs",
    "Dart_CreateIsolateGroup",
    "Dart_CreateIsolateGroupFromKernel",
    "Dart_CreateIsolateInGroup",
    "Dart_CreateSnapshot",
    "Dart_CreateVMAOTSnapshotAsAssembly",
    "Dart_CurrentIsolate",
    "Dart_CurrentIsolateData",
    "Dart_CurrentIsolateGroup",
    "Dart_CurrentIsolateGroupData",
    "Dart_CurrentIsolateGroupId",
    "Dart_DebugName",
    "Dart_DebugNameToCString",
    "Dart_DefaultCanonicalizeUrl",
    "Dart_DeferredLoadComplete",
    "Dart_DeferredLoadCompleteError",
    "Dart_DeleteFinalizableHandle",
    "Dart_DeletePersistentHandle",
    "Dart_DeleteWeakPersistentHandle",
    "Dart_DetectNullSafety",
    "Dart_DisableHeapSampling",
    "Dart_DoubleValue",
    "Dart_DumpNativeStackTrace",
    "Dart_EmptyString",
    "Dart_EnableHeapSampling",
    "Dart_EnterIsolate",
    "Dart_EnterScope",
    "Dart_ErrorGetException",
    "Dart_ErrorGetStackTrace",
    "Dart_ErrorHasException",
    "Dart_ExecuteInternalCommand",
    "Dart_ExitIsolate",
    "Dart_ExitScope",
    "Dart_False",
    "Dart_FinalizeAllClasses",
    "Dart_FinalizeLoading",
    "Dart_FunctionIsStatic",
    "Dart_FunctionName",
    "Dart_FunctionOwner",
    "Dart_GetClass",
    "Dart_GetCurrentUserTag",
    "Dart_GetDataFromByteBuffer",
    "Dart_GetDefaultUserTag",
    "Dart_GetError",
    "Dart_GetField",
    "Dart_GetLoadedLibraries",
    "Dart_GetMainPortId",
    "Dart_GetMessageNotifyCallback",
    "Dart_GetNativeArgument",
    "Dart_GetNativeArgumentCount",
    "Dart_GetNativeArguments",
    "Dart_GetNativeBooleanArgument",
    "Dart_GetNativeDoubleArgument",
    "Dart_GetNativeFieldsOfArgument",
    "Dart_GetNativeInstanceField",
    "Dart_GetNativeInstanceFieldCount",
    "Dart_GetNativeIntegerArgument",
    "Dart_GetNativeIsolateGroupData",
    "Dart_GetNativeReceiver",
    "Dart_GetNativeResolver",
    "Dart_GetNativeStringArgument",
    "Dart_GetNativeSymbol",
    "Dart_GetNonNullableType",
    "Dart_GetNullableType",
    "Dart_GetObfuscationMap",
    "Dart_GetPeer",
    "Dart_GetStaticMethodClosure",
    "Dart_GetStickyError",
    "Dart_GetType",
    "Dart_GetTypeOfExternalTypedData",
    "Dart_GetTypeOfTypedData",
    "Dart_GetUserTagLabel",
    "Dart_HandleFromPersistent",
    "Dart_HandleFromWeakPersistent",
    "Dart_HandleMessage",
    "Dart_HandleServiceMessages",
    "Dart_HasLivePorts",
    "Dart_HasServiceMessages",
    "Dart_HasStickyError",
    "Dart_IdentityEquals",
    "Dart_Initialize",
    "Dart_InstanceGetType",
    "Dart_IntegerFitsIntoInt64",
    "Dart_IntegerFitsIntoUint64",
    "Dart_IntegerToHexCString",
    "Dart_IntegerToInt64",
    "Dart_IntegerToUint64",
    "Dart_Invoke",
    "Dart_InvokeClosure",
    "Dart_InvokeConstructor",
    "Dart_InvokeVMServiceMethod",
    "Dart_IsApiError",
    "Dart_IsBoolean",
    "Dart_IsByteBuffer",
    "Dart_IsClosure",
    "Dart_IsCompilationError",
    "Dart_IsDouble",
    "Dart_IsError",
    "Dart_IsExternalString",
    "Dart_IsFatalError",
    "Dart_IsFunction",
    "Dart_IsFuture",
    "Dart_IsInstance",
    "Dart_IsInteger",
    "Dart_IsKernel",
    "Dart_IsKernelIsolate",
    "Dart_IsLegacyType",
    "Dart_IsLibrary",
    "Dart_IsList",
    "Dart_IsMap",
    "Dart_IsNonNullableType",
    "Dart_IsNull",
    "Dart_IsNullableType",
    "Dart_IsNumber",
    "Dart_IsolateData",
    "Dart_IsolateFlagsInitialize",
    "Dart_IsolateGroupData",
    "Dart_IsolateGroupHeapNewCapacityMetric",
    "Dart_IsolateGroupHeapNewExternalMetric",
    "Dart_IsolateGroupHeapNewUsedMetric",
    "Dart_IsolateGroupHeapOldCapacityMetric",
    "Dart_IsolateGroupHeapOldExternalMetric",
    "Dart_IsolateGroupHeapOldUsedMetric",
    "Dart_IsolateMakeRunnable",
    "Dart_IsolateRunnableHeapSizeMetric",
    "Dart_IsolateRunnableLatencyMetric",
    "Dart_IsolateServiceId",
    "Dart_IsPausedOnExit",
    "Dart_IsPausedOnStart",
    "Dart_IsPrecompiledRuntime",
    "Dart_IsReloading",
    "Dart_IsServiceIsolate",
    "Dart_IsString",
    "Dart_IsStringLatin1",
    "Dart_IsTearOff",
    "Dart_IsType",
    "Dart_IsTypedData",
    "Dart_IsTypeVariable",
    "Dart_IsUnhandledExceptionError",
    "Dart_IsVariable",
    "Dart_IsVMFlagSet",
    "Dart_KernelIsolateIsRunning",
    "Dart_KernelListDependencies",
    "Dart_KernelPort",
    "Dart_KillIsolate",
    "Dart_LibraryHandleError",
    "Dart_LibraryResolvedUrl",
    "Dart_LibraryUrl",
    "Dart_ListGetAsBytes",
    "Dart_ListGetAt",
    "Dart_ListGetRange",
    "Dart_ListLength",
    "Dart_ListSetAsBytes",
    "Dart_ListSetAt",
    "Dart_LoadingUnitLibraryUris",
    "Dart_LoadLibrary",
    "Dart_LoadLibraryFromKernel",
    "Dart_LoadScriptFromKernel",
    "Dart_LookupLibrary",
    "Dart_MapContainsKey",
    "Dart_MapGetAt",
    "Dart_MapKeys",
    "Dart_New",
    "Dart_NewApiError",
    "Dart_NewBoolean",
    "Dart_NewByteBuffer",
    "Dart_NewCompilationError",
    "Dart_NewDouble",
    "Dart_NewExternalLatin1String",
    "Dart_NewExternalTypedData",
    "Dart_NewExternalTypedDataWithFinalizer",
    "Dart_NewExternalUTF16String",
    "Dart_NewFinalizableHandle",
    "Dart_NewInteger",
    "Dart_NewIntegerFromHexCString",
    "Dart_NewIntegerFromUint64",
    "Dart_NewList",
    "Dart_NewListOf",
    "Dart_NewListOfType",
    "Dart_NewListOfTypeFilled",
    "Dart_NewNativePort",
    "Dart_NewPersistentHandle",
    "Dart_NewSendPort",
    "Dart_NewStringFromCString",
    "Dart_NewStringFromUTF16",
    "Dart_NewStringFromUTF32",
    "Dart_NewStringFromUTF8",
    "Dart_NewTypedData",
    "Dart_NewUnhandledExceptionError",
    "Dart_NewUnmodifiableExternalTypedDataWithFinalizer",
    "Dart_NewUserTag",
    "Dart_NewWeakPersistentHandle",
    "Dart_NotifyDestroyed",
    "Dart_NotifyIdle",
    "Dart_NotifyLowMemory",
    "Dart_Null",
    "Dart_ObjectEquals",
    "Dart_ObjectIsType",
    "Dart_Post",
    "Dart_PostCObject",
    "Dart_PostInteger",
    "Dart_Precompile",
    "Dart_PrepareToAbort",
    "Dart_PropagateError",
    "Dart_RecordTimelineEvent",
    "Dart_RegisterHeapSamplingCallback",
    "Dart_RegisterIsolateServiceRequestCallback",
    "Dart_RegisterRootServiceRequestCallback",
    "Dart_ReportSurvivingAllocations",
    "Dart_ReThrowException",
    "Dart_RootLibrary",
    "Dart_RunLoop",
    "Dart_RunLoopAsync",
    "Dart_ScopeAllocate",
    "Dart_SendPortGetId",
    "Dart_ServiceSendDataEvent",
    "Dart_SetBooleanReturnValue",
    "Dart_SetCurrentUserTag",
    "Dart_SetDartLibrarySourcesKernel",
    "Dart_SetDeferredLoadHandler",
    "Dart_SetDoubleReturnValue",
    "Dart_SetDwarfStackTraceFootnoteCallback",
    "Dart_SetEmbedderInformationCallback",
    "Dart_SetEnabledTimelineCategory",
    "Dart_SetEnvironmentCallback",
    "Dart_SetFfiNativeResolver",
    "Dart_SetField",
    "Dart_SetFileModifiedCallback",
    "Dart_SetHeapSamplingPeriod",
    "Dart_SetIntegerReturnValue",
    "Dart_SetLibraryTagHandler",
    "Dart_SetMessageNotifyCallback",
    "Dart_SetNativeInstanceField",
    "Dart_SetNativeResolver",
    "Dart_SetPausedOnExit",
    "Dart_SetPausedOnStart",
    "Dart_SetPeer",
    "Dart_SetPerformanceMode",
    "Dart_SetPersistentHandle",
    "Dart_SetReturnValue",
    "Dart_SetRootLibrary",
    "Dart_SetServiceStreamCallbacks",
    "Dart_SetShouldPauseOnExit",
    "Dart_SetShouldPauseOnStart",
    "Dart_SetStickyError",
    "Dart_SetThreadName",
    "Dart_SetTimelineRecorderCallback",
    "Dart_SetVMFlags",
    "Dart_SetWeakHandleReturnValue",
    "Dart_ShouldPauseOnExit",
    "Dart_ShouldPauseOnStart",
    "Dart_ShutdownIsolate",
    "Dart_SortClasses",
    "Dart_StartProfiling",
    "Dart_StopProfiling",
    "Dart_StringGetProperties",
    "Dart_StringLength",
    "Dart_StringUTF8Length",
    "Dart_StringStorageSize",
    "Dart_StringToCString",
    "Dart_StringToLatin1",
    "Dart_StringToUTF16",
    "Dart_StringToUTF8",
    "Dart_CopyUTF8EncodingOfString",
    "Dart_ThreadDisableProfiling",
    "Dart_ThreadEnableProfiling",
    "Dart_ThrowException",
    "Dart_TimelineEvent",
    "Dart_TimelineGetMicros",
    "Dart_TimelineGetTicks",
    "Dart_TimelineGetTicksFrequency",
    "Dart_ToString",
    "Dart_True",
    "Dart_TypedDataAcquireData",
    "Dart_TypedDataReleaseData",
    "Dart_TypeDynamic",
    "Dart_TypeNever",
    "Dart_TypeToNonNullableType",
    "Dart_TypeToNullableType",
    "Dart_TypeVoid",
    "Dart_VersionString",
    "Dart_WaitForEvent",
    "Dart_WriteHeapSnapshot",
    "Dart_WriteProfileToTimeline",
  ];

  if (isAOTRuntime) {
    expectedSymbols.addAll([
      "Dart_LoadELF",
      "Dart_LoadELF_Memory",
      "Dart_UnloadELF",
    ]);
    if (!Platform.isMacOS) {
      expectedSymbols.addAll([
        "Dart_LoadELF_Fd",
      ]);
    }
  }

  Expect.setEquals(expectedSymbols, symbols);
}
