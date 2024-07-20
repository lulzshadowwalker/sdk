// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/src/dart/analysis/byte_store.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer/src/dart/analysis/file_state.dart';
import 'package:analyzer/src/dart/analysis/library_context.dart';
import 'package:analyzer/src/dart/analysis/library_graph.dart';
import 'package:analyzer/src/dart/analysis/unlinked_unit_store.dart';
import 'package:analyzer/src/dart/micro/resolve_file.dart';
import 'package:analyzer/src/utilities/extensions/file_system.dart';
import 'package:collection/collection.dart';
import 'package:test/test.dart';

class AnalyzerStatePrinter {
  static const String _macroUriStr = 'package:macros/macros.dart';
  static const String _macroImplApiUriStr = 'package:_macros/src/api.dart';

  final MemoryByteStore byteStore;
  final UnlinkedUnitStoreImpl unlinkedUnitStore;
  final IdProvider idProvider;
  final LibraryContext libraryContext;
  final AnalyzerStatePrinterConfiguration configuration;
  final ResourceProvider resourceProvider;
  final StringSink sink;
  final bool withKeysGetPut;

  String _indent = '';
  final Set<LibraryCycle> _libraryCyclesWithWrittenDetails = Set.identity();

  AnalyzerStatePrinter({
    required this.byteStore,
    required this.unlinkedUnitStore,
    required this.idProvider,
    required this.libraryContext,
    required this.configuration,
    required this.resourceProvider,
    required this.sink,
    required this.withKeysGetPut,
  });

  FileSystemState get fileSystemState => libraryContext.fileSystemState;

  void writeAnalysisDriver(AnalysisDriverTestView testData) {
    _writeFiles(testData.fileSystem);
    _writeLibraryContext(testData.libraryContext);
    _writeElementFactory();
  }

  void writeFileResolver(FileResolverTestData testData) {
    _writeFiles(testData.fileSystem);
    _writeLibraryContext(testData.libraryContext);
    _writeElementFactory();
    _writeUnlinkedUnitStore();
    _writeByteStore();
  }

  String _stringOfLibraryCycle(LibraryCycle cycle) {
    if (configuration.omitSdkFiles) {
      var isSdkLibrary = cycle.libraries.any((library) {
        return library.file.uri.isScheme('dart');
      });
      if (isSdkLibrary) {
        if (cycle.libraries.any((e) => e.file.uriStr == 'dart:core')) {
          return 'dart:core';
        } else if (cycle.libraries
            .any((e) => e.file.uriStr == 'dart:collection')) {
          return 'dart:collection';
        } else if (cycle.libraries.any((e) => e.file.uriStr == 'dart:io')) {
          return 'dart:io';
        } else {
          throw UnimplementedError('$cycle');
        }
      }
    }
    if (cycle.libraries.any((e) => e.file.uriStr == _macroUriStr)) {
      return _macroUriStr;
    }
    return idProvider.libraryCycle(cycle);
  }

  String _stringOfUriStr(String uriStr) {
    if (uriStr.trim().isEmpty) {
      return "'$uriStr'";
    } else {
      return uriStr;
    }
  }

  void _verifyKnownFiles() {
    var uriFiles = fileSystemState.test.uriToFile.values.toSet();
    var pathFiles = fileSystemState.test.uriToFile.values.toSet();

    expect(pathFiles.difference(uriFiles), isEmpty);
    expect(uriFiles.difference(pathFiles), isEmpty);

    var knownFilesNotInUriFiles = fileSystemState.knownFiles.toSet();
    knownFilesNotInUriFiles.removeAll(uriFiles);
    expect(knownFilesNotInUriFiles, isEmpty);
  }

  void _withIndent(void Function() f) {
    var indent = _indent;
    _indent = '$_indent  ';
    f();
    _indent = indent;
  }

  void _writeAugmentationImports(LibraryOrAugmentationFileKind container) {
    _writeElements<AugmentationImportState>(
      'augmentationImports',
      container.augmentationImports,
      (import) {
        if (import is AugmentationImportWithFile) {
          expect(import.container, same(container));
          var file = import.importedFile;
          sink.write(_indent);

          var importedAugmentation = import.importedAugmentation;
          if (importedAugmentation != null) {
            expect(importedAugmentation.file, file);
            sink.write(idProvider.fileKind(importedAugmentation));
          } else {
            sink.write('notAugmentation ${idProvider.fileState(file)}');
          }
          sink.writeln();
        } else if (import is AugmentationImportWithUri) {
          _writelnWithIndent('uri: ${import.uri.relativeUri}');
        } else if (import is AugmentationImportWithUriStr) {
          var uriStr = _stringOfUriStr(import.uri.relativeUriStr);
          _writelnWithIndent('uriStr: $uriStr');
        } else {
          _writelnWithIndent('noUriStr');
        }
      },
    );
  }

