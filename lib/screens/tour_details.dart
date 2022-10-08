import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

import '/models.dart';
import '/screens/navigation.dart';
import '/widgets/gallery.dart';

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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 250.0,
            leading: InitialFadeIn(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: "Back",
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            actions: [
              InitialFadeIn(
                child: IconButton(
                  onPressed: () {},
                  tooltip: "Preview",
                  icon: const Icon(Icons.map),
                ),
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.passthrough,
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Image.asset(
                      widget.summary.thumbnail.fullPath,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Stack(
                    fit: StackFit.passthrough,
                    children: [
                      Hero(
                        tag: "tourThumbnail",
                        child: Image.asset(
                          widget.summary.thumbnail.fullPath,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      Positioned.fill(
                        child: InitialFadeIn(
                          child: Container(
                              color: const Color.fromARGB(64, 0, 0, 0)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              centerTitle: true,
              title: InitialFadeIn(
                child: Text(
                  widget.summary.name,
                  style: GoogleFonts.montserrat(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              expandedTitleScale: 2,
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: StartTourButtonDelegate(
              tickerProvider: this,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => NavigationScreen(tour!)));
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Material(
                elevation: 3,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 12.0, bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Description",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tour?.desc ?? "",
                        style: GoogleFonts.poppins(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Gallery(images: tour?.gallery ?? []),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Material(
                  elevation: 3,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          tour?.waypoints[index].name ?? "",
                          style: GoogleFonts.montserrat(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "${tour?.waypoints[index].desc ?? ""}\n\n",
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }, childCount: tour?.waypoints.length ?? 0),
          ),
        ],
      ),
    );
  }
}

class InitialFadeIn extends StatefulWidget {
  const InitialFadeIn({super.key, required this.child});

  final Widget child;

  @override
  State<InitialFadeIn> createState() => _InitialFadeInState();
}

class _InitialFadeInState extends State<InitialFadeIn>
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

class StartTourButtonDelegate extends SliverPersistentHeaderDelegate {
  const StartTourButtonDelegate({
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
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(
                Theme.of(context).colorScheme.secondary),
            shape: MaterialStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
            padding: const MaterialStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.explore),
              const SizedBox(width: 12),
              Text(
                "Start Tour",
                style: Theme.of(context)
                    .textTheme
                    .button!
                    .copyWith(fontSize: 16, color: Colors.white),
              ),
            ],
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
