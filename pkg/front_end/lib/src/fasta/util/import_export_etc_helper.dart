// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:_fe_analyzer_shared/src/scanner/scanner.dart';
import 'package:_fe_analyzer_shared/src/scanner/token.dart' show Token;
import 'package:front_end/src/fasta/util/parser_ast.dart';
import 'package:front_end/src/fasta/util/parser_ast_helper.dart';

FileInfoHelper getFileInfoHelper(Uint8List zeroTerminatedBytes) {
  ImportExportPartLibraryHelperVisitor visitor =
      new ImportExportPartLibraryHelperVisitor();
  visitor.accept(getAST(
    zeroTerminatedBytes,
    enableExtensionMethods: true,
    enableNonNullable: true,
    enableTripleShift: true,
    includeBody: false,
    includeComments: false,
  ));
  return visitor.fileInfo;
}

FileInfoHelper getFileInfoHelperFromString(String source) {
  Uint8List rawBytes = utf8.encode(source);
  Uint8List zeroTerminatedBytes = new Uint8List(rawBytes.length + 1);
  zeroTerminatedBytes.setRange(0, rawBytes.length, rawBytes);
  return getFileInfoHelper(zeroTerminatedBytes);
}

class FileInfoHelper {
  List<String> imports = [];
  List<String> exports = [];
  List<String> parts = [];
  List<String> partOfUri = [];
  List<String> partOfIdentifiers = [];
  List<String> libraryNames = [];

  String getContent() {
    StringBuffer sb = new StringBuffer();
    if (imports.isNotEmpty) {
      sb.writeln("Imports:");
      for (String import in imports) {
        sb.writeln(" - $import");
      }
    }
    if (exports.isNotEmpty) {
      sb.writeln("Exports:");
      for (String export in exports) {
        sb.writeln(" - $export");
      }
    }
    if (parts.isNotEmpty) {
      sb.writeln("Parts:");
      for (String part in parts) {
        sb.writeln(" - $part");
      }
    }
    if (partOfUri.isNotEmpty) {
      sb.writeln("Part of uris:");
      for (String partOf in partOfUri) {
        sb.writeln(" - $partOf");
      }
    }
    if (partOfIdentifiers.isNotEmpty) {
      sb.writeln("Part of identifiers:");
      for (String partOf in partOfIdentifiers) {
        sb.writeln(" - $partOf");
      }
    }
    if (libraryNames.isNotEmpty) {
      sb.writeln("Library names:");
      for (String name in libraryNames) {
        sb.writeln(" - $name");
      }
    }

    return sb.toString().trim();
  }
}

class ImportExportPartLibraryHelperVisitor extends ParserAstVisitor {
  final FileInfoHelper fileInfo = new FileInfoHelper();
  @override
  void visitExport(ExportEnd node, Token startInclusive, Token endInclusive) {
    fileInfo.exports.add(node.getExportUriString());
    // TODO(jensj): Should the data from `node.getConditionalExportUriStrings()`
    // also be included?
  }

  @override
  void visitImport(ImportEnd node, Token startInclusive, Token? endInclusive) {
    fileInfo.imports.add(node.getImportUriString());
    // TODO(jensj): Should the data from `node.getConditionalImportUriStrings()`
    // also be included?
  }

  @override
  void visitLibraryName(
      LibraryNameEnd node, Token startInclusive, Token endInclusive) {
    if (node.hasName) {
      List<String> identifiers = node.getNameIdentifiers();
      if (identifiers.isNotEmpty) {
        fileInfo.libraryNames.add(identifiers.join("."));
      }
    }
  }

  @override
  void visitPart(PartEnd node, Token startInclusive, Token endInclusive) {
    fileInfo.parts.add(node.getPartUriString());
  }

  @override
  void visitPartOf(PartOfEnd node, Token startInclusive, Token endInclusive) {
    String? uriString = node.getPartOfUriString();
    if (uriString != null) {
      fileInfo.partOfUri.add(uriString);
    }
    List<String> identifiers = node.getPartOfIdentifiers();
    if (identifiers.isNotEmpty) {
      fileInfo.partOfIdentifiers.add(identifiers.join("."));
    }
  }
}
