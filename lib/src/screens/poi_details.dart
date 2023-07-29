import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data.dart';
import '../widgets/details_button.dart';
import '../widgets/details_description.dart';
import '../widgets/details_screen_header_delegate.dart';

class PoiDetails extends StatefulWidget {
  const PoiDetails(this.poi, {super.key});

  final PoiModel poi;

  @override
  State<PoiDetails> createState() => _PoiDetailsState();
}

class _PoiDetailsState extends State<PoiDetails>
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
                gallery: widget.poi.gallery,
                title: widget.poi.name,
                action: ElevatedButton(
                  onPressed: () {
                    if (Platform.isIOS) {
                      launchUrl(
                        Uri.parse(
                            "https://maps.apple.com/?daddr=${widget.poi.lat},${widget.poi.lng}"),
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      launchUrl(
                        Uri.parse(
                            "https://www.google.com/maps/dir/?api=1&destination=${widget.poi.lat},${widget.poi.lng}"),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
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
                      Icon(Icons.route),
                      SizedBox(width: 8.0),
                      Text("Directions"),
                      SizedBox(width: 12.0),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
                child: DetailsDescription(desc: widget.poi.desc)),
            for (final entry in widget.poi.links.entries)
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
