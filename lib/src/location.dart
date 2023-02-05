import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

Future<Stream<LatLng>?> getLocationStream(BuildContext context) async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Location services disabled"),
          content: const Text(
            "Location services are disabled. "
            "Please enable them in order to be guided along tours.",
          ),
          actions: [
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return null;
  }

  var permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Location services denied"),
            content: const Text(
              "Location services permission was denied. "
              "Please allow access in order to be guided along tours.",
            ),
            actions: [
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Location services denied forever"),
          content: const Text(
            "Location services permission was permanently denied. "
            "The app cannot request permission. "
            "Please edit your settings to reenable the location services. ",
          ),
          actions: [
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return null;
  }

  return Geolocator.getPositionStream()
      .map((pos) => LatLng(pos.latitude, pos.longitude));
}
