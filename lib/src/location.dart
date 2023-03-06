import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

Future<bool> requestGpsPermissions(BuildContext context) async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    if (!context.mounted) return false;
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

    return false;
  }

  var permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      if (!context.mounted) return false;
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

      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    if (!context.mounted) return false;
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
  }

  return true;
}

Future<Stream<LatLng>?> getLocationStream(BuildContext context) async {
  if (!context.mounted) return null;

  if (await requestGpsPermissions(context)) {
    return Geolocator.getPositionStream()
        .map((pos) => LatLng(pos.latitude, pos.longitude));
  } else {
    return null;
  }
}
