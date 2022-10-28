import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import '/models.dart';
import '/widgets/gallery.dart';

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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            toolbarHeight: kToolbarHeight + 5,
            expandedHeight: 200.0,
            leading: _InitialFadeIn(
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: "Back",
                icon: Icon(Icons.adaptive.arrow_back),
                color: Colors.white,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.passthrough,
                children: [
                  if (widget.waypoint.gallery.isNotEmpty)
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Image.file(
                        File(widget.waypoint.gallery.first.fullPath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  Stack(
                    fit: StackFit.passthrough,
                    children: [
                      if (widget.waypoint.gallery.isNotEmpty)
                        Hero(
                          tag: "waypointThumbnail ${widget.waypoint.name}",
                          child: Image.file(
                            File(widget.waypoint.gallery.first.fullPath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      Positioned.fill(
                        child: _InitialFadeIn(
                          child: Container(
                              color: const Color.fromARGB(64, 0, 0, 0)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              centerTitle: true,
              expandedTitleScale: 1.0,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: LayoutBuilder(builder: (context, constraints) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: _InitialFadeIn(
                      child: Text(
                        widget.waypoint.name,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.center,
                        maxLines: constraints.maxHeight > 84 ? 3 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 6)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        widget.waypoint.desc,
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
              child: Gallery(images: widget.waypoint.gallery),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 6)),
        ],
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
