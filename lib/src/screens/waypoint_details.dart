import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/data.dart';
import '../widgets/collapsible_section.dart';
import '../widgets/details_button.dart';
import '../widgets/details_description.dart';
import '../widgets/details_screen_header_delegate.dart';

class WaypointDetails extends StatefulWidget {
  const WaypointDetails(this.waypoint, {super.key});

  final WaypointModel waypoint;

  @override
  State<WaypointDetails> createState() => _WaypointDetailsState();
}

class _WaypointDetailsState extends State<WaypointDetails>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: DetailsScreenHeaderDelegate(
                tickerProvider: this,
                gallery: widget.waypoint.gallery,
                title: widget.waypoint.name,
                action: null,
                /*action: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                        Theme.of(context).colorScheme.secondary),
                    padding: const MaterialStatePropertyAll(EdgeInsets.zero),
                    shape: const MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                    ),
                  ),
                  child: Row(
                    children: const [
                      SizedBox(width: 12.0),
                      Icon(Icons.music_note),
                      SizedBox(width: 8.0),
                      Text("Listen"),
                      SizedBox(width: 12.0),
                    ],
                  ),
                ),*/
              ),
            ),
            SliverToBoxAdapter(
              child: DetailsDescription(desc: widget.waypoint.desc),
            ),
            if (widget.waypoint.transcript != null)
              SliverPadding(
                padding: const EdgeInsets.only(top: 16.0),
                sliver: SliverToBoxAdapter(
                  child: CollapsibleSection(
                    title: "Transcript",
                    child: DetailsDescription(
                      header: null,
                      desc: widget.waypoint.transcript!,
                    ),
                  ),
                ),
              ),
            for (final entry in widget.waypoint.links.entries)
              SliverPadding(
                padding: const EdgeInsets.only(top: 8.0),
                sliver: SliverToBoxAdapter(
                  child: DetailsButton(
                    icon: Icons.link,
                    title: entry.key,
                    onPressed: () {
                      launchUrl(Uri.parse(entry.value.href),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
