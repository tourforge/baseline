import 'package:flutter/material.dart';
import 'package:tourforge/src/config.dart';

import '/src/data.dart';
import '/src/screens/tour_details.dart';
import '/src/widgets/asset_image_builder.dart';
import 'about.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
        title: Text(tourForgeConfig.appName),
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
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          Material(
            type: MaterialType.card,
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tours",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    "Below, you will find a list containing the tours currently available "
                    "in ${tourForgeConfig.appName}. Try tapping on one to take a look!",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          FutureBuilder<TourIndex>(
            future: tourIndex,
            builder: (context, snapshot) {
              var tours = snapshot.data?.tours;

              if (tours != null) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const ScrollPhysics(),
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
        ],
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
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        elevation: 3,
        shadowColor: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final tourModel = await widget.tour.loadDetails();
            if (!mounted) return;

            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TourDetails(tourModel)));
          },
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 200,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
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
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                  bottom: 8.0,
                ),
                child: Text(
                  widget.tour.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontSize: 18),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: Wrap(
                  spacing: 4.0,
                  runSpacing: 8.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Icon(
                      Icons.download,
                      size: 20,
                      color: Color.fromARGB(255, 160, 160, 160),
                    ),
                    Text(
                      "Download",
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: const Color.fromARGB(255, 160, 160, 160)),
                    ),
                    const SizedBox(width: 4.0),
                    const Icon(
                      Icons.directions_car,
                      size: 20,
                      color: Color.fromARGB(255, 160, 160, 160),
                    ),
                    Text(
                      "Driving Tour",
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: const Color.fromARGB(255, 160, 160, 160)),
                    ),
                    const SizedBox(width: 4.0),
                    const Icon(
                      Icons.route,
                      size: 20,
                      color: Color.fromARGB(255, 160, 160, 160),
                    ),
                    Text(
                      "18 Stops",
                      style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: const Color.fromARGB(255, 160, 160, 160)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
