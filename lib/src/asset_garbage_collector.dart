import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'package:tourforge_baseline/src/data.dart';

/// Collects the garbage of unreferenced files.
class AssetGarbageCollector {
  static late final String base;
  static bool isRunning = false;

  /// Runs the garbage collector.
  ///
  /// `ignoredTours` contains the list of tours that will be ignored when computing
  /// the set of used assets. Hence, to delete assets which are only required by a
  /// given tour or set of tours, include the IDs of those tours in ignoredTours.
  static Future<void> run({Set<String>? ignoredTours}) async {
    if (isRunning) return;
    isRunning = true;

    if (kDebugMode) {
      print("Asset garbage collector running.");
    }

    try {
      var index = Project.parse(
          jsonDecode(await File("$base/tourforge.json").readAsString()));

      var usedAssets = HashSet<String>();

      usedAssets.add("tourforge.json");

      for (var tourEntry in index.tours) {
        if (ignoredTours != null && ignoredTours.contains(tourEntry.id)) {
          continue;
        }

        usedAssets.addAll(tourEntry.allAssets.map((e) => e.id));
      }

      await for (var entry in Directory(base).list()) {
        if (!usedAssets.contains(p.basename(entry.path))) {
          if (kDebugMode) {
            print("Asset garbage collector is deleting a file: ${entry.path}");
          }
          try {
            await entry.delete();
          } catch (e, stack) {
            if (kDebugMode) {
              print("Error while deleting suspected garbage: $e");
              print("Garbage collection error stack trace: $stack");
              print("Continuing...");
            }
          }
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print("Unexpected error while garbage collecting: $e");
        print("Garbage collection error stack trace: $stack");
      }
    } finally {
      if (kDebugMode) {
        print("Asset garbage collector finished.");
      }
      isRunning = false;
    }
  }
}
