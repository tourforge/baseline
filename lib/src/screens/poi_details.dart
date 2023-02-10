import 'package:flutter/material.dart';

import '../models/data.dart';
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
    return Scaffold(
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
          SliverToBoxAdapter(child: DetailsDescription(desc: widget.poi.desc)),
        ],
      ),
    );
  }
}
