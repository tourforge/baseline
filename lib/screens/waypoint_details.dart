import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/models.dart';
import '/widgets/gallery.dart';

class WaypointDetails extends StatelessWidget {
  const WaypointDetails(this.waypoint, {super.key});

  final WaypointModel waypoint;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    waypoint.name,
                    style: GoogleFonts.roboto(fontSize: 16),
                  ),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                      ),
                      splashRadius: 16,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Text(
                waypoint.desc,
                style: GoogleFonts.poppins(),
              ),
            ),
            SizedBox(
              height: 200,
              child: Gallery(
                images: waypoint.gallery,
                padding: const EdgeInsets.only(
                  left: 16.0,
                  bottom: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
