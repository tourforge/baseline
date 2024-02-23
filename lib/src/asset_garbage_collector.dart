import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'package:tourforge/src/data.dart';

/// Collects the garbage of unreferenced files.
class AssetGarbageCollector {
  static late final String base;
  static bool isRunning = false;

  static Future<void> run() async {
    if (isRunning) return;
    isRunning = true;

    if (kDebugMode) {
      print("Asset garbage collector running.");
    }

    try {
      var index = TourIndex.parse(
          jsonDecode(await File("$base/index.json").readAsString()));

      var usedAssets = HashSet<String>();

      usedAssets.add("index.json");

      usedAssets.addAll(index.tours.map((e) => e.thumbnail).whereType());

      for (var tourEntry in index.tours) {
        if (tourEntry.thumbnail != null) {
          usedAssets.add(tourEntry.thumbnail!.name);
        }

        if (await File("$base/${tourEntry.content.name}").exists()) {
          usedAssets.add(tourEntry.content.name);

          var tour = TourModel.parse(
              "$base/${tourEntry.content.name}",
              jsonDecode(await File("$base/${tourEntry.content.name}")
                  .readAsString()));

          usedAssets.addAll(tour.allAssets.map((e) => e.name));
        }
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
        print("Unexpected rror while garbage collecting: $e");
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
