import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../models/data.dart';
import '../screens/navigation/navigation.dart';
import '../widgets/asset_image_builder.dart';
import '../widgets/details_header.dart';
import '../widgets/gallery.dart';
import '../widgets/waypoint_card.dart';

// TODO: investigate performance of this page, it's pretty heavy

class TourDetails extends StatefulWidget {
  const TourDetails(this.summary, {super.key});

  final TourSummary summary;

  @override
  State<TourDetails> createState() => _TourDetailsState();
}

class _TourDetailsState extends State<TourDetails>
    with SingleTickerProviderStateMixin {
  late Future<TourModel> tourFuture;
  TourModel? tour;

  @override
  void initState() {
    super.initState();

    tourFuture = TourModel.load(widget.summary.id);
    tourFuture.then((value) => setState(() => tour = value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: MultiSliver(
              pushPinnedChildren: false,
              children: [
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: kToolbarHeight + 5,
                  expandedHeight: 200.0,
                  leading: _InitialFadeIn(
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: "Back",
                      icon: Icon(Icons.adaptive.arrow_back),
                      color: Theme.of(context).appBarTheme.foregroundColor,
                    ),
                  ),
                  actions: [
                    _InitialFadeIn(
                      child: IconButton(
                        onPressed: () {},
                        tooltip: "Preview",
                        icon: const Icon(Icons.map),
                        color: Theme.of(context).appBarTheme.foregroundColor,
                      ),
                    )
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.passthrough,
                      children: [
                        if (widget.summary.thumbnail != null)
                          AssetImageBuilder(
                            widget.summary.thumbnail!,
                            builder: (image) {
                              return Image(
                                image: image,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        Positioned.fill(
                          child: _InitialFadeIn(
                            child: Container(
                                color: const Color.fromARGB(64, 0, 0, 0)),
                          ),
                        ),
                      ],
                    ),
                    centerTitle: true,
                    expandedTitleScale: 1.0,
                    title: LayoutBuilder(builder: (context, constraints) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 56.0),
                        child: _InitialFadeIn(
                          child: Text(
                            widget.summary.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .foregroundColor,
                                ),
                            textAlign: TextAlign.center,
                            maxLines: constraints.maxHeight > 90 ? 3 : 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }),
                  ),
                  forceElevated: innerBoxIsScrolled,
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StartTourButtonDelegate(
                    tickerProvider: this,
                    onPressed: () {
                      Navigator.of(context).push(NavigationRoute(tour!));
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Material(
                    elevation: 3,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    type: MaterialType.card,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 12.0, bottom: 16.0),
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
                            tour?.desc ?? "",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 250,
                  child: Gallery(images: tour?.gallery ?? []),
                ),
              ),
              const SliverToBoxAdapter(
                child: DetailsHeader(
                  title: "Tour Stops",
                ),
              ),
              _WaypointList(tour: tour),
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

class _InitialFadeIn extends StatefulWidget {
  const _InitialFadeIn({super.key, required this.child});

  final Widget child;

  @override
  State<_InitialFadeIn> createState() => _InitialFadeInState();
}

class _InitialFadeInState extends State<_InitialFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 600),
    vsync: this,
  )..forward();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInCubic,
  );

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
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
