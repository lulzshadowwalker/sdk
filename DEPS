# Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# IMPORTANT:
# Before adding or updating dependencies, please review the documentation here:
# https://github.com/dart-lang/sdk/tree/main/docs/Adding-and-Updating-Dependencies.md
#
# Packages can be rolled to the latest version with `tools/manage_deps.dart`.
#
# For example
#
#     dart tools/manage_deps.dart bump third_party/pkg/dart_style

allowed_hosts = [
  'android.googlesource.com',
  'boringssl.googlesource.com',
  'chrome-infra-packages.appspot.com',
  'chromium.googlesource.com',
  'dart.googlesource.com',
  'dart-internal.googlesource.com',
  'fuchsia.googlesource.com',
  'llvm.googlesource.com',
]

vars = {
  # The dart_root is the root of our sdk checkout. This is normally
  # simply sdk, but if using special gclient specs it can be different.
  "dart_root": "sdk",

  # We use mirrors of all github repos to guarantee reproducibility and
  # consistency between what users see and what the bots see.
  # We need the mirrors to not have 100+ bots pulling github constantly.
  # We mirror our github repos on Dart's git servers.
  # DO NOT use this var if you don't see a mirror here:
  #   https://dart.googlesource.com/
  "dart_git": "https://dart.googlesource.com/",
  "dart_internal_git": "https://dart-internal.googlesource.com",
  # If the repo you want to use is at github.com/dart-lang, but not at
  # dart.googlesource.com, please file an issue
  # on github and add the label 'area-infrastructure'.
  # When the repo is mirrored, you can add it to this DEPS file.

  # Chromium git
  "android_git": "https://android.googlesource.com",
  "chromium_git": "https://chromium.googlesource.com",
  "fuchsia_git": "https://fuchsia.googlesource.com",
  "llvm_git": "https://llvm.googlesource.com",

  # Checked-in SDK version. The checked-in SDK is a Dart SDK distribution
  # in a cipd package used to run Dart scripts in the build and test
  # infrastructure, which is automatically built on the release commits.
  "sdk_tag": "git_revision:7e6469bd51d404916395a47b011d907d2c905121",

  # co19 is a cipd package automatically generated for each co19 commit.
  # Use tests/co19/update.sh to update this hash.
  "co19_rev": "a40b6ef7d12bf9699602253480f16d9f763cd8f2",

  # The internal benchmarks to use. See go/dart-benchmarks-internal
  "benchmarks_internal_rev": "3bd6bc6d207dfb7cf687537e819863cf9a8f2470",
  "checkout_benchmarks_internal": False,

  # Checkout the flute benchmark only when benchmarking.
  "checkout_flute": False,

  # Checkout Android dependencies only on Mac and Linux.
  "download_android_deps":
    "host_os == mac or (host_os == linux and host_cpu == x64)",

  # Checkout extra javascript engines for testing or benchmarking. You can
  # self-service update these by following the go/dart-engprod/browsers.md
  # instructions. d8, the V8 shell, is always checked out.
  "checkout_javascript_engines": False,
  "d8_tag": "version:12.8.142",
  "jsshell_tag": "version:127.0.2",
  "jsc_tag": "version:280364",

  # https://chrome-infra-packages.appspot.com/p/fuchsia/third_party/clang
  "clang_version": "git_revision:3809e20afc68d7d03821f0ec59b928dcf9befbf4",

  # https://chrome-infra-packages.appspot.com/p/gn/gn
  "gn_version": "git_revision:b2afae122eeb6ce09c52d63f67dc53fc517dbdc8",

  "reclient_version": "git_revision:c7349324c93c6e0d85bc1e00b5d7526771006ea0",
  "download_reclient": True,

  # Update from https://chrome-infra-packages.appspot.com/p/fuchsia/sdk/core
  "fuchsia_sdk_version": "version:22.20240730.5.1",
  "download_fuchsia_deps": False,

  # Ninja, runs the build based on files generated by GN.
  "ninja_tag": "version:2@1.11.1.chromium.7",

  # Scripts that make 'git cl format' work.
  "clang_format_scripts_rev": "bb994c6f067340c1135eb43eed84f4b33cfa7397",

  ### /third_party/ dependencies

  # Prefer to use hashes of binaryen that have been reviewed & rolled into g3.
  "binaryen_rev" : "654ee6e2504f11fb0e982a2cf276bafa750f694b",
  "boringssl_gen_rev": "fef055e8d2749b82c79c8f043be1cbe5e8e4b40c",
  "boringssl_rev": "2db0eb3f96a5756298dcd7f9319e56a98585bd10",
  "browser-compat-data_tag": "ac8cae697014da1ff7124fba33b0b4245cc6cd1b", # v1.0.22
  "cpu_features_rev": "936b9ab5515dead115606559502e3864958f7f6e",
  "devtools_rev": "14084d20946268f2d22c5ed55bd53e0176748368",
  "icu_rev": "43953f57b037778a1b8005564afabe214834f7bd",
  "jinja2_rev": "2222b31554f03e62600cd7e383376a7c187967a1",
  "libcxx_rev": "44079a4cc04cdeffb9cfe8067bfb3c276fb2bab0",
  "libcxxabi_rev": "2ce528fb5e0f92e57c97ec3ff53b75359d33af12",
  "libprotobuf_rev": "24487dd1045c7f3d64a21f38a3f0c06cc4cf2edb",
  "markupsafe_rev": "8f45f5cfa0009d2a70589bcda0349b8cb2b72783",
  "perfetto_rev": "13ce0c9e13b0940d2476cd0cff2301708a9a2e2b",
  "ply_rev": "604b32590ffad5cbb82e4afef1d305512d06ae93",
  "protobuf_gn_rev": "ca669f79945418f6229e4fef89b666b2a88cbb10",
  "WebCore_rev": "bcb10901266c884e7b3740abc597ab95373ab55c",
  "zlib_rev": "108fa50cda23ed4a712a098d058dccbbfd248206",

  ### /third_party/pkg dependencies
  # 'tools/rev_sdk_deps.dart' can rev pkg dependencies to their latest; put an
  # EOL comment after a dependency to disable this and pin it at its current
  # revision.

  "args_rev": "1a24d614423e7861ae2e341bfb19050959cef0cd",
  "async_rev": "c0d81f8699682d01d657a9bf827107d11904a247",
  "bazel_worker_rev": "02f190b88df771fc8e05c07d4b64ae942c02f456",
  "benchmark_harness_rev": "a06785cdfc51538e3556c1d59bb4f03426e9e1c5",
  "boolean_selector_rev": "c5468f44fd9ca0ea3435e1a0a84ff9b6fac38261",
  "browser_launcher_rev": "fe7ffa13ba59ec6f7d56256f79059344555fdaf2",
  "characters_rev": "7633a16a22c626e19ca750223237396315268a06",
  "cli_util_rev": "6a0bb9292ea4bb2c9e547af03da4c9948f9556a1",
  "clock_rev": "6e43768a0b135a0d36fc886907b70c4bf27117e6",
  "collection_rev": "0c1f829c29da1d63488be774f430b2035a565d6f",
  "convert_rev": "9035cafefc1da4315f26058734d0c2a19d5ab56a",
  "crypto_rev": "1216790ba704a0ab194f9cd0da2d65e1767f3342",
  "csslib_rev": "192d720f121792ab05ca157ea280edc7e0410e9c",
  # Note: Updates to dart_style have to be coordinated with the infrastructure
  # team so that the internal formatter `tools/sdks/dart-sdk/bin/dart format`
  # matches the version here. Please follow this process to make updates:
  #
  # * Create a commit that updates the version here to the desired version and
  #   adds any appropriate CHANGELOG text.
  # * Send that to eng-prod to review. They will update the checked-in SDK
  #   and land the review.
  #
  # For more details, see https://github.com/dart-lang/sdk/issues/30164.
  "dart_style_rev": "f7bd4c42ad6015143f08931540631448048f692d", # disable tools/rev_sdk_deps.dart
  "dartdoc_rev": "ce098154b16255bbc9ddfa89e3f6141262645513",
  "ecosystem_rev": "f977423b1d9faa2afb34b805e9f28de0b2a657f1",
  "file_rev": "855831c242a17c2dee163828d52710d9043c7c8d",
  "fixnum_rev": "6c19e60366ce3d5edfaed51a7c12c98e7977977e",
  "flute_rev": "a531c96a8b43d015c6bfbbfe3ab54867b0763b8b",
  "glob_rev": "8b05be87f84f74d90dc0c15956f3ff95805322e5",
  "html_rev": "0da420ca1e196cda54ede476d0d8d3ecf55375ef",
  "http_rev": "73fce7763a40920c1ce6cb5d2258d8662813ac9d",
  "http_multi_server_rev": "8348be1bf8fd17881e2643086e68c9d2b28dd9ce",
  "http_parser_rev": "ce528cf82f3d26ac761e29b2494a9e0c270d4939",
  "intl_rev": "5d65e3808ce40e6282e40881492607df4e35669f",
  "json_rpc_2_rev": "b4810dc7bee5828f240586c81f3f34853cacdbce",
  "leak_tracker_rev": "f5620600a5ce1c44f65ddaa02001e200b096e14c", # manually rolled
  "lints_rev": "f6b5d36485f6f067ac0f5a7193006ebe82ee6113",
  "logging_rev": "8752902b75a476d2c7b64dcf01aaaee885f35c4c",
  "markdown_rev": "f6eaea38146d8901756418c4e7123eb7bd77249e",
  "matcher_rev": "d6d573d0f8d65b36550ce62aad3ce6b5e987b642",
  "material_color_utilities_rev": "799b6ba2f3f1c28c67cc7e0b4f18e0c7d7f3c03e",
  "mime_rev": "11fec7d6df509a4efd554051cc27e3bf82df9c96",
  "mockito_rev": "eb4d1daa20c105c94ac29689c1975f0850fa18f2",
  "native_rev": "b01a3f3ef5e3a219fefb182d4cfc41d2895f32ca", # mosum@ and dacoharkes@ are rolling breaking changes manually while the assets features are in experimental.
  "package_config_rev": "f0b72567d85b827aa0f53991fe8a4a8bf36eb479",
  "path_rev": "e969f42ed112dd702a9453beb9df6c12ae2d3805",
  "pool_rev": "924fb04353cec915d927f9f1aed88e2eda92b98a",
  "protobuf_rev": "ccf104dbc36929c0f8708285d5f3a8fae206343e",
  "pub_rev": "570696dd6f7b1e0fb7516eacd197d31542d7168e", # disable tools/rev_sdk_deps.dart
  "pub_semver_rev": "d9e5ee68a350fbf4319bd4dfcb895fc016337d3a",
  "shelf_rev": "9f2dffecbe8f219146a077e401758602752d486a",
  "source_map_stack_trace_rev": "741b6ceb4b6cdb8ff620664337d7ecc63ca52cc1",
  "source_maps_rev": "5f82c613664ade03c7a6d0e6c59687c69dec894b",
  "source_span_rev": "f81cd4a2df630a97264fb4015fb93944b5b98b11",
  "sse_rev": "af2c5c572a8da6d2f7551b80d75121f2a38a4c79",
  "stack_trace_rev": "090d3d186c085fdb913fe5350c666f8d0bd0f60f",
  "stream_channel_rev": "c0c5a978b225d2e02be858e98e24455b7f79b1a0",
  "string_scanner_rev": "a40bbbd83f1176bcc0021b336f5841310f91d8cb",
  "sync_http_rev": "ab8377eba79baff3d77e8c75d502efc2b85a9342",
  "tar_rev": "32ceb55e673141abff4e84b99483fe5eb881c291",
  "term_glyph_rev": "38a158f55006cf30942c928171ea601ee5e0308f",
  "test_rev": "9fbbfdbee18a686e3f84a386a01960ea0543ba01",
  "test_descriptor_rev": "90743bc16bc00526a1b9a64f813614be9b2479d9",
  "test_process_rev": "6223572ca16d7585d5f08d9281de6a5734e45150",
  "test_reflective_loader_rev": "6e648863b39aab8d0204e769d25805eea9db0ac4",
  "tools_rev": "55dbd6e09042bc1b935c019d8e70b3f41e6b90ea",
  "typed_data_rev": "365468a74251c930a463daf5b8f13227e269111a",
  "vector_math_rev": "2cfbe2c115a57b368ccbc3c89ebd38a06764d3d1",
  "watcher_rev": "0484625589d8512b36a7ad898a6cc6351d24c556",
  "web_rev": "e89fe49d8a86845e49686b4578c56b67bdd7ba49",
  "web_socket_channel_rev": "0e1d6e2eb5a0bfd62e45b772ac7107d796176cf6",
  "webdev_rev": "75417c09181c97786d9539a662834bed9d2f1e77",
  "webdriver_rev": "b181c9e5eca657ea4a12621332f47d9579106fda",
  "webkit_inspection_protocol_rev": "119b877ae82bd2ca4cf7e5144d3a5ec104055164",
  "yaml_rev": "a645c3905fc3cc2bbd3def9879ba8dedd26e3aa5",
  "yaml_edit_rev": "5c54d455f272bbb83c948ac420c677371e69ae77",

  # Windows deps
  "crashpad_rev": "bf327d8ceb6a669607b0dbab5a83a275d03f99ed",
  "minichromium_rev": "8d641e30a8b12088649606b912c2bc4947419ccc",
  "googletest_rev": "f854f1d27488996dc8a6db3c9453f80b02585e12",

  # Pinned browser versions used by the testing infrastructure. These are not
  # meant to be downloaded by users for local testing. You can self-service
  # update these by following the go/dart-engprod/browsers.md instructions.
  "download_chrome": False,
  "chrome_tag": "128.0.6613.5",
  "download_firefox": False,
  "firefox_tag": "128.0",

  # Emscripten is used in dart2wasm tests.
  "download_emscripten": False,
  "emsdk_rev": "e41b8c68a248da5f18ebd03bd0420953945d52ff",
  "emsdk_ver": "3.1.3",
}

