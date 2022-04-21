// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.7

import 'dart:convert';
import 'dart:io';
import 'package:_fe_analyzer_shared/src/testing/features.dart';
import 'package:async_helper/async_helper.dart';
import 'package:compiler/src/compiler.dart';
import 'package:compiler/src/dump_info.dart';
import 'package:compiler/src/elements/entities.dart';
import 'package:compiler/src/js_model/element_map.dart';
import 'package:compiler/src/js_model/js_world.dart';
import 'package:dart2js_info/info.dart' as info;
import 'package:dart2js_info/json_info_codec.dart' as info;
import 'package:kernel/ast.dart' as ir;
import '../equivalence/id_equivalence.dart';
import '../equivalence/id_equivalence_helper.dart';

main(List<String> args) {
  asyncTest(() async {
    Directory dataDir = new Directory.fromUri(Platform.script.resolve('data'));
    print('Testing output of dump-info');
    print('==================================================================');
    await checkTests(dataDir, const DumpInfoDataComputer(),
        args: args, testedConfigs: allSpecConfigs, options: ['--dump-info']);
  });
}

class Tags {
  static const String library = 'library';
  static const String clazz = 'class';
  static const String classType = 'classType';
  static const String function = 'function';
  static const String typeDef = 'typedef';
  static const String field = 'field';
  static const String constant = 'constant';
  static const String holding = 'holding';
  static const String dependencies = 'dependencies';
  static const String outputUnits = 'outputUnits';
  static const String deferredFiles = 'deferredFiles';
}

class DumpInfoDataComputer extends DataComputer<Features> {
  const DumpInfoDataComputer();

  static const String wildcard = '%';

  @override
  void computeMemberData(Compiler compiler, MemberEntity member,
      Map<Id, ActualData<Features>> actualMap,
      {bool verbose: false}) {
    JsonEncoder encoder = const JsonEncoder.withIndent('    ');
    var converter = info.AllInfoToJsonConverter(
        isBackwardCompatible: true, filterTreeshaken: false);
    DumpInfoStateData dumpInfoState = compiler.dumpInfoStateForTesting;

    Features features = new Features();
    var functionInfo = dumpInfoState.entityToInfo[member];
    if (functionInfo == null) return;

    if (functionInfo is info.FunctionInfo) {
      features.addElement(
          Tags.function, encoder.convert(functionInfo.accept(converter)));
    }

    if (functionInfo is info.FieldInfo) {
      features.addElement(
          Tags.function, encoder.convert(functionInfo.accept(converter)));
    }

    JsClosedWorld closedWorld = compiler.backendClosedWorldForTesting;
    JsToElementMap elementMap = closedWorld.elementMap;
    ir.Member node = elementMap.getMemberDefinition(member).node;
    Id id = computeMemberId(node);
    ir.TreeNode nodeWithOffset = computeTreeNodeWithOffset(node);
    actualMap[id] = new ActualData<Features>(id, features,
        nodeWithOffset?.location?.file, nodeWithOffset?.fileOffset, member);
  }

  @override
  DataInterpreter<Features> get dataValidator =>
      const JsonFeaturesDataInterpreter(wildcard: wildcard);
}

/// Feature interpreter for Features with Json values.
///
/// The data annotation reader removes whitespace, but this fork adds them
/// back for readability.
class JsonFeaturesDataInterpreter implements DataInterpreter<Features> {
  final String wildcard;

  const JsonFeaturesDataInterpreter({this.wildcard});

  @override
  String isAsExpected(Features actualFeatures, String expectedData) {
    JsonEncoder encoder = const JsonEncoder.withIndent('    ');

    if (wildcard != null && expectedData == wildcard) {
      return null;
    } else if (expectedData == '') {
      return actualFeatures.isNotEmpty ? "Expected empty data." : null;
    } else {
      List<String> errorsFound = [];
      Features expectedFeatures = Features.fromText(expectedData);
      Set<String> validatedFeatures = new Set<String>();
      expectedFeatures.forEach((String key, Object expectedValue) {
        validatedFeatures.add(key);
        Object actualValue = actualFeatures[key];
        if (!actualFeatures.containsKey(key)) {
          errorsFound.add('No data found for $key');
        } else if (expectedValue == '') {
          if (actualValue != '') {
            errorsFound.add('Non-empty data found for $key');
          }
        } else if (wildcard != null && expectedValue == wildcard) {
          return;
        } else if (expectedValue is List) {
          if (actualValue is List) {
            List actualList = actualValue.toList();
            for (Object expectedObject in expectedValue) {
              String expectedText =
                  encoder.convert(jsonDecode('$expectedObject'));
              bool matchFound = false;
              if (wildcard != null && expectedText.endsWith(wildcard)) {
                // Wildcard matcher.
                String prefix =
                    expectedText.substring(0, expectedText.indexOf(wildcard));
                List matches = [];
                for (Object actualObject in actualList) {
                  if ('$actualObject'.startsWith(prefix)) {
                    matches.add(actualObject);
                    matchFound = true;
                  }
                }
                for (Object match in matches) {
                  actualList.remove(match);
                }
              } else {
                for (Object actualObject in actualList) {
                  if (expectedText == '$actualObject') {
                    actualList.remove(actualObject);
                    matchFound = true;
                    break;
                  }
                }
              }
              if (!matchFound) {
                errorsFound.add("No match found for $key=[$expectedText]");
              }
            }
            if (actualList.isNotEmpty) {
              errorsFound
                  .add("Extra data found $key=[${actualList.join(',')}]");
            }
          } else {
            errorsFound.add("List data expected for $key: "
                "expected '$expectedValue', found '${actualValue}'");
          }
        } else if (expectedValue != actualValue) {
          errorsFound.add("Mismatch for $key: expected '$expectedValue', "
              "found '${actualValue}'");
        }
      });
      actualFeatures.forEach((String key, Object value) {
        if (!validatedFeatures.contains(key)) {
          if (value == '') {
            errorsFound.add("Extra data found '$key'");
          } else {
            errorsFound.add("Extra data found $key=$value");
          }
        }
      });
      return errorsFound.isNotEmpty ? errorsFound.join('\n ') : null;
    }
  }

  @override
  String getText(Features actualData, [String indentation]) {
    return actualData.getText(indentation);
  }

  @override
  bool isEmpty(Features actualData) {
    return actualData == null || actualData.isEmpty;
  }
}
