import 'dart:io';

import 'package:flutter/material.dart';

import '/models.dart';
import '/screens/tour_details.dart';

class TourGallery extends StatefulWidget {
  const TourGallery({super.key});

  @override
  State<TourGallery> createState() => _TourGalleryState();
}

class _TourGalleryState extends State<TourGallery> {
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
        title: const Text("Evresi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            tooltip: 'Help',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('TODO: Show help page'))); // TODO
            },
            color: Colors.white,
          ),
        ],
      ),
      body: FutureBuilder<List<TourSummary>>(
        future: tours,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return TourListView(
              items: [
                for (var tourSummary in snapshot.data!)
                  TourListItem(
                    title: tourSummary.name,
                    thumbnail: tourSummary.thumbnail != null
                        ? Hero(
                            tag: "tourThumbnail",
                            child: Image.file(
                              File(tourSummary.thumbnail!.fullPath),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const SizedBox(),
                    eta: 25,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => TourDetails(tourSummary)));
                    },
                  ),
              ],
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

class TourListView extends StatelessWidget {
  const TourListView({super.key, required this.items});

  final List<TourListItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return items[index];
      },
    );
  }
}

class TourListItem extends StatelessWidget {
  const TourListItem({
    super.key,
    required this.title,
    required this.thumbnail,
    required this.eta,
    required this.onTap,
  });

  final String title;
  final Widget thumbnail;
  final int eta;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.card,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: SizedBox(
          height: 125,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 125,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  child: thumbnail,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                        child: Center(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Text(
                        "Duration: about $eta minute${eta == 1 ? "" : "s"}",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.grey),
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
