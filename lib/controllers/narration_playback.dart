import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '/models/data.dart';

enum PlaybackState {
  playing,
  paused,
  completed,
  stopped,
}

class NarrationPlaybackController {
  NarrationPlaybackController({required this.narrations}) {
    _player.audioCache = AudioCache(prefix: '');
    _player.onDurationChanged.listen((duration) {
      _currentDuration = duration;
    });
    _player.onPlayerStateChanged.listen((event) {
      _onStateChanged.add(null);
    });
  }

  final List<AssetModel?> narrations;

  final AudioPlayer _player = AudioPlayer();

  final StreamController _onStateChanged = StreamController.broadcast();
  Stream<void> get onStateChanged => _onStateChanged.stream;

  PlaybackState get state {
    switch (_player.state) {
      case PlayerState.playing:
        return PlaybackState.playing;
      case PlayerState.paused:
        return PlaybackState.paused;
      case PlayerState.completed:
        return PlaybackState.completed;
      case PlayerState.stopped:
        return PlaybackState.stopped;
    }
  }

  AssetModel? _currentNarration;
  Duration? _currentDuration;

  Stream<double> get onPositionChanged =>
      _player.onPositionChanged.asyncMap<double>((duration) async =>
          (duration.inMilliseconds.toDouble()) /
          ((await _player.getDuration())!.inMilliseconds.toDouble()));

  Future<void> play(int newWaypoint) async {
    _currentNarration = narrations[newWaypoint];

    await _player.stop();

    if (_currentNarration == null) {
      _currentDuration = null;
      _onStateChanged.add(null);
      return;
    }

    await _player.play(DeviceFileSource(_currentNarration!.downloadPath));
  }

  Future<void> pause() async {
    await _player.pause();
    _onStateChanged.add(null);
  }

  Future<void> resume() async {
    await _player.resume();
    _onStateChanged.add(null);
  }

  Future<void> seek(double position) async {
    var duration = Duration(
      milliseconds:
          (((await _player.getDuration())!.inMilliseconds.toDouble()) *
                  position)
              .toInt(),
    );

    await _player.seek(duration);
  }

  Future<void> replay() async {
    var narration = _currentNarration;
    if (narration == null) return;

    await _player.stop();
    await _player.play(DeviceFileSource(narration.downloadPath));
    _onStateChanged.add(null);
  }

  String? positionToString(double position) {
    var fullDuration = _currentDuration;
    if (fullDuration == null) return null;
    if (position.isNaN || !position.isFinite) return null;

    var duration = Duration(
      milliseconds: (fullDuration.inMilliseconds.toDouble() * position).toInt(),
    );

    var mins = "${duration.inMinutes}".padLeft(2, "0");
    var secs =
        "${duration.inSeconds - duration.inMinutes * 60}".padLeft(2, "0");

    return "$mins:$secs";
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
