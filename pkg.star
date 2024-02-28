# Copyright (c) 2023 The Dart project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
"""
Defines the pkg builders.
"""

load("//lib/dart.star", "dart")
load(
    "//lib/defaults.star",
    "arm64",
    "chrome",
    "flutter_pool",
    "jammy",
    "mac",
    "no_android",
    "no_reclient",
    "windows",
    "windows11",
)
load("//lib/paths.star", "paths")

dart.ci_sandbox_builder(
    "pkg-linux-release",
    category = "pkg|l",
    location_filters = paths.to_location_filters(paths.pkg),
    properties = chrome,
)
dart.ci_sandbox_builder(
    "pkg-linux-release-arm64",
    category = "pkg|la",
    dimensions = [jammy, arm64],
    goma = False,  # no such package: infra_internal/goma/client/linux-arm64
    properties = {"clobber": False},
)
dart.ci_sandbox_builder(
    "pkg-mac-release",
    category = "pkg|m",
    dimensions = mac,
    properties = chrome,
)
dart.ci_sandbox_builder(
    "pkg-mac-release-arm64",
    category = "pkg|ma",
    channels = ["try"],
    dimensions = [mac, arm64],
    properties = [chrome, no_android],
)
dart.ci_sandbox_builder(
    "pkg-win-release",
    category = "pkg|w",
    dimensions = windows,
    properties = chrome,
)
dart.ci_sandbox_builder(
    "pkg-win-release-arm64",
    category = "pkg|wa",
    dimensions = [windows11, arm64, flutter_pool],
    goma = False,  # no such package: infra_internal/goma/client/windows-arm64
    properties = [{"clobber": False}, no_reclient],
)
dart.ci_sandbox_builder(
    "pkg-linux-debug",
    category = "pkg|ld",
    channels = ["try"],
    properties = chrome,
)
