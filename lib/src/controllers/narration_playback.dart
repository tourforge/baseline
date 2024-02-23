import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../data.dart';

enum NarrationPlaybackState {
  playing,
  paused,
  completed,
  stopped,
  loading,
}

class NarrationPlaybackController extends BaseAudioHandler with SeekHandler {
  static late final NarrationPlaybackController instance;

  static Future<void> init() async {
    instance = await AudioService.init(
      builder: () => NarrationPlaybackController(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'org.tourforge.guide.channel.audio',
        androidNotificationChannelName: 'Narration playback',
      ),
    );
  }

  NarrationPlaybackController() {
    _player.playerStateStream.listen((event) {
      _onStateChanged.add(null);
      _updatePlaybackState();
    });
    _player.durationStream.listen((duration) {
      if (_currentIndex == null || duration == null) return;

      buildMediaItem(tour.waypoints[_currentIndex!], duration)
          .then(updateMediaItem);
    });
    _player.positionDiscontinuityStream.listen((event) {
      _updatePlaybackState();
    });
  }

  late TourModel tour;

  AudioPlayer _player = AudioPlayer();

  final StreamController _onStateChanged = StreamController.broadcast();
  Stream<void> get onStateChanged => _onStateChanged.stream;

  NarrationPlaybackState get state {
    switch (_player.processingState) {
      case ProcessingState.idle:
        return NarrationPlaybackState.stopped;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        return NarrationPlaybackState.loading;
      case ProcessingState.completed:
        return NarrationPlaybackState.completed;
      case ProcessingState.ready:
        return _player.playing
            ? NarrationPlaybackState.playing
            : NarrationPlaybackState.paused;
    }
  }

  int? _currentIndex;
  AssetModel? _currentNarration;

  Stream<double> get onPositionChanged =>
      _player.positionStream.asyncMap<double>((duration) async =>
          (duration.inMilliseconds.toDouble()) /
          (_player.duration?.inMilliseconds.toDouble() ?? 0));

  Future<void> reset() async {
    await stop();
    _currentIndex = _currentNarration = null;
    mediaItem.add(null);
    await _player.dispose();
    _player = AudioPlayer();
  }

  Future<void> playWaypoint(int index) async {
    _currentIndex = index;
    _currentNarration = tour.waypoints[index].narration;

    await _player.stop();

    mediaItem.add(await buildMediaItem(tour.waypoints[index]));
    if (_currentNarration == null) {
      _onStateChanged.add(null);
      _updatePlaybackState();
    } else {
      await _player.setAudioSource(
          ProgressiveAudioSource(Uri.file(_currentNarration!.localPath)));
      await play();
    }
  }

  Future<MediaItem> buildMediaItem(WaypointModel waypoint,
      [Duration? duration]) async {
    Uri? artUri;
    if (waypoint.gallery.isNotEmpty) {
      var squarePath =
          "${(await getTemporaryDirectory()).path}/square-${waypoint.gallery.first.name}";
      artUri = Uri.file(squarePath);

      if (!await File(squarePath).exists()) {
        var imgContent =
            await File(waypoint.gallery.first.localPath).readAsBytes();

        var square = await compute((imgContent) {
          var img = decodeImage(imgContent)!;

          return copyResizeCropSquare(img, size: 512);
        }, imgContent);

        await File(squarePath).writeAsBytes(encodeJpg(square));
      }
    }

    return MediaItem(
      id: waypoint.narration?.localPath ?? "${tour.name}/${waypoint.name}",
      title: waypoint.name,
      album: tour.name,
      artUri: artUri,
      duration: duration,
    );
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    _onStateChanged.add(null);

    _updatePlaybackState();
  }

  @override
  Future<void> play() async {
    _player.play();
    _onStateChanged.add(null);
  }

  Future<void> seekFractional(double position) async {
    var duration = Duration(
      milliseconds:
          ((_player.duration!.inMilliseconds.toDouble()) * position).toInt(),
    );

    await seek(duration);
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    if (_currentIndex == null || _currentIndex! >= tour.waypoints.length - 1) {
      return;
    }

    playWaypoint(_currentIndex! + 1);
  }

  @override
  Future<void> skipToPrevious() async {
    if (_currentIndex == null || _currentIndex! == 0) {
      return;
    }

    playWaypoint(_currentIndex! - 1);
  }

  Future<void> replay() async {
    var narration = _currentNarration;
    if (narration == null) return;

    await _player.stop();
    _player.seek(Duration.zero);
    _player.play();
    _onStateChanged.add(null);

    _updatePlaybackState();
  }

  void _updatePlaybackState() {
    playbackState.add(PlaybackState(
      controls: [
        if (_currentIndex != null) MediaControl.skipToPrevious,
        if (_currentIndex != null &&
            _player.processingState == ProcessingState.ready)
          _player.playing ? MediaControl.pause : MediaControl.play,
        if (_currentIndex != null) MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      processingState: AudioProcessingState.ready,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: 1.0,
      queueIndex: 0,
    ));
  }

  String? positionToString(double position) {
    var fullDuration = _player.duration;
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