  void _writeByteStore() {
    _writelnWithIndent('byteStore');
    _withIndent(() {
      var groups = byteStore.map.entries.groupListsBy((element) {
        return element.value.refCount;
      });

      for (var groupEntry in groups.entries) {
        var keys = groupEntry.value.map((e) => e.key).toList();
        var shortKeys = idProvider.shortKeys(keys)..sort();
        _writelnWithIndent('${groupEntry.key}: $shortKeys');
      }
    });
  }

  void _writeDocImports(FileKind container) {
    _writeElements<LibraryImportState>(
      'docImports',
      container.docImports,
      (import) {
        expect(import.isDocImport, isTrue);
        _writeLibraryImport(container, import);
      },
    );
  }

  void _writeElementFactory() {
    _writelnWithIndent('elementFactory');
    _withIndent(() {
      var elementFactory = libraryContext.elementFactory;
      _writeUriList(
        'hasElement',
        elementFactory.uriListWithLibraryElements,
      );
      _writeUriList(
        'hasReader',
        elementFactory.uriListWithLibraryReaders,
      );
    });
  }

  void _writeElements<T>(String name, List<T> elements, void Function(T) f) {
    if (elements.isNotEmpty) {
      _writelnWithIndent(name);
      _withIndent(() {
        for (var element in elements) {
          f(element);
        }
      });
    }
  }

  void _writeFile(FileState file) {
    _withIndent(() {
      _writelnWithIndent('id: ${idProvider.fileState(file)}');
      _writeFileContent(file);
      _writeFileKind(file);
      _writeReferencingFiles(file);
      _writeFileUnlinkedKey(file);
    });
  }

  void _writeFileContent(FileState file) {
    if (configuration.filesToPrintContent.any((e) => e.path == file.path)) {
      _writelnWithIndent('content\n---\n${file.content}---');
    }
  }

  void _writeFileKind(FileState file) {
    var kind = file.kind;
    expect(kind.file, same(file));

    _writelnWithIndent('kind: ${idProvider.fileKind(kind)}');
    if (kind is AugmentationKnownFileKind) {
      _withIndent(() {
        var augmented = kind.augmented;
        if (augmented != null) {
          var id = idProvider.fileKind(augmented);
          _writelnWithIndent('augmented: $id');
        } else {
          var id = idProvider.fileState(kind.uriFile);
          _writelnWithIndent('uriFile: $id');
        }

        var library = kind.library;
        if (library != null) {
          var id = idProvider.fileKind(library);
          _writelnWithIndent('library: $id');
        }

        _writeLibraryImports(kind);
        _writeLibraryExports(kind);
        _writeAugmentationImports(kind);
        _writeDocImports(kind);
      });
    } else if (kind is AugmentationUnknownFileKind) {
      _withIndent(() {
        var uri = kind.uri;
        if (uri is DirectiveUriWithoutString) {
          _writelnWithIndent('noUriStr');
        } else if (uri is DirectiveUriWithInSummarySource) {
          throw UnimplementedError('${uri.runtimeType}');
        } else if (uri is DirectiveUriWithUri) {
          sink.write(_indent);
          sink.write('uri: ${uri.relativeUri}');
          sink.writeln();
        } else if (uri is DirectiveUriWithString) {
          var uriStr = _stringOfUriStr(uri.relativeUriStr);
          sink.write(_indent);
          sink.write('uriStr: $uriStr');
          sink.writeln();
        }
      });
    } else if (kind is LibraryFileKind) {
      expect(kind.library, same(kind));

      _withIndent(() {
        var name = kind.name;
        if (name != null) {
          _writelnWithIndent('name: $name');
        }

        _writeLibraryImports(kind);
        _writeLibraryExports(kind);
        _writeAugmentationImports(kind);
        _writePartIncludes(kind);
        _writeDocImports(kind);

        var filesIds = kind.fileKinds.map(idProvider.fileKind);
        _writelnWithIndent('fileKinds: ${filesIds.join(' ')}');

        _writeLibraryCycle(kind);
      });
    } else if (kind is PartOfNameFileKind) {
      _withIndent(() {
        var libraries = kind.libraries;
        if (libraries.isNotEmpty) {
          var keys = libraries
              .map(idProvider.fileKind)
              .sorted(compareNatural)
              .join(' ');
          _writelnWithIndent('libraries: $keys');
        }

        var library = kind.library;
        if (library != null) {
          var id = idProvider.fileKind(library);
          _writelnWithIndent('library: $id');
        } else {
          _writelnWithIndent('name: ${kind.unlinked.name}');
        }

        _writeLibraryImports(kind);
        _writeLibraryExports(kind);
        _writePartIncludes(kind);
        _writeDocImports(kind);
      });
    } else if (kind is PartOfUriKnownFileKind) {
      _withIndent(() {
        var uriFileId = idProvider.fileState(kind.uriFile);
        _writelnWithIndent('uriFile: $uriFileId');

        if (kind.library case var library?) {
          var id = idProvider.fileKind(library);
          _writelnWithIndent('library: $id');
        }

        _writeLibraryImports(kind);
        _writeLibraryExports(kind);
        _writePartIncludes(kind);
        _writeDocImports(kind);
      });
    } else if (kind is PartOfUriUnknownFileKind) {
      _withIndent(() {
        _writelnWithIndent('uri: ${kind.unlinked.uri}');
        expect(kind.library, isNull);
      });
    } else {
      throw UnimplementedError('${kind.runtimeType}');
    }
  }

