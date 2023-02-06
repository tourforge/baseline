import 'package:flutter/material.dart';

import '../config.dart';
import '../models/data.dart';
import '../screens/about.dart';
import '../screens/tour_details.dart';
import '../widgets/asset_image_builder.dart';

class TourList extends StatefulWidget {
  const TourList({super.key});

  @override
  State<TourList> createState() => _TourListState();
}

class _TourListState extends State<TourList> {
  late Future<List<TourSummary>> tours;

  @override
  void initState() {
    super.initState();

    tours = TourSummary.list();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appConfig.appName),
        actions: [
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            tooltip: 'More',
            elevation: 1.0,
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: "About",
                child: Text("About"),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case "About":
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const About()));
                  break;
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<TourSummary>>(
        future: tours,
        builder: (context, snapshot) {
          var tours = snapshot.data;

          if (tours != null) {
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: tours.length,
              itemBuilder: (BuildContext context, int index) =>
                  _TourListItem(tours[index]),
            );
          } else {
            return Container(
              padding: const EdgeInsets.all(32.0),
              alignment: Alignment.topCenter,
              child: const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(color: Colors.black),
              ),
            );
          }
        },
      ),
    );
  }
}

class _TourListItem extends StatefulWidget {
  const _TourListItem(this.tour);

  final TourSummary tour;

  @override
  State<_TourListItem> createState() => _TourListItemState();
}

class _TourListItemState extends State<_TourListItem> {
  final ValueNotifier<double> downloadProgress = ValueNotifier(0);

  late final _DownloadIconClipper _clipper =
      _DownloadIconClipper(downloadProgress);
  late Future<bool> _isDownloaded = TourModel.isDownloaded(widget.tour.id);

  @override
  void dispose() {
    _clipper.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.card,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      elevation: 3,
      child: InkWell(
        onTap: () async {
          var isDownloaded = await _isDownloaded;
          if (!mounted) return;

          if (isDownloaded) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TourDetails(widget.tour)));
          } else if (downloadProgress.value == 0) {
            var shouldDownload = await Navigator.of(context).push<bool>(
                DialogRoute(
                    context: context, builder: (context) => _DownloadDialog()));
            if (!mounted) return;

            if (shouldDownload == true) {
              await TourModel.download(
                widget.tour.id,
                _CallbackSink((progress) => downloadProgress.value = progress),
              );

              downloadProgress.value = 1;

              setState(() {
                _isDownloaded = Future.value(true);
              });
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('This tour is still downloading.')));
          }
        },
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: SizedBox(
          height: 130,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 130,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  child: widget.tour.thumbnail != null
                      ? AssetImageBuilder(
                          widget.tour.thumbnail!,
                          builder: (image) {
                            return Image(
                              image: image,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : const SizedBox(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                        child: Center(
                          child: Text(
                            widget.tour.name,
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Text(
                        "about 25 minute${25 == 1 ? "" : "s"} long",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.grey),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              FutureBuilder<bool>(
                future: _isDownloaded,
                builder: (context, isDownloadedSnapshot) {
                  if (isDownloadedSnapshot.data == true) {
                    return const SizedBox(width: 20);
                  } else if (isDownloadedSnapshot.error == null) {
                    return SizedBox(
                      width: 96,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 4.0,
                                ),
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 245, 245, 245),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(12.0))),
                                child: const Icon(
                                  Icons.download,
                                  size: 40,
                                  color: Color.fromARGB(255, 211, 211, 211),
                                ),
                              ),
                              ClipRect(
                                clipper: _DownloadIconClipper(downloadProgress),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                    horizontal: 4.0,
                                  ),
                                  decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 61, 252, 109),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12.0))),
                                  child: const Icon(
                                    Icons.download,
                                    size: 40,
                                    color: Color.fromARGB(255, 0, 192, 48),
                                  ),
                                ),
                              )
                            ],
                          ),
                          _DownloadPercentage(downloadProgress),
                        ],
                      ),
                    );
                  } else {
                    throw isDownloadedSnapshot.error!;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DownloadPercentage extends StatefulWidget {
  const _DownloadPercentage(this.downloadProgress);

  final ValueNotifier<double> downloadProgress;

  @override
  State<_DownloadPercentage> createState() => _DownloadPercentageState();
}

class _DownloadPercentageState extends State<_DownloadPercentage> {
  late double _currentProgress = widget.downloadProgress.value;

  @override
  void initState() {
    super.initState();

    widget.downloadProgress.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    widget.downloadProgress.removeListener(_onProgressChanged);

    super.dispose();
  }

  void _onProgressChanged() {
    setState(() {
      _currentProgress = widget.downloadProgress.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentProgress != 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          "${(_currentProgress * 100).toInt()}%",
          style: Theme.of(context).textTheme.labelSmall,
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}

class _DownloadIconClipper extends CustomClipper<Rect> {
  _DownloadIconClipper(this.reclip) : super(reclip: reclip) {
    reclip.addListener(_onClipChanged);
  }

  void dispose() {
    reclip.removeListener(_onClipChanged);
  }

  final ValueNotifier<double> reclip;

  late double currentClip = reclip.value;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width, size.height * currentClip);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => true;

  void _onClipChanged() {
    currentClip = reclip.value;
  }
}

class _DownloadDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Download Tour'),
      content: SingleChildScrollView(
        child: ListBody(
          children: const <Widget>[
            Text(
              'This tour must be downloaded before it can be viewed. '
              'Downloading the tour may incur data charges. '
              'It is recommended to connect to WiFi before proceeding.',
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        TextButton(
          child: const Text('Download'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}

class _CallbackSink<T> implements Sink<T> {
  const _CallbackSink(this.callback);

  final void Function(T) callback;

  @override
  void add(T data) {
    callback(data);
  }

  @override
  void close() {}
}
