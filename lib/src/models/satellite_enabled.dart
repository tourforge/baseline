import 'package:flutter/foundation.dart';

class SatelliteEnabledModel extends ChangeNotifier {
  bool _value = false;

  bool get value => _value;
  set value(bool newValue) {
    _value = newValue;
    notifyListeners();
  }
}
