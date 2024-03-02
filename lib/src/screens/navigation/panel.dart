import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/narration_playback.dart';
import '../../models/current_waypoint.dart';
import '../../data.dart';

class NavigationPanel extends StatelessWidget {
  const NavigationPanel({
    Key? key,
    required this.tour,
  }) : super(key: key);

  final TourModel tour;

  @override
  Widget build(BuildContext context) {
    var currentWaypoint = context.watch<CurrentWaypointModel>();

    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 8.0,
      ),
      child: Material(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(16.0),
        ),
        color: Colors.black.withAlpha(208),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8.0, left: 4.0, bottom: 8.0),
              child: _AudioControlButton(),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 8.0,
                    ),
                    child: Text(
                      currentWaypoint.index != null
                          ? "${currentWaypoint.index! + 1}. ${tour.route[currentWaypoint.index!].title}"
                          : "No Narration Playing",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: currentWaypoint.index == null
                                ? Colors.grey
                                : Colors.white,
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
        const SizedBox(width: 8),
        Text(
          NarrationPlaybackController.instance.state !=
                  NarrationPlaybackState.loading
              ? NarrationPlaybackController.instance
                      .positionToString(position) ??
                  "00:00"
              : "00:00",
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Colors.grey),
        ),
        Expanded(
          child: Slider(
            thumbColor: Colors.white,
            activeColor: Colors.white,
            inactiveColor: Colors.white.withAlpha(32),
            value: NarrationPlaybackController.instance.state !=
                    NarrationPlaybackState.loading
                ? position
                : 0,
            label:
                NarrationPlaybackController.instance.positionToString(position),
            min: 0,
            max: 1,
            onChanged: NarrationPlaybackController.instance.state !=
                        NarrationPlaybackState.stopped &&
                    NarrationPlaybackController.instance.state !=
                        NarrationPlaybackState.loading
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
          NarrationPlaybackController.instance.state !=
                  NarrationPlaybackState.loading
              ? NarrationPlaybackController.instance.positionToString(1.0) ??
                  "00:00"
              : "00:00",
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
    var isEnabled = NarrationPlaybackController.instance.state !=
        NarrationPlaybackState.stopped;
    return IconButton(
      onPressed: isEnabled ? _onPressed : null,
      iconSize: 48,
      icon: _icon(),
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
      case NarrationPlaybackState.loading:
        break;
    }
  }

  Widget _icon() {
    switch (NarrationPlaybackController.instance.state) {
      case NarrationPlaybackState.playing:
        return const Icon(Icons.pause, color: Colors.white);
      case NarrationPlaybackState.paused:
        return const Icon(Icons.play_arrow, color: Colors.white);
      case NarrationPlaybackState.completed:
        return const Icon(Icons.replay, color: Colors.white);
      case NarrationPlaybackState.stopped:
        return const Icon(Icons.play_arrow, color: Colors.white);
      case NarrationPlaybackState.loading:
        return const SizedBox(
          width: 48,
          height: 48,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        );
    }
  }
}
