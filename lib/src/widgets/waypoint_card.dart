import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data.dart';
import '../screens/waypoint_details.dart';
import '../widgets/asset_image_builder.dart';

class WaypointCard extends StatefulWidget {
  const WaypointCard({
    Key? key,
    required this.waypoint,
    required this.index,
    this.onPlayed,
    this.currentlyPlaying = false,
  }) : super(key: key);

  final WaypointModel waypoint;
  final int index;
  final void Function()? onPlayed;
  final bool currentlyPlaying;

  @override
  State<WaypointCard> createState() => _WaypointCardState();
}

class _WaypointCardState extends State<WaypointCard> {
  @override
  Widget build(BuildContext context) {
    const borderRadius = Radius.circular(20);

    return Material(
      elevation: 3,
      borderRadius: const BorderRadius.all(borderRadius),
      type: MaterialType.card,
      shadowColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => WaypointDetails(widget.waypoint)));
            },
            borderRadius: BorderRadius.only(
              topLeft: borderRadius,
              topRight: borderRadius,
              bottomLeft: widget.currentlyPlaying ? Radius.zero : borderRadius,
              bottomRight: widget.currentlyPlaying ? Radius.zero : borderRadius,
            ),
            child: Row(
              children: [
                if (widget.waypoint.gallery.isNotEmpty)
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      fit: StackFit.passthrough,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: borderRadius,
                            bottomLeft: widget.currentlyPlaying
                                ? Radius.zero
                                : borderRadius,
                          ),
                          child: AssetImageBuilder(
                            widget.waypoint.gallery.first,
                            builder: (image) {
                              return Image(
                                image: image,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                        Center(
                          child: Text(
                            "${widget.index + 1}",
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
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.waypoint.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(fontSize: 14.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${widget.waypoint.desc}\n\n",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.onPlayed != null && !widget.currentlyPlaying)
                  SizedBox(
                    width: 72,
                    child: Center(
                      child: IconButton(
                        onPressed: widget.onPlayed ?? () {},
                        iconSize: 28,
                        padding: const EdgeInsets.all(16),
                        icon: Icon(
                          Icons.play_arrow,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ),
                  ),
                if (!(widget.onPlayed != null && !widget.currentlyPlaying))
                  const SizedBox(width: 20),
              ],
            ),
          ),
          if (widget.currentlyPlaying)
            Material(
              color: Theme.of(context).colorScheme.onSecondary.withAlpha(192),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: borderRadius,
                  bottomRight: borderRadius,
                ),
              ),
              child: SizedBox(
                height: 32,
                child: Center(
                  child: Text(
                    "Currently Playing",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
