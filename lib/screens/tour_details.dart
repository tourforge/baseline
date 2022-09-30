import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/models.dart';

// TODO: investigate performance of this page, it's pretty heavy

class TourDetails extends StatefulWidget {
  const TourDetails(this.summary, {super.key});

  final TourSummary summary;

  @override
  State<TourDetails> createState() => _TourDetailsState();
}

class _TourDetailsState extends State<TourDetails> {
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
                  icon: const Icon(Icons.arrow_back)),
            ),
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
                      fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                elevation: 3,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
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
