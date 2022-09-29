import 'package:flutter/material.dart';

class TourGallery extends StatelessWidget {
  const TourGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Evresi"),
      ),
      body: TourListView(
        items: [
          TourListItem(
            title: "This is a Tour with a Name of Maximum Typical Length",
            thumbnail: Image.asset("assets/images/placeholder.webp"),
            eta: 999,
          ),
          TourListItem(
            title: "Short Title",
            thumbnail: Image.asset("assets/images/placeholder.webp"),
            eta: 0,
          ),
        ],
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
  });

  final String title;
  final Image thumbnail;
  final int eta;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                child: Image.asset("assets/images/placeholder.webp"),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 50,
                      child: Center(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.subtitle1,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    Text(
                      "$eta minute${eta == 1 ? "" : "s"}",
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
    );
  }
}
