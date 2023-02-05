import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/narration_playback.dart';
import '../../models/current_waypoint.dart';
import '../../models/data.dart';

class NavigationPanel extends StatelessWidget {
  const NavigationPanel({
    Key? key,
    required this.tour,
  }) : super(key: key);

  final TourModel tour;

  @override
  Widget build(BuildContext context) {
    var currentWaypoint = context.watch<CurrentWaypointModel>();

    return Material(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor, width: 2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8.0, left: 8.0, bottom: 8.0),
              child: _AudioControlButton(),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: Text(
                      currentWaypoint.index != null
                          ? "${currentWaypoint.index! + 1}. ${tour.waypoints[currentWaypoint.index!].name}"
                          : "No Narration Playing",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: currentWaypoint.index == null
                                ? Colors.grey
                                : null,
                            fontStyle: currentWaypoint.index == null
                                ? FontStyle.italic
                                : null,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const _AudioPositionSlider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioPositionSlider extends StatefulWidget {
  const _AudioPositionSlider();

  @override
  State<_AudioPositionSlider> createState() => _AudioPositionSliderState();
}

class _AudioPositionSliderState extends State<_AudioPositionSlider> {
  late final StreamSubscription<double> _positionSubscription;

  bool isDragging = false;
  double position = 0;

  @override
  void initState() {
    super.initState();

    NarrationPlaybackController.instance.onStateChanged.listen((event) {
      if (mounted) setState(() {});
    });

    _positionSubscription = NarrationPlaybackController
        .instance.onPositionChanged
        .listen((position) {
      if (!isDragging && position >= 0.0 && position <= 1.0) {
        setState(() {
          this.position = position;
        });
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        Text(
          NarrationPlaybackController.instance.positionToString(position) ??
              "00:00",
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Colors.grey),
        ),
        Expanded(
          child: Slider(
            value: position,
            label:
                NarrationPlaybackController.instance.positionToString(position),
            min: 0,
            max: 1,
            onChanged: NarrationPlaybackController.instance.state !=
                    NarrationPlaybackState.stopped
                ? (value) {
                    setState(() {
                      position = value;
                    });
                  }
                : null,
            onChangeStart: (_) => isDragging = true,
            onChangeEnd: (value) {
              isDragging = false;
              NarrationPlaybackController.instance.seekFractional(value);
            },
          ),
        ),
        Text(
          NarrationPlaybackController.instance.positionToString(1.0) ?? "00:00",
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Colors.grey),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _AudioControlButton extends StatefulWidget {
  const _AudioControlButton();

  @override
  State<_AudioControlButton> createState() => _AudioControlButtonState();
}

class _AudioControlButtonState extends State<_AudioControlButton> {
  late final StreamSubscription<void> _streamSubscription;

  @override
  void initState() {
    super.initState();

    _streamSubscription =
        NarrationPlaybackController.instance.onStateChanged.listen((event) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    const radius = 36.0;

    var isEnabled = NarrationPlaybackController.instance.state !=
        NarrationPlaybackState.stopped;
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Material(
        shape: const CircleBorder(),
        color: isEnabled ? Theme.of(context).colorScheme.primary : Colors.grey,
        child: IconButton(
          splashRadius: radius,
          onPressed: isEnabled ? _onPressed : null,
          iconSize: 48,
          icon: Icon(
            _icon(),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _onPressed() {
    switch (NarrationPlaybackController.instance.state) {
      case NarrationPlaybackState.playing:
        NarrationPlaybackController.instance.pause();
        break;
      case NarrationPlaybackState.paused:
        NarrationPlaybackController.instance.play();
        break;
      case NarrationPlaybackState.completed:
        NarrationPlaybackController.instance.replay();
        break;
      case NarrationPlaybackState.stopped:
        break;
    }
  }

  IconData _icon() {
    switch (NarrationPlaybackController.instance.state) {
      case NarrationPlaybackState.playing:
        return Icons.pause;
      case NarrationPlaybackState.paused:
        return Icons.play_arrow;
      case NarrationPlaybackState.completed:
        return Icons.replay;
      case NarrationPlaybackState.stopped:
        return Icons.play_arrow;
    }
  }
}