  void _writeFiles(FileSystemTestData testData) {
    fileSystemState.discoverReferencedFiles();

    if (configuration.discardPartialMacroAugmentationFiles) {
      var pattern = RegExp(r'^.*\.macro\d+\.dart$');
      testData.files.removeWhere((file, value) {
        return pattern.hasMatch(file.path);
      });
    }

    _verifyKnownFiles();

    // Discover libraries for parts.
    // This is required for consistency checking.
    for (var fileData in testData.files.values.toList()) {
      var current = fileSystemState.getExisting(fileData.file);
      if (current != null) {
        var kind = current.kind;
        if (kind is PartOfNameFileKind) {
          kind.discoverLibraries();
        }
      }
    }

    // This is required for consistency checking.
    fileSystemState.discoverReferencedFiles();

    // Sort, mostly by path.
    // But sort SDK libraries to the end, with `dart:core` first.
    var fileDataList = testData.files.values.toList();
    fileDataList.sort((first, second) {
      var firstPath = first.file.path;
      var secondPath = second.file.path;
      if (configuration.omitSdkFiles) {
        var firstUri = first.uri;
        var secondUri = second.uri;
        var firstIsSdk = firstUri.isScheme('dart');
        var secondIsSdk = secondUri.isScheme('dart');
        if (firstIsSdk && !secondIsSdk) {
          return 1;
        } else if (!firstIsSdk && secondIsSdk) {
          return -1;
        } else if (firstIsSdk && secondIsSdk) {
          if ('$firstUri' == 'dart:core') {
            return -1;
          } else if ('$secondUri' == 'dart:core') {
            return 1;
          }
        }
      }
      return firstPath.compareTo(secondPath);
    });

    // Ask ID for every file in the sorted order, so that IDs are nice.
    // Register objects that can be referenced.
    idProvider.resetRegisteredObject();
    for (var fileData in fileDataList) {
      var current = fileSystemState.getExisting(fileData.file);
      if (current != null) {
        idProvider.registerFileState(current);
        var kind = current.kind;
        idProvider.registerFileKind(kind);
        if (kind is LibraryFileKind) {
          idProvider.registerLibraryCycle(kind.libraryCycle);
        }
      }
    }

    _writelnWithIndent('files');
    _withIndent(() {
      for (var fileData in fileDataList) {
        if (configuration.omitSdkFiles && fileData.uri.isScheme('dart')) {
          continue;
        }
        if (_isMacroApiUri(fileData.uri)) {
          continue;
        }
        var file = fileData.file;
        _writelnWithIndent(file.posixPath);
        _withIndent(() {
          _writelnWithIndent('uri: ${fileData.uri}');

          var current = fileSystemState.getExisting(file);
          if (current != null) {
            _writelnWithIndent('current');
            _writeFile(current);
          }

          if (withKeysGetPut) {
            var shortGets = idProvider.shortKeys(fileData.unlinkedKeyGet);
            var shortPuts = idProvider.shortKeys(fileData.unlinkedKeyPut);
            _writelnWithIndent('unlinkedGet: $shortGets');
            _writelnWithIndent('unlinkedPut: $shortPuts');
          }
        });
      }
    });
  }

