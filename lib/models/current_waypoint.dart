import 'package:flutter/foundation.dart';

class CurrentWaypointModel extends ChangeNotifier {
  int? _index;

  int? get index => _index;
  set index(int? newValue) {
    _index = newValue;
    notifyListeners();
  }
}
