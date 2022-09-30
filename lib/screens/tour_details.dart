import 'package:flutter/material.dart';

import '/models.dart';

class TourDetails extends StatefulWidget {
  const TourDetails(this.id, {super.key});

  final String id;

  @override
  State<TourDetails> createState() => _TourDetailsState();
}

class _TourDetailsState extends State<TourDetails> {
  late Future<TourModel> tour;

  @override
  void initState() {
    super.initState();

    tour = TourModel.load(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tour"),
      ),
      body: FutureBuilder<TourModel>(
        future: tour,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Text(snapshot.data!.name);
          } else {
            return Container(
              padding: const EdgeInsets.all(32),
              width: 64,
              height: 64,
              alignment: Alignment.topCenter,
              child: const CircularProgressIndicator(color: Colors.black),
            );
          }
        },
      ),
    );
  }
}
