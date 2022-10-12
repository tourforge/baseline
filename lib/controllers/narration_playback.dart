import 'package:audioplayers/audioplayers.dart';

import '/models.dart';

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
      onStateChanged();
    });
    ;
  }

  final List<AssetModel?> narrations;

  final AudioPlayer _player = AudioPlayer();

  void Function() onStateChanged = () {};

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

  Future<void> arrivedAtWaypoint(int? newWaypoint) async {
    if (newWaypoint == null) return;

    var narration = narrations[newWaypoint];
    if (narration == null) return;

    _currentNarration = narration;
    await _player.stop();
    await _player.play(AssetSource(narration.fullPath));
  }

  Future<void> pause() async {
    await _player.pause();
    onStateChanged();
  }

  Future<void> resume() async {
    await _player.resume();
    onStateChanged();
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
    await _player.play(AssetSource(narration.fullPath));
    onStateChanged();
  }

  String? positionToString(double position) {
    var duration = _currentDuration;
    if (duration == null) return null;

    var mins = "${duration.inMinutes}";
    var secs =
        "${duration.inSeconds - duration.inMinutes * 60}".padLeft(2, "0");

    return "$mins:$secs";
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
