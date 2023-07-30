import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../data.dart';
import 'gallery.dart';

class DetailsScreenHeaderDelegate extends SliverPersistentHeaderDelegate {
  const DetailsScreenHeaderDelegate({
    required this.tickerProvider,
    required this.gallery,
    required this.title,
    this.action,
    this.onHelpPressed,
  });

  final TickerProvider tickerProvider;
  final List<AssetModel> gallery;
  final String title;
  final Widget? action;
  final void Function()? onHelpPressed;

  @override
  double get maxExtent => 384;

  @override
  double get minExtent =>
      MediaQueryData.fromWindow(ui.window).padding.top + kToolbarHeight;

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
      true;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final shrinkFactor =
        clampDouble(shrinkOffset / (maxExtent - minExtent), 0.0, 1.0);

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor),
          ),
        ),
        Opacity(
          opacity:
              1.0 - pow(max(shrinkFactor - 0.8, 0.0), 2) / pow(1.0 - 0.8, 2),
          child: ClipRect(
            child: OverflowBox(
              maxHeight: maxExtent - 80,
              alignment: Alignment.topCenter,
              child: Gallery(
                images: gallery,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        if (onHelpPressed != null)
          Positioned(
            top: MediaQueryData.fromWindow(ui.window).padding.top,
            right: 0,
            child: IconButton(
              tooltip: "Help",
              onPressed: () {
                onHelpPressed!();
              },
              padding: const EdgeInsets.all(8.0),
              icon: DecoratedBox(
                decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    borderRadius:
                        const BorderRadius.all(Radius.circular(160.0))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.question_mark,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: MediaQueryData.fromWindow(ui.window).padding.top,
          left: 0,
          child: IconButton(
            onPressed: null,
            padding: const EdgeInsets.all(8.0),
            icon: DecoratedBox(
              decoration: BoxDecoration(
                  color: Theme.of(context).appBarTheme.backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(160.0))),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _DetailsScreenHeader(
            shrinkFactor: shrinkFactor,
            title: title,
            action: action,
          ),
        ),
        Positioned(
          top: MediaQueryData.fromWindow(ui.window).padding.top,
          left: 0,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            padding: const EdgeInsets.all(8.0),
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.arrow_back,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailsScreenHeader extends StatelessWidget {
  const _DetailsScreenHeader({
    super.key,
    required this.shrinkFactor,
    required this.title,
    this.action,
  });

  final double shrinkFactor;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final titleLeftPadding =
        20 + pow(max(shrinkFactor - 0.5, 0.0), 2) * (1 / 0.25) * 44;

    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      height: ui.lerpDouble(80, kToolbarHeight, shrinkFactor) ?? kToolbarHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: titleLeftPadding,
          ),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).appBarTheme.foregroundColor),
              overflow: TextOverflow.ellipsis,
              maxLines: shrinkFactor < 0.45 ? 2 : 1,
            ),
          ),
          if (action != null) const SizedBox(width: 24),
          if (action != null) action!,
          if (action != null) const SizedBox(width: 16.0),
        ],
      ),
    );
  }
}
