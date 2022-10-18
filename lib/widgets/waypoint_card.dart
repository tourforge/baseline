import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/models.dart';
import '/screens/waypoint_details.dart';

class WaypointCard extends StatelessWidget {
  const WaypointCard({
    Key? key,
    required this.waypoint,
    required this.index,
  }) : super(key: key);

  final WaypointModel waypoint;
  final int index;

  @override
  Widget build(BuildContext context) {
    const borderRadius = Radius.circular(20);

    return Material(
      elevation: 3,
      borderRadius: const BorderRadius.all(borderRadius),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(DialogRoute(
              context: context,
              builder: (context) => WaypointDetails(waypoint)));
        },
        borderRadius: const BorderRadius.all(borderRadius),
        child: Row(
          children: [
            if (waypoint.gallery.isNotEmpty)
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: borderRadius,
                        bottomLeft: borderRadius,
                      ),
                      child: Image.asset(
                        waypoint.gallery.first.fullPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Center(
                      child: Text(
                        "${index + 1}",
                        style: GoogleFonts.robotoMono(
                          color: Colors.white,
                          fontSize: 32,
                          shadows: const [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 35,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      waypoint.name,
                      style: GoogleFonts.montserrat(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "${waypoint.desc}\n\n",
                      style:
                          GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
