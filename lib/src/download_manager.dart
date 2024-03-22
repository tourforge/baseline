import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'data.dart';

class DownloadFailedException implements Exception {
  DownloadFailedException(this.response);

  final HttpClientResponse? response;
}

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

  /// Returns the current in-progress download of the given path, if any.
  Download? downloadInProgress(String path) => _currentDownloads[path];

  /// Checks if the given file is already downloaded.
  Future<bool> isDownloaded(String path) => File("$localBase/$path").exists();

  /// A cached version of [isDownloaded]. Might return false when the given path
  /// is actually downloaded.
  bool cachedIsDownloaded(String path) => _downloadedAssetNames.contains(path);

  MultiDownload downloadAll(Iterable<AssetModel> assets,
      [Sink<DownloadProgress>? downloadProgress]) {
    var downloads = <Download>[];
    for (final asset in HashSet<AssetModel>.from(assets)) {
      downloads.add(download(asset));
    }

    return MultiDownload.of(downloads);
  }

  /// Downloads the asset with the given `path`. If there is already a download
  /// in progress for that asset, that download object is returned. Retries with
  /// exponential backoff in the case of network error.
  Download download(AssetModel asset,
      {bool reDownload = false, int? maxRetries}) {
    var name = asset.id;

    var currentDownload = _currentDownloads[name];
    if (currentDownload != null) return currentDownload;

    final downloadProgress = StreamController<DownloadProgress>.broadcast();

    return _currentDownloads[name] = Download(
      downloadProgress: downloadProgress.stream,
      file: (() async {
        await Future.wait([localBaseFut, networkBaseFut]);

        var srcUri = Uri.parse("$networkBase/$name");
        var outDir = p.dirname("$localBase/$name");
        var outPath = "$localBase/$name";
        var partPath = "$localBase/$name.part";

        // don't redownload if it's unnecessary
        if (!reDownload && await File(outPath).exists()) {
          _markDownloaded(name);

          await downloadProgress.close();
          return File(outPath);
        }

        // create the directory where our files will go in case it doesn't exist
        await Directory(outDir).create(recursive: true);

        final rng = Random();
        var retryIn = 0;
        for (var i = 0; maxRetries != null ? i < maxRetries : true; i++) {
          if (retryIn > 0) {
            await Future.delayed(Duration(milliseconds: retryIn));
          }

          try {
            // attempt the download
            await _attemptDownload(srcUri, File(partPath), downloadProgress);

            // successfully downloaded!
            await downloadProgress.close();
            await File(partPath).rename(outPath);

            _markDownloaded(name);

            return File(outPath);
          } on Exception catch (e) {
            if (e is DownloadFailedException) {
              if (asset.required) {
                rethrow;
              } else {
                return File(outPath);
              }
            }

            // exponential backoff: wait 0ms, then 500ms, then 1000ms, then 2000ms...
            // also multiply by random coefficient to prevent making lots of requests
            // at the same time when lots of requests fail at the same time
            retryIn = ((rng.nextDouble() + 0.5) * 500 * pow(2, i)).toInt();
            _printDebug(
                "Download of $name failed. Retrying in ${retryIn}ms... Context: $e");
          }
        }

        throw DownloadFailedException(null);
      })(),
    );
  }

  Future<void> _attemptDownload(
      Uri srcUri, File outFile, Sink<DownloadProgress> progress) async {
    var client = HttpClient();
    var req = await client.getUrl(srcUri);
    var resp = await req.close();

    if (resp.statusCode != 200) {
      throw DownloadFailedException(resp);
    }

    var totalDownloadSize =
        resp.contentLength != -1 ? resp.contentLength : null;

    var downloadedSize = 0;
    var outSink = outFile.openWrite();
    try {
      await outSink.addStream(resp.map((chunk) {
        downloadedSize += chunk.length;
        progress.add(DownloadProgress(
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

    progress.add(DownloadProgress(
      totalDownloadSize: downloadedSize,
      downloadedSize: downloadedSize,
    ));
  }

  Future<void> delete(AssetModel asset) async {
    await asset.downloadedFile.delete();
    _downloadedAssetNames.remove(asset.id);
  }

  void _printDebug(String message) {
    if (kDebugMode) print(message);
  }

  void _markDownloaded(String path) {
    _downloadedAssetNames.add(path);
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

class MultiDownload {
  MultiDownload({
    required this.downloadProgress,
    required this.completed,
  });

  factory MultiDownload.of(List<Download> downloads) {
    var controller = StreamController<DownloadProgress>.broadcast();

    var progresses = <DownloadProgress>[];
    for (final download in downloads) {
      final index = progresses.length;

      progresses.add(const DownloadProgress(downloadedSize: 0));
      download.downloadProgress.listen((progress) {
        progresses[index] = progress;

        controller.add(DownloadProgress.all(progresses));
      });
    }

    return MultiDownload(
      downloadProgress: controller.stream,
      completed: Future.wait(downloads.map((d) => d.file)),
    );
  }

  /// A stream that is updated with download progress as the files are downloaded.
  final Stream<DownloadProgress> downloadProgress;

  /// A future that completes when the download is completed.
  final Future<void> completed;
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

  static DownloadProgress all(Iterable<DownloadProgress> progresses) =>
      progresses.reduce(
        (a, b) => DownloadProgress(
          totalDownloadSize:
              (a.totalDownloadSize ?? 0) + (b.totalDownloadSize ?? 0),
          downloadedSize: a.downloadedSize + b.downloadedSize,
        ),
      );
}
