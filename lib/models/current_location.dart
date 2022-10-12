import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class CurrentLocationModel extends ChangeNotifier {
  LatLng? _value;

  LatLng? get value => _value;
  set value(LatLng? newValue) {
    _value = newValue;
    notifyListeners();
  }
}