gclient_gn_args_file = Var("dart_root") + '/build/config/gclient_args.gni'
gclient_gn_args = [
]

deps = {
  # Stuff needed for GN build.
  Var("dart_root") + "/buildtools/clang_format/script":
    Var("chromium_git") + "/chromium/llvm-project/cfe/tools/clang-format.git" +
    "@" + Var("clang_format_scripts_rev"),

  Var("dart_root") + "/benchmarks-internal": {
    "url": Var("dart_internal_git") + "/benchmarks-internal.git" +
           "@" + Var("benchmarks_internal_rev"),
    "condition": "checkout_benchmarks_internal",
  },
  Var("dart_root") + "/tools/sdks/dart-sdk": {
      "packages": [{
          "package": "dart/dart-sdk/${{platform}}",
          "version": Var("sdk_tag"),
      }],
      "dep_type": "cipd",
  },
  Var("dart_root") + "/third_party/d8/linux/x64": {
      "packages": [{
          "package": "dart/third_party/d8/linux-amd64",
          "version": Var("d8_tag"),
      }],
      "dep_type": "cipd",
  },
  Var("dart_root") + "/third_party/d8/linux/arm64": {
      "packages": [{
          "package": "dart/third_party/d8/linux-arm64",
          "version": Var("d8_tag"),
      }],
      "dep_type": "cipd",
  },
  Var("dart_root") + "/third_party/d8/macos/x64": {
      "packages": [{
          "package": "dart/third_party/d8/mac-amd64",
          "version": Var("d8_tag"),
      }],
      "dep_type": "cipd",
  },
  Var("dart_root") + "/third_party/d8/macos/arm64": {
      "packages": [{
          "package": "dart/third_party/d8/mac-arm64",
          "version": Var("d8_tag"),
      }],
      "dep_type": "cipd",
  },
  Var("dart_root") + "/third_party/d8/windows/x64": {
      "packages": [{
          "package": "dart/third_party/d8/windows-amd64",
          "version": Var("d8_tag"),
      }],
      "dep_type": "cipd",
  },
  Var("dart_root") + "/third_party/firefox_jsshell": {
      "packages": [{
          "package": "dart/third_party/jsshell/${{platform}}",
          "version": Var("jsshell_tag"),
      }],
      "condition": "checkout_javascript_engines",
      "dep_type": "cipd",
  },
  Var("dart_root") + "/third_party/jsc": {
      "packages": [{
          "package": "dart/third_party/jsc/${{platform}}",
          "version": Var("jsc_tag"),
      }],
      "condition": "checkout_javascript_engines and host_os == 'linux' and host_cpu == 'x64'",
      "dep_type": "cipd",
  },
  Var("dart_root") + "/third_party/devtools": {
      "packages": [{
          "package": "dart/third_party/flutter/devtools",
          "version": "git_revision:" + Var("devtools_rev"),
      }],
      "dep_type": "cipd",
  },
  Var("dart_root") + "/tests/co19/src": {
      "packages": [{
          "package": "dart/third_party/co19",
          "version": "git_revision:" + Var("co19_rev"),
      }],
      "dep_type": "cipd",
  },
  Var("dart_root") + "/third_party/markupsafe":
      Var("chromium_git") + "/chromium/src/third_party/markupsafe.git" +
      "@" + Var("markupsafe_rev"),
  Var("dart_root") + "/third_party/babel": {
      "packages": [{
          "package": "dart/third_party/babel",
          "version": "version:7.4.5",
      }],
      "dep_type": "cipd",
  },
  Var("dart_root") + "/third_party/zlib":
      Var("chromium_git") + "/chromium/src/third_party/zlib.git" +
      "@" + Var("zlib_rev"),
  Var("dart_root") + "/third_party/cpu_features/src":
      Var("chromium_git") + "/external/github.com/google/cpu_features.git" +
      "@" + Var("cpu_features_rev"),

  Var("dart_root") + "/third_party/libcxx":
      Var("llvm_git") + "/llvm-project/libcxx" + "@" + Var("libcxx_rev"),

  Var("dart_root") + "/third_party/libcxxabi":
      Var("llvm_git") + "/llvm-project/libcxxabi" + "@" + Var("libcxxabi_rev"),

  Var("dart_root") + "/third_party/boringssl":
      Var("dart_git") + "boringssl_gen.git" + "@" + Var("boringssl_gen_rev"),
  Var("dart_root") + "/third_party/boringssl/src":
      "https://boringssl.googlesource.com/boringssl.git" +
      "@" + Var("boringssl_rev"),

  Var("dart_root") + "/third_party/binaryen/src" :
      Var("chromium_git") + "/external/github.com/WebAssembly/binaryen.git" +
      "@" + Var("binaryen_rev"),

  Var("dart_root") + "/third_party/gsutil": {
      "packages": [{
          "package": "infra/3pp/tools/gsutil",
          "version": "version:2@5.5",
      }],
      "dep_type": "cipd",
  },

  Var("dart_root") + "/third_party/emsdk":
      Var("dart_git") + "external/github.com/emscripten-core/emsdk.git" +
      "@" + Var("emsdk_rev"),

  Var("dart_root") + "/third_party/jinja2":
      Var("chromium_git") + "/chromium/src/third_party/jinja2.git" +
      "@" + Var("jinja2_rev"),

  Var("dart_root") + "/third_party/perfetto":
      Var("android_git") + "/platform/external/perfetto" +
      "@" + Var("perfetto_rev"),

  Var("dart_root") + "/third_party/ply":
      Var("chromium_git") + "/chromium/src/third_party/ply.git" +
      "@" + Var("ply_rev"),

  Var("dart_root") + "/build/secondary/third_party/protobuf":
      Var("fuchsia_git") + "/protobuf-gn" +
      "@" + Var("protobuf_gn_rev"),

  Var("dart_root") + "/third_party/protobuf":
      Var("fuchsia_git") + "/third_party/protobuf" +
      "@" + Var("libprotobuf_rev"),

  Var("dart_root") + "/third_party/icu":
      Var("chromium_git") + "/chromium/deps/icu.git" +
      "@" + Var("icu_rev"),

  Var("dart_root") + "/third_party/WebCore":
      Var("dart_git") + "webcore.git" + "@" + Var("WebCore_rev"),

  Var("dart_root") + "/third_party/mdn/browser-compat-data/src":
      Var('chromium_git') + '/external/github.com/mdn/browser-compat-data' +
      "@" + Var("browser-compat-data_tag"),

  Var("dart_root") + "/third_party/pkg/args":
      Var("dart_git") + "args.git" + "@" + Var("args_rev"),
  Var("dart_root") + "/third_party/pkg/async":
      Var("dart_git") + "async.git" + "@" + Var("async_rev"),
  Var("dart_root") + "/third_party/pkg/bazel_worker":
      Var("dart_git") + "bazel_worker.git" + "@" + Var("bazel_worker_rev"),
  Var("dart_root") + "/third_party/pkg/benchmark_harness":
      Var("dart_git") + "benchmark_harness.git" + "@" +
      Var("benchmark_harness_rev"),
  Var("dart_root") + "/third_party/pkg/boolean_selector":
      Var("dart_git") + "boolean_selector.git" +
      "@" + Var("boolean_selector_rev"),
  Var("dart_root") + "/third_party/pkg/browser_launcher":
      Var("dart_git") + "browser_launcher.git" + "@" + Var("browser_launcher_rev"),
  Var("dart_root") + "/third_party/pkg/characters": {
    # Contact athom@ or ensure that license requirements are met before using
    # this dependency in other parts of the Dart SDK.
    "url": Var("dart_git") + "characters.git" + "@" + Var("characters_rev"),
    "condition": "checkout_flute",
  },
  Var("dart_root") + "/third_party/pkg/cli_util":
      Var("dart_git") + "cli_util.git" + "@" + Var("cli_util_rev"),
  Var("dart_root") + "/third_party/pkg/clock":
      Var("dart_git") + "clock.git" + "@" + Var("clock_rev"),
  Var("dart_root") + "/third_party/pkg/collection":
      Var("dart_git") + "collection.git" + "@" + Var("collection_rev"),
  Var("dart_root") + "/third_party/pkg/convert":
      Var("dart_git") + "convert.git" + "@" + Var("convert_rev"),
  Var("dart_root") + "/third_party/pkg/crypto":
      Var("dart_git") + "crypto.git" + "@" + Var("crypto_rev"),
  Var("dart_root") + "/third_party/pkg/csslib":
      Var("dart_git") + "csslib.git" + "@" + Var("csslib_rev"),
  Var("dart_root") + "/third_party/pkg/dart_style":
      Var("dart_git") + "dart_style.git" + "@" + Var("dart_style_rev"),
  Var("dart_root") + "/third_party/pkg/dartdoc":
      Var("dart_git") + "dartdoc.git" + "@" + Var("dartdoc_rev"),
  Var("dart_root") + "/third_party/pkg/ecosystem":
      Var("dart_git") + "ecosystem.git" + "@" + Var("ecosystem_rev"),
  Var("dart_root") + "/third_party/pkg/fixnum":
      Var("dart_git") + "fixnum.git" + "@" + Var("fixnum_rev"),
  Var("dart_root") + "/third_party/flute": {
    "url": Var("dart_git") + "flute.git" + "@" + Var("flute_rev"),
    "condition": "checkout_flute",
  },
  Var("dart_root") + "/third_party/pkg/file":
      Var("dart_git") + "external/github.com/google/file.dart"
      + "@" + Var("file_rev"),
  Var("dart_root") + "/third_party/pkg/glob":
      Var("dart_git") + "glob.git" + "@" + Var("glob_rev"),
  Var("dart_root") + "/third_party/pkg/html":
      Var("dart_git") + "html.git" + "@" + Var("html_rev"),
  Var("dart_root") + "/third_party/pkg/http":
      Var("dart_git") + "http.git" + "@" + Var("http_rev"),
  Var("dart_root") + "/third_party/pkg/http_multi_server":
      Var("dart_git") + "http_multi_server.git" +
      "@" + Var("http_multi_server_rev"),
  Var("dart_root") + "/third_party/pkg/http_parser":
      Var("dart_git") + "http_parser.git" + "@" + Var("http_parser_rev"),
  Var("dart_root") + "/third_party/pkg/intl":
      Var("dart_git") + "intl.git" + "@" + Var("intl_rev"),
  Var("dart_root") + "/third_party/pkg/json_rpc_2":
      Var("dart_git") + "json_rpc_2.git" + "@" + Var("json_rpc_2_rev"),
  Var("dart_root") + "/third_party/pkg/leak_tracker":
      Var("dart_git") + "leak_tracker.git" + "@" + Var("leak_tracker_rev"),
  Var("dart_root") + "/third_party/pkg/lints":
      Var("dart_git") + "lints.git" + "@" + Var("lints_rev"),
  Var("dart_root") + "/third_party/pkg/logging":
      Var("dart_git") + "logging.git" + "@" + Var("logging_rev"),
  Var("dart_root") + "/third_party/pkg/markdown":
      Var("dart_git") + "markdown.git" + "@" + Var("markdown_rev"),
  Var("dart_root") + "/third_party/pkg/matcher":
      Var("dart_git") + "matcher.git" + "@" + Var("matcher_rev"),
  Var("dart_root") + "/third_party/pkg/material_color_utilities": {
    "url": Var("dart_git") +
           "external/github.com/material-foundation/material-color-utilities.git" +
           "@" + Var("material_color_utilities_rev"),
    "condition": "checkout_flute",
  },
  Var("dart_root") + "/third_party/pkg/mime":
      Var("dart_git") + "mime.git" + "@" + Var("mime_rev"),
  Var("dart_root") + "/third_party/pkg/mockito":
      Var("dart_git") + "mockito.git" + "@" + Var("mockito_rev"),
  Var("dart_root") + "/third_party/pkg/native":
      Var("dart_git") + "native.git" + "@" + Var("native_rev"),
  Var("dart_root") + "/third_party/pkg/package_config":
      Var("dart_git") + "package_config.git" +
      "@" + Var("package_config_rev"),
  Var("dart_root") + "/third_party/pkg/path":
      Var("dart_git") + "path.git" + "@" + Var("path_rev"),
  Var("dart_root") + "/third_party/pkg/pool":
      Var("dart_git") + "pool.git" + "@" + Var("pool_rev"),
  Var("dart_root") + "/third_party/pkg/protobuf":
       Var("dart_git") + "protobuf.git" + "@" + Var("protobuf_rev"),
  Var("dart_root") + "/third_party/pkg/pub_semver":
      Var("dart_git") + "pub_semver.git" + "@" + Var("pub_semver_rev"),
  Var("dart_root") + "/third_party/pkg/pub":
      Var("dart_git") + "pub.git" + "@" + Var("pub_rev"),
  Var("dart_root") + "/third_party/pkg/shelf":
      Var("dart_git") + "shelf.git" + "@" + Var("shelf_rev"),
  Var("dart_root") + "/third_party/pkg/source_maps":
      Var("dart_git") + "source_maps.git" + "@" + Var("source_maps_rev"),
  Var("dart_root") + "/third_party/pkg/source_span":
      Var("dart_git") + "source_span.git" + "@" + Var("source_span_rev"),
  Var("dart_root") + "/third_party/pkg/source_map_stack_trace":
      Var("dart_git") + "source_map_stack_trace.git" +
      "@" + Var("source_map_stack_trace_rev"),
  Var("dart_root") + "/third_party/pkg/sse":
      Var("dart_git") + "sse.git" + "@" + Var("sse_rev"),
  Var("dart_root") + "/third_party/pkg/stack_trace":
      Var("dart_git") + "stack_trace.git" + "@" + Var("stack_trace_rev"),
  Var("dart_root") + "/third_party/pkg/stream_channel":
      Var("dart_git") + "stream_channel.git" +
      "@" + Var("stream_channel_rev"),
  Var("dart_root") + "/third_party/pkg/string_scanner":
      Var("dart_git") + "string_scanner.git" +
      "@" + Var("string_scanner_rev"),
  Var("dart_root") + "/third_party/pkg/sync_http":
      Var("dart_git") + "sync_http.git" + "@" + Var("sync_http_rev"),
Var("dart_root") + "/third_party/pkg/tar":
      Var("dart_git") + "external/github.com/simolus3/tar.git" +
      "@" + Var("tar_rev"),
  Var("dart_root") + "/third_party/pkg/term_glyph":
      Var("dart_git") + "term_glyph.git" + "@" + Var("term_glyph_rev"),
  Var("dart_root") + "/third_party/pkg/test":
      Var("dart_git") + "test.git" + "@" + Var("test_rev"),
  Var("dart_root") + "/third_party/pkg/test_descriptor":
      Var("dart_git") + "test_descriptor.git" + "@" + Var("test_descriptor_rev"),
  Var("dart_root") + "/third_party/pkg/test_process":
      Var("dart_git") + "test_process.git" + "@" + Var("test_process_rev"),
  Var("dart_root") + "/third_party/pkg/test_reflective_loader":
      Var("dart_git") + "test_reflective_loader.git" +
      "@" + Var("test_reflective_loader_rev"),
  Var("dart_root") + "/third_party/pkg/tools":
      Var("dart_git") + "tools.git" + "@" + Var("tools_rev"),
  Var("dart_root") + "/third_party/pkg/typed_data":
      Var("dart_git") + "typed_data.git" + "@" + Var("typed_data_rev"),
  Var("dart_root") + "/third_party/pkg/vector_math":
      Var("dart_git") + "external/github.com/google/vector_math.dart.git" +
      "@" + Var("vector_math_rev"),
  Var("dart_root") + "/third_party/pkg/watcher":
      Var("dart_git") + "watcher.git" + "@" + Var("watcher_rev"),
  Var("dart_root") + "/third_party/pkg/webdev":
      Var("dart_git") + "webdev.git" + "@" + Var("webdev_rev"),
  Var("dart_root") + "/third_party/pkg/webdriver":
      Var("dart_git") + "external/github.com/google/webdriver.dart.git" +
      "@" + Var("webdriver_rev"),
  Var("dart_root") + "/third_party/pkg/webkit_inspection_protocol":
      Var("dart_git") + "external/github.com/google/webkit_inspection_protocol.dart.git" +
      "@" + Var("webkit_inspection_protocol_rev"),
  Var("dart_root") + "/third_party/pkg/web":
      Var("dart_git") + "web.git" + "@" + Var("web_rev"),
  Var("dart_root") + "/third_party/pkg/web_socket_channel":
      Var("dart_git") + "web_socket_channel.git" +
      "@" + Var("web_socket_channel_rev"),
  Var("dart_root") + "/third_party/pkg/yaml_edit":
      Var("dart_git") + "yaml_edit.git" + "@" + Var("yaml_edit_rev"),
  Var("dart_root") + "/third_party/pkg/yaml":
      Var("dart_git") + "yaml.git" + "@" + Var("yaml_rev"),

  Var("dart_root") + "/buildtools/sysroot/linux": {
      "packages": [
          {
              "package": "fuchsia/third_party/sysroot/linux",
              "version": "git_revision:fa7a5a9710540f30ff98ae48b62f2cdf72ed2acd",
          },
      ],
      "condition": "host_os == linux",
      "dep_type": "cipd",
  },
  Var("dart_root") + "/buildtools/sysroot/focal": {
      "packages": [
          {
              "package": "fuchsia/third_party/sysroot/focal",
              "version": "git_revision:fa7a5a9710540f30ff98ae48b62f2cdf72ed2acd",
          },
      ],
      "condition": "host_os == linux",
      "dep_type": "cipd",
  },

  # Keep consistent with pkg/test_runner/lib/src/options.dart.
  Var("dart_root") + "/buildtools/linux-x64/clang": {
      "packages": [
          {
              "package": "fuchsia/third_party/clang/linux-amd64",
              "version": Var("clang_version"),
          },
      ],
      "dep_type": "cipd",
  },
  Var("dart_root") + "/buildtools/mac-x64/clang": {
      "packages": [
          {
              "package": "fuchsia/third_party/clang/mac-amd64",
              "version": Var("clang_version"),
          },
      ],
      "condition": "host_os == mac", # On ARM64 Macs too because Goma doesn't support the host-arm64 toolchain.
      "dep_type": "cipd",
  },
  Var("dart_root") + "/buildtools/win-x64/clang": {
      "packages": [
          {
              "package": "fuchsia/third_party/clang/windows-amd64",
              "version": Var("clang_version"),
          },
      ],
      "condition": "host_os == win", # On ARM64 Windows too because Fuchsia doesn't provide the host-arm64 toolchain.
      "dep_type": "cipd",
  },
  Var("dart_root") + "/buildtools/linux-arm64/clang": {
      "packages": [
          {
              "package": "fuchsia/third_party/clang/linux-arm64",
              "version": Var("clang_version"),
          },
      ],
      "condition": "host_os == 'linux' and host_cpu == 'arm64'",
      "dep_type": "cipd",
  },
  Var("dart_root") + "/buildtools/mac-arm64/clang": {
      "packages": [
          {
              "package": "fuchsia/third_party/clang/mac-arm64",
              "version": Var("clang_version"),
          },
      ],
      "condition": "host_os == 'mac' and host_cpu == 'arm64'",
      "dep_type": "cipd",
  },

  Var("dart_root") + '/buildtools/reclient': {
    'packages': [
      {
        'package': 'infra/rbe/client/${{platform}}',
        'version': Var('reclient_version'),
      }
    ],
    # Download reclient only on the platforms where it has packages available.
    # Unfortunately windows-arm64 gclient uses x64 python which lies in
    # host_cpu, so we have to use a variable to not download reclient there.
    'condition': 'download_reclient and (((host_os == "linux" or host_os == "mac" or host_os == "win") and host_cpu == "x64") or (host_os == "mac" and host_cpu == "arm64"))',
    'dep_type': 'cipd',
  },

  Var("dart_root") + "/third_party/webdriver/chrome": {
    "packages": [
      {
        "package": "dart/third_party/chromedriver/${{platform}}",
        "version": "version:" + Var("chrome_tag"),
      }
    ],
    "condition": "download_chrome",
    "dep_type": "cipd",
  },

  Var("dart_root") + "/buildtools": {
      "packages": [
          {
              "package": "gn/gn/${{platform}}",
              "version": Var("gn_version"),
          },
      ],
      "condition": "host_os != 'win'",
      "dep_type": "cipd",
  },
  Var("dart_root") + "/buildtools/win": {
      "packages": [
          {
              "package": "gn/gn/windows-amd64",
              "version": Var("gn_version"),
          },
      ],
      "condition": "host_os == 'win'",
      "dep_type": "cipd",
  },

  Var("dart_root") + "/buildtools/ninja": {
      "packages": [{
          "package": "infra/3pp/tools/ninja/${{platform}}",
          "version": Var("ninja_tag"),
      }],
      "dep_type": "cipd",
  },

  Var("dart_root") + "/third_party/android_tools/ndk": {
      "packages": [
          {
            "package": "flutter/android/ndk/${{os}}-amd64",
            "version": "version:r27.0.10869015"
          }
      ],
      "condition": "download_android_deps",
      "dep_type": "cipd",
  },
  Var("dart_root") + "/third_party/android_tools/sdk/platform-tools": {
      "packages": [
          {
            "package": "flutter/android/sdk/platform-tools/linux-amd64",
            "version": "1tZc4sOxZS6FQIvT5i0wwdycmM8AO7QZY32FC9_HfR4C"
          }
      ],
      "condition": "download_android_deps",
      "dep_type": "cipd",
  },

  Var("dart_root") + "/third_party/fuchsia/sdk/linux": {
    "packages": [
      {
      "package": "fuchsia/sdk/core/${{platform}}",
      "version": Var("fuchsia_sdk_version"),
      }
    ],
    "condition": 'download_fuchsia_deps and host_os == "linux"',
    "dep_type": "cipd",
  },

  Var("dart_root") + "/third_party/fuchsia/test_scripts": {
    "packages": [
      {
      "package": "chromium/fuchsia/test-scripts",
      "version": "EAdD2YcYwVrhF2q_zR6xUvPkcKlPb1tJyM_6_oOc84kC",
      }
    ],
    "condition": 'download_fuchsia_deps',
    "dep_type": "cipd",
  },

  Var("dart_root") + "/third_party/fuchsia/gn-sdk": {
    "packages": [
      {
      "package": "chromium/fuchsia/gn-sdk",
      "version": "sbh76PYVTMxav4ACTgA-TXWcbZTZcWWjsqATCxrGIvwC",
      }
    ],
    "condition": 'download_fuchsia_deps',
    "dep_type": "cipd",
  },

  Var("dart_root") + "/pkg/front_end/test/fasta/types/benchmark_data": {
    "packages": [
      {
        "package": "dart/cfe/benchmark_data",
        "version": "sha1sum:5b6e6dfa33b85c733cab4e042bf46378984d1544",
      }
    ],
    "dep_type": "cipd",
  },

  # TODO(37531): Remove these cipd packages and build with sdk instead when
  # benchmark runner gets support for that.
  Var("dart_root") + "/benchmarks/FfiBoringssl/native/out/": {
      "packages": [
          {
              "package": "dart/benchmarks/ffiboringssl",
              "version": "commit:a86c69888b9a416f5249aacb4690a765be064969",
          },
      ],
      "dep_type": "cipd",
  },
  Var("dart_root") + "/benchmarks/FfiCall/native/out/": {
      "packages": [
          {
              "package": "dart/benchmarks/fficall",
              "version": "ebF5aRXKDananlaN4Y8b0bbCNHT1MnkGbWqfpCpiND4C",
          },
      ],
          "dep_type": "cipd",
  },
  Var("dart_root") + "/benchmarks/NativeCall/native/out/": {
      "packages": [
          {
              "package": "dart/benchmarks/nativecall",
              "version": "w1JKzCIHSfDNIjqnioMUPq0moCXKwX67aUfhyrvw4E0C",
          },
      ],
          "dep_type": "cipd",
  },
  Var("dart_root") + "/third_party/browsers/chrome": {
      "packages": [
          {
              "package": "dart/browsers/chrome/${{platform}}",
              "version": "version:" + Var("chrome_tag"),
          },
      ],
      "condition": "download_chrome",
      "dep_type": "cipd",
  },
  Var("dart_root") + "/third_party/browsers/firefox": {
      "packages": [
          {
              "package": "dart/browsers/firefox/${{platform}}",
              "version": "version:" + Var("firefox_tag"),
          },
      ],
      "condition": "download_firefox",
      "dep_type": "cipd",
  },
}

