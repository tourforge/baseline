import 'package:flutter/material.dart';

import '../models/data.dart';
import '../widgets/details_description.dart';
import '../widgets/details_header.dart';
import '../widgets/details_screen_header_delegate.dart';
import '../widgets/waypoint_card.dart';
import 'navigation/navigation.dart';

class TourDetails extends StatefulWidget {
  const TourDetails(this.tour, {super.key});

  final TourModel tour;

  @override
  State<TourDetails> createState() => _TourDetailsState();
}

class _TourDetailsState extends State<TourDetails>
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
              gallery: widget.tour.gallery,
              title: widget.tour.name,
              action: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(NavigationRoute(widget.tour));
                },
                style: const ButtonStyle(
                    padding: MaterialStatePropertyAll(EdgeInsets.zero),
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                    )),
                child: Row(
                  children: const [
                    SizedBox(width: 12.0),
                    Icon(Icons.explore),
                    SizedBox(width: 8.0),
                    Text("Start"),
                    SizedBox(width: 12.0),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: DetailsDescription(desc: widget.tour.desc)),
          const SliverToBoxAdapter(
            child: DetailsHeader(
              title: "Tour Stops",
            ),
          ),
          _WaypointList(tour: widget.tour),
          const SliverToBoxAdapter(child: SizedBox(height: 6)),
        ],
      ),
    );
  }
}

class _WaypointList extends StatelessWidget {
  const _WaypointList({
    Key? key,
    required this.tour,
  }) : super(key: key);

  final TourModel? tour;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: tour?.waypoints.length ?? 0,
        (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: WaypointCard(
              waypoint: tour!.waypoints[index],
              index: index,
            ),
          );
        },
      ),
    );
  }
}
