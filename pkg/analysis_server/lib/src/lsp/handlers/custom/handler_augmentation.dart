// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/lsp_protocol/protocol.dart' hide Element;
import 'package:analysis_server/src/lsp/constants.dart';
import 'package:analysis_server/src/lsp/handlers/custom/abstract_go_to.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/utilities/extensions/element.dart';

class AugmentationHandler extends AbstractGoToHandler {
  AugmentationHandler(super.server);

  @override
  Method get handlesMessage => CustomMethods.augmentation;

  @override
  bool get requiresTrustedCaller => false;

  @override
  Element? findRelatedElement(Element element) {
    return element.augmentation;
  }
}
