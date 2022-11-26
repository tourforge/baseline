import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';

class DownloadManager {
  DownloadManager(this.localBaseFut, this.networkBaseFut) {
    localBaseFut.then((value) => localBase = value);
    networkBaseFut.then((value) => networkBase = value);
  }

  static late final DownloadManager instance;

  final Future<String> localBaseFut;
  final Future<String> networkBaseFut;
  final Map<String, Future<Download>> _currentDownloads = {};
  final Set<String> _downloadedAssetNames = {};

  late final String localBase;
  late final String networkBase;

  void markDownloaded(String path) {
    _downloadedAssetNames.add(path);
  }

  bool isDownloaded(String path) => _downloadedAssetNames.contains(path);

  Future<Download> download(String path, [String? localPath]) async {
    await Future.wait([localBaseFut, networkBaseFut]);

    var uri = Uri.parse("$networkBase/$path");
    var outPath = "$localBase/${localPath ?? path}";

    var file = File(outPath);

    var currentDownloadCompleter = Completer<Download>();

    if (_currentDownloads.containsKey(path)) {
      return _currentDownloads[path]!;
    } else {
      _currentDownloads[path] = currentDownloadCompleter.future;
    }

    await Directory(p.dirname(outPath)).create(recursive: true);

    if (await file.exists()) {
      markDownloaded(path);

      var res = Download(
        downloadSize: 0,
        downloadProgress: const Stream.empty(),
        file: Future.value(file),
      );

      currentDownloadCompleter.complete(res);

      return res;
    }

    _printDebug("Downloading $uri...");
    var client = HttpClient();
    var req = await client.getUrl(uri);
    var resp = await req.close();
    var downloadSize = resp.contentLength != -1 ? resp.contentLength : null;
    var downloadProgress = StreamController<int>();

    var dl = Download(
      downloadSize: downloadSize,
      downloadProgress: downloadProgress.stream,
      file: (() async {
        var outFile = File("$outPath.part");

        var downloadedSize = 0;
        var outSink = outFile.openWrite();
        await outSink.addStream(resp.map((event) {
          downloadedSize += event.length;
          downloadProgress.add(downloadedSize);
          return event;
        }));
        await outSink.flush();
        await outSink.close();
        downloadProgress.add(downloadedSize);
        downloadProgress.close();

        await outFile.rename(outPath);
        _printDebug("Finished downloading $uri.");

        if (!await file.exists()) {
          currentDownloadCompleter.completeError(Exception(
              "Download of $uri has completed but file wasn't saved to disk?!"));
          throw Exception(
              "Download of $uri has completed but file wasn't saved to disk?!");
        }

        markDownloaded(path);

        return file;
      })(),
    );

    currentDownloadCompleter.complete(dl);

    return dl;
  }

  void _printDebug(String message) {
    if (kDebugMode) print(message);
  }
}

class Download {
  const Download({
    required this.downloadSize,
    required this.downloadProgress,
    required this.file,
  });

  /// The size of the file to be downloaded. Null if the download size is unknown.
  /// Zero if the file is already downloaded.
  final int? downloadSize;

  /// A stream that's updated with the number of bytes of the file downloaded so
  /// far. If the file is already downloaded, this stream is empty.
  final Stream<int> downloadProgress;

  /// An object pointing to the downloaded file.
  final Future<File> file;
}
