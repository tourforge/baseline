import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config.dart';
import '../../models/current_waypoint.dart';
import '../../data.dart';
import '../../widgets/waypoint_card.dart';

class TourNavigationDrawer extends StatefulWidget {
  const TourNavigationDrawer({
    super.key,
    required this.handleHeight,
    required this.tour,
    required this.playWaypoint,
  });

  final double handleHeight;
  final TourModel tour;
  final void Function(int waypointIdx) playWaypoint;

  @override
  State<TourNavigationDrawer> createState() => TourNavigationDrawerState();
}

class TourNavigationDrawerState extends State<TourNavigationDrawer>
    with SingleTickerProviderStateMixin {
  static const _curve = Cubic(0.65, 0.0, 0.35, 1.0);
  static const _invCurve = Cubic(0.0, 0.65, 1.0, 0.35);

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: _curve,
  );

  Offset? _dragStart;
  double? _dragStartSize;

  double _innerSize = 0;
  double _expandedSize = 0;

  @override
  Widget build(BuildContext context) {
    const handleHeight = 8.0;
    const handleWidth = 50.0;

    var currentWaypoint = context.watch<CurrentWaypointModel>().index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: LayoutBuilder(builder: (context, constraints) {
        _expandedSize = constraints.maxHeight * 0.5;
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              color: Colors.black.withAlpha(208),
              child: GestureDetector(
                onTap: _onTap,
                onVerticalDragStart: onVerticalDragStart,
                onVerticalDragEnd: onVerticalDragEnd,
                onVerticalDragUpdate: onVerticalDragUpdate,
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: SizedBox(
                    height: widget.handleHeight,
                    child: const UnconstrainedBox(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        child:
                            SizedBox(height: handleHeight, width: handleWidth),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizeTransition(
              sizeFactor: _animation,
              child: SizedBox(
                height: _innerSize,
                child: Theme(
                  data: tourForgeConfig.darkThemeData,
                  child: Material(
                    child: OverflowBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: NotificationListener<OverscrollNotification>(
                              onNotification: (notification) {
                                if (notification.velocity == 0 &&
                                    notification.overscroll < -8) {
                                  setState(() {
                                    var factor = _animation.value *
                                        _innerSize /
                                        _expandedSize;
                                    _controller.reverse(
                                        from: _invCurve.transform(factor));
                                  });
                                }

                                return false;
                              },
                              child: ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  const SizedBox(height: 4),
                                  for (var entry
                                      in widget.tour.waypoints.asMap().entries)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                        vertical: 4.0,
                                      ),
                                      child: WaypointCard(
                                        waypoint: entry.value,
                                        index: entry.key,
                                        currentlyPlaying:
                                            entry.key == currentWaypoint,
                                        onPlayed: () {
                                          widget.playWaypoint(entry.key);
                                        },
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _onTap() {
    setState(() {
      var factor = _animation.value * _innerSize / _expandedSize;

      if (factor > 0.5) {
        _controller.reverse(from: _invCurve.transform(factor));
      } else {
        _innerSize = _expandedSize;
        _controller.forward(from: _invCurve.transform(factor));
      }
    });
  }

  void onVerticalDragStart(DragStartDetails details) {
    setState(() {
      _controller.stop();
      _dragStart = details.globalPosition;
      _dragStartSize = _innerSize = _controller.value * _innerSize;
      _controller.value = _controller.upperBound;
    });
  }

  void onVerticalDragEnd(DragEndDetails details) {
    setState(() {
      var startFactor = _dragStartSize! / _expandedSize;
      var factor = _innerSize / _expandedSize;

      if (factor > (startFactor > 0.5 ? 0.85 : 0.15)) {
        _innerSize = _expandedSize;
        _controller.forward(from: _invCurve.transform(factor));
      } else {
        _controller.reverse(from: _invCurve.transform(factor));
      }

      _dragStart = null;
      _dragStartSize = null;
    });
  }

  void onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      var dragStart = _dragStart!;
      var dragStartSize = _dragStartSize!;

      var dragOffset = details.globalPosition - dragStart;

      _innerSize = clampDouble(dragStartSize - dragOffset.dy, 0, _expandedSize);
    });
  }
}
