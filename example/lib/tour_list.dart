import 'package:flutter/material.dart';

import 'package:opentourguide/opentourguide.dart';

class TourList extends StatefulWidget {
  const TourList({super.key});

  @override
  State<TourList> createState() => _TourListState();
}

class _TourListState extends State<TourList> {
  late Future<TourIndex> tourIndex;

  @override
  void initState() {
    super.initState();

    tourIndex = TourIndex.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OpenTourGuide"),
      ),
      body: FutureBuilder<TourIndex>(
        future: tourIndex,
        builder: (context, snapshot) {
          var tours = snapshot.data?.tours;

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
              child: SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
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

  final TourIndexEntry tour;

  @override
  State<_TourListItem> createState() => _TourListItemState();
}

class _TourListItemState extends State<_TourListItem> {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.card,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      elevation: 3,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final tourModel = await widget.tour.loadDetails();
          if (!mounted) return;

          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => TourDetails(tourModel)));
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
