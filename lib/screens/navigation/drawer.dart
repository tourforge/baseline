import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '/models.dart';
import '/widgets/waypoint_card.dart';

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({super.key, required this.tour});

  final TourModel tour;

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer>
    with SingleTickerProviderStateMixin {
  static const curve = Cubic(0.65, 0.0, 0.35, 1.0);
  static const invCurve = Cubic(0.0, 0.65, 1.0, 0.35);

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: curve,
  );

  Offset? _dragStart;
  double? _dragStartSize;

  double _innerSize = 0;
  double _expandedSize = 0;

  @override
  Widget build(BuildContext context) {
    const handleHeight = 8.0;
    const handleWidth = 50.0;

    return ConstraintsTransformBox(
      constraintsTransform: (c) => BoxConstraints(
        minWidth: c.minWidth,
        maxWidth: c.maxWidth,
        minHeight: 0,
        maxHeight: c.maxHeight,
      ),
      alignment: Alignment.bottomCenter,
      child: LayoutBuilder(builder: (context, constraints) {
        _expandedSize = constraints.maxHeight * 0.5;
        return ClipRect(
          child: Material(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Theme.of(context).dividerColor, width: 2)),
                  ),
                  child: GestureDetector(
                    onVerticalDragStart: _onVerticalDragStart,
                    onVerticalDragEnd: _onVerticalDragEnd,
                    onVerticalDragUpdate: _onVerticalDragUpdate,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(color: Colors.transparent),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: UnconstrainedBox(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            child: SizedBox(
                                height: handleHeight, width: handleWidth),
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
                    child: ListView(
                      children: [
                        const SizedBox(height: 3),
                        for (var x in widget.tour.waypoints.asMap().entries)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 3.0,
                            ),
                            child: WaypointCard(
                              waypoint: x.value,
                              index: x.key,
                            ),
                          ),
                        const SizedBox(height: 3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _onVerticalDragStart(DragStartDetails details) {
    setState(() {
      _controller.stop();
      _dragStart = details.globalPosition;
      _dragStartSize = _innerSize = _controller.value * _innerSize;
      _controller.value = _controller.upperBound;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    setState(() {
      var startFactor = _dragStartSize! / _expandedSize;
      var factor = _innerSize / _expandedSize;

      if (factor > (startFactor > 0.5 ? 0.85 : 0.15)) {
        _innerSize = _expandedSize;
        _controller.forward(from: invCurve.transform(factor));
      } else {
        _controller.reverse(from: invCurve.transform(factor));
      }

      _dragStart = null;
      _dragStartSize = null;
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      var dragStart = _dragStart!;
      var dragStartSize = _dragStartSize!;

      var dragOffset = details.globalPosition - dragStart;

      _innerSize = clampDouble(dragStartSize - dragOffset.dy, 0, _expandedSize);
    });
  }
}

class _GoodThing extends StatelessWidget {
  const _GoodThing({
    Key? key,
    required this.waypoint,
  }) : super(key: key);

  final WaypointModel waypoint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            child: SizedBox(
              width: 64,
              child: Image.asset(
                waypoint.gallery.first.fullPath,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    waypoint.name,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    waypoint.desc,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontSize: 15, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
