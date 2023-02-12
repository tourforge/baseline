import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class DownloadManager {
  DownloadManager(this.localBaseFut, this.networkBaseFut) {
    localBaseFut.then((value) => localBase = value);
    networkBaseFut.then((value) => networkBase = value);
  }

  static late final DownloadManager instance;

  final Future<String> localBaseFut;
  final Future<String> networkBaseFut;
  final Map<String, Download> _currentDownloads = {};
  final Set<String> _downloadedAssetNames = {};

  late final String localBase;
  late final String networkBase;

  String localPath(String path) => "$localBase/$path";

  void markDownloaded(String path) {
    _downloadedAssetNames.add(path);
  }

  bool isDownloaded(String path) => _downloadedAssetNames.contains(path);

  Future<Download> download(String path, {bool reDownload = false}) async {
    var preexistingDownload = _currentDownloads[path];
    if (preexistingDownload != null) return preexistingDownload;

    final downloadProgressStream =
        StreamController<DownloadProgress>.broadcast();
    final fileCompleter = Completer<File>();

    var download = _currentDownloads[path] = Download(
      downloadProgress: downloadProgressStream.stream,
      file: fileCompleter.future,
    );

    (() async {
      final rng = Random();

      var retryIn = 0;
      for (var i = 0;; i++) {
        if (retryIn > 0) {
          await Future.delayed(Duration(milliseconds: retryIn));
        }

        var downloadFut = _downloadInner(path, reDownload: reDownload);

        StreamSubscription<DownloadProgress>? progressSubscription;
        try {
          var download = await downloadFut;

          progressSubscription = download.downloadProgress.listen((progress) {
            downloadProgressStream.add(progress);
          }, onError: (e) {
            _printDebug("Silenced error from download progress stream: $e");
          });

          var downloadedFile = await download.file;

          await downloadProgressStream.close();

          fileCompleter.complete(downloadedFile);

          break;
        } on Exception catch (e) {
          // exponential backoff: wait 0ms, then 500ms, then 1000ms, then 2000ms...
          // also multiply by random coefficient to prevent making lots of requests
          // at the same time when lots of requests fail at the same time
          retryIn = ((rng.nextDouble() + 0.5) * 500 * pow(2, i)).toInt();
          _printDebug(
              "Download of $path failed. Retrying in ${retryIn}ms... Context: $e");
        } finally {
          progressSubscription?.cancel();
        }
      }
    })();

    return download;
  }

  Future<Download> _downloadInner(String path,
      {bool reDownload = false}) async {
    await Future.wait([localBaseFut, networkBaseFut]);

    var uri = Uri.parse("$networkBase/$path");
    var outPath = "$localBase/$path";

    var file = File(outPath);

    if (!reDownload && await file.exists()) {
      markDownloaded(path);

      return Download(
        downloadProgress: const Stream.empty(),
        file: Future.value(file),
      );
    }

    _printDebug("Downloading $uri...");
    var client = HttpClient();
    var req = await client.getUrl(uri);
    var resp = await req.close();
    var totalDownloadSize =
        resp.contentLength != -1 ? resp.contentLength : null;
    var downloadProgress = StreamController<DownloadProgress>.broadcast();

    await Directory(p.dirname(outPath)).create(recursive: true);

    return Download(
      downloadProgress: downloadProgress.stream,
      file: (() async {
        var outFile = File("$outPath.part");

        var downloadedSize = 0;
        var outSink = outFile.openWrite();
        try {
          await outSink.addStream(resp.map((chunk) {
            downloadedSize += chunk.length;
            downloadProgress.add(DownloadProgress(
              totalDownloadSize: totalDownloadSize,
              downloadedSize: downloadedSize,
            ));
            return chunk;
          }));
        } on IOException {
          try {
            await outFile.delete();
          } catch (_) {}

          rethrow;
        } finally {
          try {
            await outSink.flush();
            await outSink.close();
          } catch (_) {}
        }

        downloadProgress.add(DownloadProgress(
          totalDownloadSize: downloadedSize,
          downloadedSize: downloadedSize,
        ));
        downloadProgress.close();

        await outFile.rename(outPath);
        _printDebug("Finished downloading $uri.");

        if (!await file.exists()) {
          throw Exception(
              "Download of $uri has completed but file wasn't saved to disk?!");
        }

        markDownloaded(path);

        return file;
      })(),
    );
  }

  void _printDebug(String message) {
    if (kDebugMode) print(message);
  }
}

class Download {
  const Download({
    required this.downloadProgress,
    required this.file,
  });

  /// A stream that is updated with download progress as the file is downloaded.
  final Stream<DownloadProgress> downloadProgress;

  /// An object pointing to the downloaded file.
  final Future<File> file;
}

class DownloadProgress {
  const DownloadProgress({
    this.totalDownloadSize,
    required this.downloadedSize,
  });

  /// Total number of bytes that the remote file contains. May be null if unknown.
  final int? totalDownloadSize;

  /// Total number of bytes downloaded so far.
  final int downloadedSize;
}
