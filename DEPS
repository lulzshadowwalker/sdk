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
  "sdk_tag": "version:3.4.0-247.0.dev",

  # co19 is a cipd package automatically generated for each co19 commit.
  # Use tests/co19/update.sh to update this hash.
  "co19_rev": "3b6147cd64211dace7ea86b9bab7ba48f4a328d2",

  # The internal benchmarks to use. See go/dart-benchmarks-internal
  "benchmarks_internal_rev": "a7c23b2422492dcc515d1ba4abe3609b50e2a139",
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
  "d8_tag": "version:12.6.163",
  "jsshell_tag": "version:125.0.3",
  "jsc_tag": "version:278398",

  # https://chrome-infra-packages.appspot.com/p/fuchsia/third_party/clang
  "clang_version": "git_revision:0f61051f541a5b8cfce25c84262dfdbadb9ca688",

  # https://chrome-infra-packages.appspot.com/p/gn/gn
  "gn_version": "git_revision:f284b6b47039a2d7edfcbfc51f52664f82b5a789",

  "reclient_version": "git_revision:c7349324c93c6e0d85bc1e00b5d7526771006ea0",
  "download_reclient": True,

  # Update from https://chrome-infra-packages.appspot.com/p/fuchsia/sdk/core
  "fuchsia_sdk_version": "version:19.20240327.2.1",
  "download_fuchsia_deps": False,

  # Ninja, runs the build based on files generated by GN.
  "ninja_tag": "version:2@1.11.1.chromium.7",

  # Scripts that make 'git cl format' work.
  "clang_format_scripts_rev": "bb994c6f067340c1135eb43eed84f4b33cfa7397",

  ### /third_party/ dependencies

  # Prefer to use hashes of binaryen that have been reviewed & rolled into g3.
  "binaryen_rev" : "d844d2e77b402d562ade8cf8fd96759b587bf09d",
  "boringssl_gen_rev": "9c7294fd58261a79794f5afaa26598cf1442ad20",
  "boringssl_rev": "d24a38200fef19150eef00cad35b138936c08767",
  "browser-compat-data_tag": "ac8cae697014da1ff7124fba33b0b4245cc6cd1b", # v1.0.22
  "cpu_features_rev": "936b9ab5515dead115606559502e3864958f7f6e",
  "devtools_rev": "a53696352fe1508c18d908a85b68c113b11dbe58",
  "icu_rev": "81d656878ec611cb0b42d52c82e9dae93920d9ba",
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

  "args_rev": "cf905519d67054a5e8d8835ffd4b247d8bbb602d",
  "async_rev": "77a25d77392b131df4ecac85bcfe9a30f82a9f40",
  "bazel_worker_rev": "2fb4fbff6ee8d26fee1f3576fa0500057d897afd",
  "benchmark_harness_rev": "accc7552b5fc0ba38493707635dc9e1ce7b90f12",
  "boolean_selector_rev": "2cbd4a60b89fe51a404e9ee3625a8fb8019561dd",
  "browser_launcher_rev": "0dcf2246c11eaf6c4f2591332f1057734a847793",
  "characters_rev": "7633a16a22c626e19ca750223237396315268a06",
  "cli_util_rev": "9fe3eeb8a2fad6da9a156055207337474436da12",
  "clock_rev": "80e70acf72cc3a876d3158911b097b581cd8fd1a",
  "collection_rev": "471839875a3bbfb26a7d51eca82be5b788660982",
  "convert_rev": "056626e0cddd56c4cc1184aac787ba06ecdaae3a",
  "crypto_rev": "3f815aca8ad5020bb39be09ec9bfd75c36910809",
  "csslib_rev": "141dd6567651500bb8c17ccb65e3c9e117c64035",
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
  "dart_style_rev": "a6ad7693555a9add6f98ad6fd94de80d35c89415", # disable tools/rev_sdk_deps.dart
  "dartdoc_rev": "1e1a004c69022ae19e121b6b9c90039dccd56749",
  "ecosystem_rev": "ad9da1557bbf522ff5bd25aa83117aeb818160c9",
  "file_rev": "8ce0d13ffe9dac267bdbd6c65c145ba4f611af72",
  "fixnum_rev": "ac892adead8317e22fafaec65a4e76bda1640f26",
  "flute_rev": "a531c96a8b43d015c6bfbbfe3ab54867b0763b8b",
  "glob_rev": "ee48ea82a1ccb64c8cc62e9f4f44c44ca67add71",
  "html_rev": "00d34611eee5eff976bd12a631357a4d591ef5fb",
  "http_rev": "6337ee3f6d1f641192ba40e133f27085c69aa815",
  "http_multi_server_rev": "4a791af861da1cf53b57d9928fbc605f57139e4f",
  "http_parser_rev": "702698a3fc726f7cbb8cd7824a8639c7fe84b169",
  "intl_rev": "5d65e3808ce40e6282e40881492607df4e35669f",
  "json_rpc_2_rev": "3187f7b59ed253d14b2560c5306b037bca6817b0",
  "leak_tracker_rev": "f5620600a5ce1c44f65ddaa02001e200b096e14c", # manually rolled
  "lints_rev": "b254c7e374b0328d4ebfe4f32638fd5e58a81b59",
  "logging_rev": "49d89b1de6e847174bc93b709e858b99e61b2ae7",
  "markdown_rev": "340c76f6cab697ca9a51e0772009347400d9488a",
  "matcher_rev": "4ac4096facce24a781ab6609ca99995aeb443b25",
  "material_color_utilities_rev": "799b6ba2f3f1c28c67cc7e0b4f18e0c7d7f3c03e",
  "mime_rev": "b01c9a24e0991da479bd405138be3b3e403ff456",
  "mockito_rev": "2302814df66e651b6710311366501523dbee2e11",
  "native_rev": "fef40aebc3cf34654919e8a5785b6c50b3ea445c", # mosum@ and dacoharkes@ are rolling breaking changes manually while the assets features are in experimental.
  "package_config_rev": "39096768806ccae4b7025dd4114f15f2df424b0c",
  "path_rev": "aea50fa0e997e0401ea271783dddd364ce72f924",
  "pool_rev": "1a6f2df19d7a24baaf674e032a0310a4f76725de",
  "protobuf_rev": "ccf104dbc36929c0f8708285d5f3a8fae206343e",
  "pub_rev": "75ab224376e80e918d3c53494a36d4bf8a2f2af6", # disable tools/rev_sdk_deps.dart
  "pub_semver_rev": "f57c9c31dfd4e45ce6b11f18ee388e526ba1792a",
  "shelf_rev": "d9f82bf2cdd87e2878cfdc167aa41b9ce87a52d8",
  "source_map_stack_trace_rev": "6834af5e9e4ba880741b1357a5967fee8d90827c",
  "source_maps_rev": "181a41c10668801486c53b48d6fce42fea5c9eca",
  "source_span_rev": "e80cb44fc0f8d284e86372c9c98bbdd958810beb",
  "sse_rev": "1bb0a98da769793efe7495e08c947515dc48e42e",
  "stack_trace_rev": "4d346f70990f3e2fe1fbfbbaa537b9ae8760f25e",
  "stream_channel_rev": "61ad87242146c54cbe90f1cb436e830ae873925b",
  "string_scanner_rev": "32468bdd9a2baefe2fbcae31ac21daca9e2a8bde",
  "sync_http_rev": "82553db87ae0292d4cb35aa9db6ea2a5451fcb92",
  "tar_rev": "b62573f39a4de28f69d9ed82b02fbd96b12b9633",
  "term_glyph_rev": "a46b48bd28c724e3cd6c18464e1d5ce823601488",
  "test_rev": "2464ad5c5945c98edd33fb69b3616a14771f1c8d",
  "test_descriptor_rev": "d61bf6cbccf8020d4dd2f1d8c91fb21c4be16290",
  "test_process_rev": "4ab3f1cedd4b5d971fd78bbccbce97de43be52b7",
  "test_reflective_loader_rev": "f8807e0e5816e30ab592424e3916fee90b90623e",
  "tools_rev": "86b3661fc4ccbcda5b662ff3075177448eeeba11",
  "typed_data_rev": "fb1958ca880d650972e124222d3d9e41bd35c76c",
  "vector_math_rev": "43f2a77bb0be812b027a68a11792d563713b42a1",
  "watcher_rev": "c182cd3db6f0bc285bf5da52df422f5c64f21a37",
  "web_rev": "d7766451f43001276b5493b2261d2973702b8334",
  "web_socket_channel_rev": "45b8ce9ce9fb5194a24d3dff8913c573fbe7896a",
  "webdev_rev": "fc32eb69f2ad666e9ab1cb3300510e5daed222d6",
  "webdriver_rev": "f85779edd7c9f66198d4391ed3631db1d97a5b11",
  "webkit_inspection_protocol_rev": "5740cc91eaeb13a02007b77b128fccf4b056db6e",
  "yaml_rev": "8fb8147e40236bdefd02abbca7b92ddfd7ca0749",
  "yaml_edit_rev": "31919348bd2a1bbb805b4eb88a6b7f50d4ab247e",

  # Windows deps
  "crashpad_rev": "bf327d8ceb6a669607b0dbab5a83a275d03f99ed",
  "minichromium_rev": "8d641e30a8b12088649606b912c2bc4947419ccc",
  "googletest_rev": "f854f1d27488996dc8a6db3c9453f80b02585e12",

  # Pinned browser versions used by the testing infrastructure. These are not
  # meant to be downloaded by users for local testing. You can self-service
  # update these by following the go/dart-engprod/browsers.md instructions.
  "download_chrome": False,
  "chrome_tag": "121.0.6167.85",
  "download_firefox": False,
  "firefox_tag": "126.0",

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
      "version": "RgErspyYHapUO2SpcW-vo2p8yaRUMUrq0eWjRVPfQjoC",
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
