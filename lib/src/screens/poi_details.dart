import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/data.dart';
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
