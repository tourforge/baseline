import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Checks/sets whether or not a given help screen has been viewed.
class HelpViewed {
  static Future<bool> viewed(String key) async {
    try {
      return await File(p.join((await getApplicationSupportDirectory()).path,
              "helpsviewed", key))
          .exists();
    } catch (e) {
      if (kDebugMode) {
        print("Caught exception while checking if help screen viewed: $e");
      }
      return false;
    }
  }

  static Future<void> markViewed(String key) async {
    try {
      await File(p.join((await getApplicationSupportDirectory()).path,
              "helpsviewed", key))
          .create(recursive: true);
    } catch (e) {
      if (kDebugMode) {
        print("Caught exception while marking help screen viewed: $e");
      }
    }
  }
}