deps_os = {
  "win": {
    Var("dart_root") + "/third_party/cygwin":
        Var("chromium_git") + "/chromium/deps/cygwin.git" + "@" +
        "c89e446b273697fadf3a10ff1007a97c0b7de6df",
    Var("dart_root") + "/third_party/crashpad/crashpad":
        Var("chromium_git") + "/crashpad/crashpad.git" + "@" +
        Var("crashpad_rev"),
    Var("dart_root") + "/third_party/mini_chromium/mini_chromium":
        Var("chromium_git") + "/chromium/mini_chromium" + "@" +
        Var("minichromium_rev"),
    Var("dart_root") + "/third_party/googletest":
        Var("fuchsia_git") + "/third_party/googletest" + "@" +
        Var("googletest_rev"),
  }
}

hooks = [
  {
    # Generate the .dart_tool/package_confg.json file.
    'name': 'Generate .dart_tool/package_confg.json',
    'pattern': '.',
    'action': ['python3', 'sdk/tools/generate_package_config.py'],
  },
  {
    # Generate the sdk/version file.
    'name': 'Generate sdk/version',
    'pattern': '.',
    'action': ['python3', 'sdk/tools/generate_sdk_version_file.py'],
  },
  {
    'name': 'buildtools',
    'pattern': '.',
    'action': ['python3', 'sdk/tools/buildtools/update.py'],
  },
  {
    # Update the Windows toolchain if necessary.
    'name': 'win_toolchain',
    'pattern': '.',
    'action': ['python3', 'sdk/build/vs_toolchain.py', 'update'],
    'condition': 'checkout_win'
  },
  # Install and activate the empscripten SDK.
  {
    'name': 'install_emscripten',
    'pattern': '.',
    'action': ['python3', 'sdk/third_party/emsdk/emsdk.py', 'install',
        Var('emsdk_ver')],
    'condition': 'download_emscripten'
  },
  {
    'name': 'activate_emscripten',
    'pattern': '.',
    'action': ['python3', 'sdk/third_party/emsdk/emsdk.py', 'activate',
        Var('emsdk_ver')],
    'condition': 'download_emscripten'
  },
  {
    'name': 'Erase arch/ from fuchsia sdk',
    'pattern': '.',
    'action': [
      'rm',
      '-rf',
      'sdk/third_party/fuchsia/sdk/linux/arch',
    ],
    'condition': 'download_fuchsia_deps'
  },
  {
    'name': 'Download Fuchsia system images',
    'pattern': '.',
    'action': [
      'python3',
      'sdk/build/fuchsia/with_envs.py',
      'sdk/third_party/fuchsia/test_scripts/update_product_bundles.py',
      'terminal.x64,terminal.qemu-arm64',
    ],
    'condition': 'download_fuchsia_deps'
  },
  {
    'name': 'Generate Fuchsia GN build rules',
    'pattern': '.',
    'action': [
      'python3',
      'sdk/build/fuchsia/with_envs.py',
      'sdk/third_party/fuchsia/test_scripts/gen_build_defs.py',
    ],
    'condition': 'download_fuchsia_deps'
  },
]
