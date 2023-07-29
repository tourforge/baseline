import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:opentourguide/opentourguide.dart';

import '/theme.dart';

Future<void> main() async {
  await otbGuideInit(OtbGuideAppConfig(
    appName: "OpenTourGuide",
    appDesc:
        '''OpenTourGuide is the example app for the OpenTourBuilder Guide library.''',
    baseUrl: "https://fsrv.fly.dev/v2",
    lightThemeData: lightThemeData,
    darkThemeData: darkThemeData,
  ));
  runApp(const OtbGuideApp());
}

class OtbGuideApp extends StatelessWidget {
  const OtbGuideApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenTourGuide',
      theme: SchedulerBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? darkThemeData
          : lightThemeData,
      builder: (context, child) {
        if (child != null) {
          return ScrollConfiguration(
            behavior: const BouncingScrollBehavior(),
            child: child,
          );
        } else {
          return const SizedBox();
        }
      },
      home: const _TourList(),
    );
  }
}

class BouncingScrollBehavior extends ScrollBehavior {
  const BouncingScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

class _TourList extends StatefulWidget {
  const _TourList({super.key});

  @override
  State<_TourList> createState() => _TourListState();
}

class _TourListState extends State<_TourList> {
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
              itemBuilder: (BuildContext context, int index) {
                return _TourListItem(tours[index]);
              },
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

class _TourListItem extends StatelessWidget {
  const _TourListItem(this.tour);

  final TourIndexEntry tour;
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.card,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      elevation: 3,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final tourModel = await tour.loadDetails();

          // ignore: use_build_context_synchronously
          if (!context.mounted) return;

          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => TourDetails(tourModel)));
        },
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Center(
            child: Text(
              tour.name,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