  void _writeFileUnlinkedKey(FileState file) {
    var unlinkedShort = idProvider.shortKey(file.unlinkedKey);
    _writelnWithIndent('unlinkedKey: $unlinkedShort');
  }

  void _writeLibraryContext(LibraryContextTestData testData) {
    _writelnWithIndent('libraryCycles');
    _withIndent(() {
      var cyclesToPrint = <_LibraryCycleToPrint>[];
      for (var entry in testData.libraryCycles.entries) {
        if (configuration.omitSdkFiles &&
            entry.key.any((e) => e.uri.isScheme('dart'))) {
          continue;
        }
        if (entry.key.any((e) => _isMacroApiUri(e.uri))) {
          continue;
        }
        cyclesToPrint.add(
          _LibraryCycleToPrint(
            entry.key.map((e) => e.file.posixPath).join(' '),
            entry.value,
          ),
        );
      }
      cyclesToPrint.sortBy((e) => e.pathListStr);

      var loadedBundlesMap = Map.fromEntries(
        libraryContext.loadedBundles.map((cycle) {
          var pathListStr = cycle.libraries
              .map((library) => library.file.resource.posixPath)
              .sorted()
              .join(' ');
          return MapEntry(pathListStr, cycle);
        }),
      );

      for (var cycleToPrint in cyclesToPrint) {
        _writelnWithIndent(cycleToPrint.pathListStr);
        _withIndent(() {
          var current = loadedBundlesMap[cycleToPrint.pathListStr];
          if (current != null) {
            var id = idProvider.libraryCycle(current);
            _writelnWithIndent('current: $id');
            _withIndent(() {
              // TODO(scheglov): Print it with the cycle instead?
              var short = idProvider.shortKey(current.linkedKey);
              _writelnWithIndent('key: $short');
            });
          }

          var cycleData = cycleToPrint.data;
          var shortGets = idProvider.shortKeys(cycleData.getKeys);
          var shortPuts = idProvider.shortKeys(cycleData.putKeys);
          _writelnWithIndent('get: $shortGets');
          _writelnWithIndent('put: $shortPuts');
        });
      }
    });
  }

  void _writeLibraryCycle(LibraryFileKind library) {
    var cycle = library.libraryCycle;
    _writelnWithIndent(idProvider.libraryCycle(cycle));

    if (!_libraryCyclesWithWrittenDetails.add(cycle)) {
      return;
    }

    _withIndent(() {
      var dependencyIds = cycle.directDependencies
          .map(_stringOfLibraryCycle)
          .sorted(compareNatural)
          .join(' ');
      if (dependencyIds.isNotEmpty) {
        _writelnWithIndent('dependencies: $dependencyIds');
      } else {
        _writelnWithIndent('dependencies: none');
      }

      var libraryIds = cycle.libraries
          .map(idProvider.fileKind)
          .sorted(compareNatural)
          .join(' ');
      _writelnWithIndent('libraries: $libraryIds');

      _writelnWithIndent(idProvider.apiSignature(cycle.apiSignature));

      var userIds = cycle.directUsers
          .map(_stringOfLibraryCycle)
          .sorted(compareNatural)
          .join(' ');
      if (userIds.isNotEmpty) {
        _writelnWithIndent('users: $userIds');
      }
    });
  }

  void _writeLibraryExports(FileKind container) {
    _writeElements<LibraryExportState>(
      'libraryExports',
      container.libraryExports,
      (export) {
        if (export is LibraryExportWithFile) {
          expect(export.container, same(container));
          var file = export.exportedFile;
          sink.write(_indent);

          var exportedLibrary = export.exportedLibrary;
          if (exportedLibrary != null) {
            expect(exportedLibrary.file, file);
            sink.write(idProvider.fileKind(exportedLibrary));
          } else {
            sink.write('notLibrary ${idProvider.fileState(file)}');
          }

          if (configuration.omitSdkFiles && file.uri.isScheme('dart')) {
            sink.write(' ${file.uri}');
          }
          sink.writeln();
        } else if (export is LibraryExportWithInSummarySource) {
          sink.write(_indent);
          sink.write('inSummary ${export.exportedSource.uri}');

          var librarySource = export.exportedLibrarySource;
          if (librarySource != null) {
            expect(librarySource, same(export.exportedSource));
          } else {
            sink.write(' notLibrary');
          }
          sink.writeln();
        } else if (export is LibraryExportWithUri) {
          _writelnWithIndent('uri: ${export.selectedUri.relativeUri}');
        } else if (export is LibraryExportWithUriStr) {
          var uriStr = _stringOfUriStr(export.selectedUri.relativeUriStr);
          _writelnWithIndent('uriStr: $uriStr');
        } else {
          _writelnWithIndent('noUriStr');
        }
      },
    );
  }

