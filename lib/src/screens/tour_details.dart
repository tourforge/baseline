import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../models/data.dart';
import '../screens/navigation/navigation.dart';
import '../widgets/asset_image_builder.dart';
import '../widgets/details_header.dart';
import '../widgets/gallery.dart';
import '../widgets/waypoint_card.dart';

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
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: MultiSliver(
              pushPinnedChildren: false,
              children: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _GalleryDelegate(
                    tickerProvider: this,
                    tour: widget.tour,
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StartTourButtonDelegate(
                    tickerProvider: this,
                    onPressed: () {
                      Navigator.of(context).push(NavigationRoute(widget.tour));
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
        body: Builder(builder: (context) {
          return CustomScrollView(
            slivers: [
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 24.0, right: 24.0, top: 12.0, bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Description",
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.tour.desc,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: DetailsHeader(
                  title: "Tour Stops",
                ),
              ),
              _WaypointList(tour: widget.tour),
              const SliverToBoxAdapter(child: SizedBox(height: 6)),
            ],
          );
        }),
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

class _GalleryDelegate extends SliverPersistentHeaderDelegate {
  const _GalleryDelegate({
    required this.tickerProvider,
    required this.tour,
  });

  final TickerProvider tickerProvider;
  final TourModel tour;

  @override
  double get maxExtent => 384;

  @override
  double get minExtent => MediaQueryData.fromWindow(ui.window).padding.top + 60;

  @override
  TickerProvider get vsync => tickerProvider;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration =>
      FloatingHeaderSnapConfiguration();

  @override
  PersistentHeaderShowOnScreenConfiguration get showOnScreenConfiguration =>
      const PersistentHeaderShowOnScreenConfiguration();

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final shrinkFactor = shrinkOffset / (maxExtent - minExtent);
    if (shrinkFactor < 0.99) {
      return ClipRect(
        child: OverflowBox(
          maxHeight: 384,
          child: Gallery(
            images: tour.gallery,
            padding: EdgeInsets.zero,
          ),
        ),
      );
    } else {
      return AppBar(
        title: Text(tour.name),
        backgroundColor: Colors.black,
      );
    }
  }
}

class _StartTourButtonDelegate extends SliverPersistentHeaderDelegate {
  const _StartTourButtonDelegate({
    required this.tickerProvider,
    required this.onPressed,
  });

  final TickerProvider tickerProvider;
  final void Function() onPressed;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.only(
            top: 12.0, left: 12.0, right: 12.0, bottom: 6.0),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            gradient: LinearGradient(
              begin: Alignment(-1.0, 0.5),
              colors: [
                Color.fromARGB(255, 80, 226, 194),
                Color.fromARGB(255, 38, 211, 136),
              ],
            ),
          ),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ButtonStyle(
              backgroundColor:
                  const MaterialStatePropertyAll(Colors.transparent),
              foregroundColor: const MaterialStatePropertyAll(Colors.white),
              shape: MaterialStateProperty.all(
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
              shadowColor: const MaterialStatePropertyAll(Colors.transparent),
              padding: const MaterialStatePropertyAll(EdgeInsets.zero),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.explore),
                const SizedBox(width: 12),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Text(
                      "Start Tour",
                      style: Theme.of(context)
                          .textTheme
                          .button!
                          .copyWith(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 80;

  @override
  TickerProvider get vsync => tickerProvider;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration =>
      FloatingHeaderSnapConfiguration();

  @override
  PersistentHeaderShowOnScreenConfiguration get showOnScreenConfiguration =>
      const PersistentHeaderShowOnScreenConfiguration();

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
