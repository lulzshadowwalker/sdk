// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_utilities/package_root.dart';
import 'package:linter/src/rules/analyzer_use_new_elements.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AnalyzerUseNewElementsTest);
  });
}

@reflectiveTest
class AnalyzerUseNewElementsTest extends LintRuleTest {
  @override
  String get lintRule => AnalyzerUseNewElements.code.name;

  @override
  void setUp() {
    super.setUp();

    var physicalProvider = PhysicalResourceProvider.INSTANCE;
    var pkgPath = physicalProvider.pathContext.normalize(packageRoot);
    var analyzerLibSource = physicalProvider
        .getFolder(pkgPath)
        .getChildAssumingFolder('analyzer')
        .getChildAssumingFolder('lib');

    var analyzerFolder = newFolder('/packages/analyzer');
    analyzerLibSource.copyTo(analyzerFolder);

    newPackageConfigJsonFileFromBuilder(
      testPackageRootPath,
      PackageConfigFileBuilder()
        ..add(
          name: 'analyzer',
          rootPath: analyzerFolder.path,
        ),
    );

    AnalyzerUseNewElements.resetCaches();
    _writeOptIns(r'''
lib/test.dart
''');
  }

  test_enablement_notEnabled() async {
    _writeOptIns(r'''
lib/test2.dart
''');

    await assertDiagnostics(r'''
import 'package:analyzer/dart/element/element.dart';

ClassElement f() {
  throw 42;
}
''', []);
  }

  test_enablement_wholeDirectory() async {
    _writeOptIns(r'''
lib/
''');

    await assertDiagnostics(r'''
import 'package:analyzer/dart/element/element.dart';

ClassElement f() {
  throw 42;
}
''', [
      lint(54, 12),
    ]);
  }

  test_enablement_withoutExtension() async {
    _writeOptIns(r'''
lib/test
''');

    await assertDiagnostics(r'''
import 'package:analyzer/dart/element/element.dart';

ClassElement f() {
  throw 42;
}
''', [
      lint(54, 12),
    ]);
  }

  test_namedType() async {
    await assertDiagnostics(r'''
import 'package:analyzer/dart/element/element.dart';

ClassElement f() {
  throw 42;
}
''', [
      lint(54, 12),
    ]);
  }

  test_simpleIdentifier_propertyAccess() async {
    await assertDiagnostics(r'''
import 'package:analyzer/dart/ast/ast.dart';

void f(ClassDeclaration a) {
  a.declaredElement;
}
''', [
      lint(79, 15),
    ]);
  }

  void _writeOptIns(String lines) {
    newFile('$testPackageRootPath/analyzer_use_new_elements.txt', lines);
  }
}