  void _writeLibraryImport(
    FileKind container,
    LibraryImportState<DirectiveUri> import,
  ) {
    if (import is LibraryImportWithFile) {
      expect(import.container, same(container));
      var file = import.importedFile;
      sink.write(_indent);

      var importedLibrary = import.importedLibrary;
      if (importedLibrary != null) {
        expect(importedLibrary.file, file);
        sink.write(idProvider.fileKind(importedLibrary));
      } else {
        sink.write('notLibrary ${idProvider.fileState(file)}');
      }

      if (configuration.omitSdkFiles && file.uri.isScheme('dart')) {
        sink.write(' ${file.uri}');
      }
      if (file.uriStr == _macroUriStr) {
        sink.write(' $_macroUriStr');
      }

      if (import.isSyntheticDartCore) {
        sink.write(' synthetic');
      }
      sink.writeln();
    } else if (import is LibraryImportWithInSummarySource) {
      sink.write(_indent);
      sink.write('inSummary ${import.importedSource.uri}');

      var librarySource = import.importedLibrarySource;
      if (librarySource != null) {
        expect(librarySource, same(import.importedSource));
      } else {
        sink.write(' notLibrary');
      }

      if (import.isSyntheticDartCore) {
        sink.write(' synthetic');
      }
      sink.writeln();
    } else if (import is LibraryImportWithUri) {
      sink.write(_indent);
      sink.write('uri: ${import.selectedUri.relativeUri}');
      if (import.isSyntheticDartCore) {
        sink.write(' synthetic');
      }
      sink.writeln();
    } else if (import is LibraryImportWithUriStr) {
      var uriStr = _stringOfUriStr(import.selectedUri.relativeUriStr);
      sink.write(_indent);
      sink.write('uriStr: $uriStr');
      if (import.isSyntheticDartCore) {
        sink.write(' synthetic');
      }
      sink.writeln();
    } else {
      _writelnWithIndent('noUriStr');
    }
  }

  void _writeLibraryImports(FileKind container) {
    _writeElements<LibraryImportState>(
      'libraryImports',
      container.libraryImports,
      (import) {
        _writeLibraryImport(container, import);
      },
    );
  }

  void _writelnWithIndent(String line) {
    sink.write(_indent);
    sink.writeln(line);
  }

  void _writePartIncludes(FileKind container) {
    _writeElements<PartIncludeState>(
      'partIncludes',
      container.partIncludes,
      (part) {
        expect(part.container, same(container));
        if (part is PartIncludeWithFile) {
          var file = part.includedFile;
          sink.write(_indent);

          var includedPart = part.includedPart;
          if (includedPart != null) {
            expect(includedPart.file, file);
            sink.write(idProvider.fileKind(includedPart));
          } else {
            sink.write('notPart ${idProvider.fileState(file)}');
          }
          sink.writeln();
        } else if (part is PartIncludeWithUri) {
          var uriStr = _stringOfUriStr(part.uri.relativeUriStr);
          _writelnWithIndent('uri: $uriStr');
        } else {
          _writelnWithIndent('noUri');
        }
      },
    );
  }

  void _writeReferencingFiles(FileState file) {
    var referencingFiles = file.referencingFiles;
    if (referencingFiles.isNotEmpty) {
      var fileIds = referencingFiles
          .map(idProvider.fileState)
          .sorted(compareNatural)
          .join(' ');
      _writelnWithIndent('referencingFiles: $fileIds');
    }
  }

  void _writeUnlinkedUnitStore() {
    _writelnWithIndent('unlinkedUnitStore');
    _withIndent(() {
      var groups = unlinkedUnitStore.map.entries.groupListsBy((element) {
        return element.value.usageCount;
      });

      for (var groupEntry in groups.entries) {
        var keys = groupEntry.value.map((e) => e.key).toList();
        var shortKeys = idProvider.shortKeys(keys)..sort();
        _writelnWithIndent('${groupEntry.key}: $shortKeys');
      }
    });
  }

