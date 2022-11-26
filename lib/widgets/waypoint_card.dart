import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/models/data.dart';
import '/screens/waypoint_details.dart';
import '/widgets/asset_image_builder.dart';

class WaypointCard extends StatefulWidget {
  const WaypointCard({
    Key? key,
    required this.waypoint,
    required this.index,
    this.currentlyPlaying = false,
  }) : super(key: key);

  final WaypointModel waypoint;
  final int index;
  final bool currentlyPlaying;

  @override
  State<WaypointCard> createState() => _WaypointCardState();
}

class _WaypointCardState extends State<WaypointCard> {
  bool _transcriptShown = false;

  @override
  Widget build(BuildContext context) {
    const borderRadius = Radius.circular(20);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(borderRadius),
        boxShadow: [
          if (widget.currentlyPlaying)
            const BoxShadow(
              blurRadius: 5,
              spreadRadius: -2,
              color: Color.fromARGB(192, 72, 96, 192),
            ),
        ],
      ),
      child: Material(
        elevation: 3,
        borderRadius: const BorderRadius.all(borderRadius),
        type: MaterialType.card,
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
                bottomLeft: widget.currentlyPlaying &&
                        widget.waypoint.transcript != null
                    ? Radius.zero
                    : borderRadius,
                bottomRight: widget.currentlyPlaying &&
                        widget.waypoint.transcript != null
                    ? Radius.zero
                    : borderRadius,
              ),
              child: Row(
                children: [
                  if (widget.waypoint.gallery.isNotEmpty)
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: borderRadius,
                              bottomLeft: widget.currentlyPlaying &&
                                      widget.waypoint.transcript != null
                                  ? Radius.zero
                                  : borderRadius,
                            ),
                            child: Hero(
                              tag: "waypointThumbnail ${widget.waypoint.name}",
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
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.waypoint.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(fontSize: 14.5),
                            maxLines: 2,
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
                ],
              ),
            ),
            if (_transcriptShown && widget.currentlyPlaying)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Transcript",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 4.0),
                    Text(widget.waypoint.transcript ??
                        "No transcript available."),
                  ],
                ),
              ),
            if (widget.currentlyPlaying && widget.waypoint.transcript != null)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _transcriptShown = !_transcriptShown;
                  });
                },
                style: ButtonStyle(
                  padding: const MaterialStatePropertyAll(EdgeInsets.zero),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: const MaterialStatePropertyAll(Colors.white),
                  overlayColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.onPrimary.withAlpha(64)),
                  foregroundColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.primary),
                  shape: const MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: borderRadius,
                        bottomRight: borderRadius,
                      ),
                    ),
                  ),
                ),
                child: _transcriptShown
                    ? const Text("Hide Transcript")
                    : const Text("Show Transcript"),
              ),
          ],
        ),
      ),
    );
  }
}
