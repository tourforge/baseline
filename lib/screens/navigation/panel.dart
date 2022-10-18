import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/controllers/narration_playback.dart';
import '/models.dart';

class NavigationPanel extends StatelessWidget {
  const NavigationPanel({
    Key? key,
    required this.playbackController,
    required this.currentWaypoint,
    required this.tour,
  }) : super(key: key);

  final NarrationPlaybackController playbackController;
  final int? currentWaypoint;
  final TourModel tour;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, bottom: 8.0),
            child: _AudioControlButton(playbackController: playbackController),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, left: 16.0, bottom: 8.0),
                  child: Text(
                    currentWaypoint != null
                        ? "${currentWaypoint! + 1}. ${tour.waypoints[currentWaypoint!].name}"
                        : "No Waypoints Nearby",
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        fontWeight:
                            currentWaypoint != null ? FontWeight.bold : null,
                        fontSize: 17,
                        color: currentWaypoint == null ? Colors.grey : null,
                        fontStyle:
                            currentWaypoint == null ? FontStyle.italic : null),
                  ),
                ),
                _AudioPositionSlider(playbackController: playbackController),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioPositionSlider extends StatefulWidget {
  const _AudioPositionSlider({
    Key? key,
    required this.playbackController,
  }) : super(key: key);

  final NarrationPlaybackController playbackController;

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

    _positionSubscription =
        widget.playbackController.onPositionChanged.listen((position) {
      setState(() {
        if (!isDragging) this.position = position;
      });
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
          widget.playbackController.positionToString(position) ?? "00:00",
          style: GoogleFonts.robotoCondensed(color: Colors.grey, fontSize: 16),
        ),
        Expanded(
          child: Slider(
            value: position,
            label: widget.playbackController.positionToString(position),
            min: 0,
            max: 1,
            onChanged: widget.playbackController.state != PlaybackState.stopped
                ? (value) {
                    setState(() {
                      position = value;
                    });
                  }
                : null,
            onChangeStart: (_) => isDragging = true,
            onChangeEnd: (value) {
              isDragging = false;
              widget.playbackController.seek(value);
            },
          ),
        ),
        Text(
          widget.playbackController.positionToString(1.0) ?? "00:00",
          style: GoogleFonts.robotoCondensed(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _AudioControlButton extends StatefulWidget {
  const _AudioControlButton({
    Key? key,
    required this.playbackController,
  }) : super(key: key);

  final NarrationPlaybackController playbackController;

  @override
  State<_AudioControlButton> createState() => _AudioControlButtonState();
}

class _AudioControlButtonState extends State<_AudioControlButton> {
  @override
  void initState() {
    super.initState();

    widget.playbackController.onStateChanged = () {
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    const radius = 36.0;

    var isEnabled = widget.playbackController.state != PlaybackState.stopped;
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
    switch (widget.playbackController.state) {
      case PlaybackState.playing:
        widget.playbackController.pause();
        break;
      case PlaybackState.paused:
        widget.playbackController.resume();
        break;
      case PlaybackState.completed:
        widget.playbackController.replay();
        break;
      case PlaybackState.stopped:
        break;
    }
  }

  IconData _icon() {
    switch (widget.playbackController.state) {
      case PlaybackState.playing:
        return Icons.pause;
      case PlaybackState.paused:
        return Icons.play_arrow;
      case PlaybackState.completed:
        return Icons.replay;
      case PlaybackState.stopped:
        return Icons.play_arrow;
    }
  }
}