  void _writeUriList(String name, Iterable<Uri> uriIterable) {
    var uriStrList = <String>[];
    for (var uri in uriIterable) {
      if (configuration.omitSdkFiles && uri.isScheme('dart')) {
        continue;
      }
      if (const {_macroUriStr, _macroImplApiUriStr}.contains('$uri')) {
        continue;
      }
      uriStrList.add('$uri');
    }

    if (uriStrList.isNotEmpty) {
      uriStrList.sort();
      _writelnWithIndent(name);
      _withIndent(() {
        for (var uriStr in uriStrList) {
          _writelnWithIndent(uriStr);
        }
      });
    }
  }

  static bool _isMacroApiUri(Uri uri) {
    var uriStr = '$uri';
    return uriStr.startsWith('package:macros/') ||
        uriStr.startsWith('package:_macros/');
  }
}

class AnalyzerStatePrinterConfiguration {
  bool discardPartialMacroAugmentationFiles = true;

  Set<File> filesToPrintContent = {};

  bool omitSdkFiles = true;
}

/// Encoder of object identifies into short identifiers.
class IdProvider {
  final Map<FileState, String> _fileState = Map.identity();
  final Map<LibraryCycle, String> _libraryCycle = Map.identity();
  final Map<FileKind, String> _fileKind = Map.identity();
  final Map<String, String> _keyToShort = {};
  final Map<String, String> _shortToKey = {};
  final Map<String, String> _apiSignature = {};

  Set<FileState> _currentFiles = {};
  Set<FileKind> _currentFileKinds = {};
  Set<LibraryCycle> _currentCycles = {};

  String apiSignature(String signature) {
    var length = _apiSignature.length;
    return _apiSignature[signature] ??= 'apiSignature_$length';
  }

  String fileKind(FileKind kind) {
    if (!_currentFileKinds.contains(kind)) {
      throw StateError('$kind');
    }
    return _fileKind[kind] ??= () {
      if (kind is AugmentationKnownFileKind) {
        return 'augmentation_${_fileKind.length}';
      } else if (kind is AugmentationUnknownFileKind) {
        return 'augmentationUnknown_${_fileKind.length}';
      } else if (kind is LibraryFileKind) {
        return 'library_${_fileKind.length}';
      } else if (kind is PartOfNameFileKind) {
        return 'partOfName_${_fileKind.length}';
      } else if (kind is PartOfUriKnownFileKind) {
        return 'partOfUriKnown_${_fileKind.length}';
      } else if (kind is PartFileKind) {
        return 'partOfUriUnknown_${_fileKind.length}';
      } else {
        throw UnimplementedError('${kind.runtimeType}');
      }
    }();
  }

  String fileState(FileState file) {
    if (!_currentFiles.contains(file)) {
      throw StateError('$file');
    }
    return _fileState[file] ??= 'file_${_fileState.length}';
  }

  String libraryCycle(LibraryCycle cycle) {
    if (!_currentCycles.contains(cycle)) {
      throw StateError('$cycle');
    }
    return _libraryCycle[cycle] ??= 'cycle_${_libraryCycle.length}';
  }

  /// Register that [kind] is an object that can be referenced.
  void registerFileKind(FileKind kind) {
    if (_currentFileKinds.contains(kind)) {
      throw StateError('Duplicate: $kind');
    }
    _currentFileKinds.add(kind);
    fileKind(kind);
  }

  /// Register that [file] is an object that can be referenced.
  void registerFileState(FileState file) {
    if (_currentFiles.contains(file)) {
      throw StateError('Duplicate: $file');
    }
    _currentFiles.add(file);
    fileState(file);
  }

  /// Register that [cycle] is an object that can be referenced.
  void registerLibraryCycle(LibraryCycle cycle) {
    _currentCycles.add(cycle);
    libraryCycle(cycle);
  }

  void resetRegisteredObject() {
    _currentFiles = {};
    _currentFileKinds = {};
    _currentCycles = {};
  }

  String shortKey(String key) {
    var short = _keyToShort[key];
    if (short == null) {
      short = 'k${_keyToShort.length.toString().padLeft(2, '0')}';
      _keyToShort[key] = short;
      _shortToKey[short] = key;
    }
    return short;
  }

  List<String> shortKeys(List<String> keys) {
    return keys.map(shortKey).toList();
  }
}

class _LibraryCycleToPrint {
  final String pathListStr;
  final LibraryCycleTestData data;

  _LibraryCycleToPrint(this.pathListStr, this.data);
}
