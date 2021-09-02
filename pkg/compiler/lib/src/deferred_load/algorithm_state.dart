// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'entity_data.dart';
import 'entity_data_info.dart';
import 'import_set.dart';
import 'work_queue.dart';

import '../common.dart';
import '../compiler.dart' show Compiler;
import '../elements/entities.dart';
import '../kernel/element_map.dart';
import '../world.dart' show KClosedWorld;

/// Manages the state of the [EntityData] model. Every class, member, constant,
/// etc, is wrapped in the deferred loading algorithm by an [EntityData] which
/// knows how to collect dependencies for a given [Entity].
class AlgorithmState {
  final Compiler compiler;
  final KernelToElementMap elementMap;
  final KClosedWorld closedWorld;
  final EntityDataRegistry registry;
  final Map<EntityData, ImportSet> entityToSet = {};
  final Map<EntityData, EntityDataInfo> entityDataToInfo = {};
  final ImportSetLattice importSets;
  final WorkQueue queue;

  AlgorithmState._(this.closedWorld, this.elementMap, this.compiler,
      this.importSets, this.registry)
      : queue = WorkQueue(importSets, registry);

  /// Factory function to create and initialize a [AlgorithmState].
  factory AlgorithmState.create(
      FunctionEntity main,
      Compiler compiler,
      KernelToElementMap elementMap,
      KClosedWorld closedWorld,
      ImportSetLattice importSets) {
    var entityDataState = AlgorithmState._(
        closedWorld, elementMap, compiler, importSets, EntityDataRegistry());
    entityDataState.initialize(main);
    return entityDataState;
  }

  /// Given an [EntityData], an [oldSet] and a [newSet], either ignore the
  /// update, apply the update immediately if we can avoid unions, or apply the
  /// update later if we cannot. For more detail on [oldSet] and [newSet],
  /// please see the comment in deferred_load.dart.
  void update(EntityData entityData, ImportSet oldSet, ImportSet newSet) {
    ImportSet currentSet = entityToSet[entityData];

    // If [currentSet] == [newSet], then currentSet must include all of newSet.
    if (currentSet == newSet) return;

    // Elements in the main output unit always remain there.
    if (currentSet == importSets.mainSet) return;

    // If [currentSet] == [oldSet], then we can safely update the
    // [entityToSet] map for [entityData] to [newSet] in a single assignment.
    // If not, then if we are supposed to update [entityData] recursively, we add
    // it back to the queue so that we can re-enter [update] later after
    // performing a union. If we aren't supposed to update recursively, we just
    // perform the union inline.
    if (currentSet == oldSet) {
      // Continue recursively updating from [oldSet] to [newSet].
      entityToSet[entityData] = newSet;
      updateDependencies(entityData, oldSet, newSet);
    } else if (entityData.needsRecursiveUpdate) {
      assert(
          // Invariant: we must mark main before we mark any deferred import.
          newSet != importSets.mainSet || oldSet != null,
          failedAt(
              NO_LOCATION_SPANNABLE,
              "Tried to assign to the main output unit, but it was assigned "
              "to $currentSet."));
      queue.addEntityData(entityData, newSet);
    } else {
      entityToSet[entityData] = importSets.union(currentSet, newSet);
    }
  }

  /// Returns the [EntityDataInfo] associated with a given [EntityData].
  /// Note: In the event of a cache miss, i.e. the first time we ever see a new
  /// [EntityData], we will add all reachable deferred roots to the queue for
  /// processing.
  EntityDataInfo getInfo(EntityData data) {
    // Check for cached [EntityDataInfo], otherwise create a new one and
    // collect dependencies.
    var info = entityDataToInfo[data];
    if (info == null) {
      var infoBuilder =
          EntityDataInfoBuilder(closedWorld, elementMap, compiler, registry);
      var visitor = EntityDataInfoVisitor(infoBuilder);
      data.accept(visitor);
      info = infoBuilder.info;
      entityDataToInfo[data] = info;

      // This is the first time we have seen this [EntityData] before so process
      // all deferred roots.
      info.deferredRoots.forEach((entity, imports) {
        for (ImportEntity deferredImport in imports) {
          queue.addEntityData(entity, importSets.initialSetOf(deferredImport));
        }
      });
    }
    return info;
  }

  /// Updates the dependencies of a given [EntityData] from [oldSet] to
  /// [newSet].
  void updateDependencies(
      EntityData entityData, ImportSet oldSet, ImportSet newSet) {
    var info = getInfo(entityData);

    // Process all direct dependencies.
    for (var entity in info.directDependencies) {
      update(entity, oldSet, newSet);
    }
  }

  /// Initializes the [AlgorithmState] assuming that [main] is the main entry
  /// point of a given program.
  void initialize(FunctionEntity main) {
    // Add `main` and their recursive dependencies to the main output unit.
    // We do this upfront to avoid wasting time visiting these elements when
    // analyzing deferred imports.
    queue.addMember(main, importSets.mainSet);

    // Also add "global" dependencies to the main output unit.  These are
    // things that the backend needs but cannot associate with a particular
    // element. This set also contains elements for which we lack precise
    // information.
    for (MemberEntity element
        in closedWorld.backendUsage.globalFunctionDependencies) {
      queue.addMember(element, importSets.mainSet);
    }
    for (ClassEntity element
        in closedWorld.backendUsage.globalClassDependencies) {
      queue.addClass(element, importSets.mainSet);
    }

    // Empty queue.
    while (queue.isNotEmpty) {
      queue.processNextItem(this);
    }
  }
}
