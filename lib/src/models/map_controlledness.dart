import 'package:flutter/foundation.dart';

class MapControllednessModel extends ChangeNotifier {
  bool _value = false;

  bool get value => _value;
  set value(bool newValue) {
    _value = newValue;
    notifyListeners();
  }
}
