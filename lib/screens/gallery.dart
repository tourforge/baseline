import 'package:flutter/material.dart';

//import 'package:http/http.dart' as http;
// Future<http.Response> fetchAlbum() {
//   return http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));
// }
class TourGallery extends StatelessWidget {
  const TourGallery({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: TourListView(
        items: [
          TourListItem(
            title: "This Right Here Is An Extremely Long Tour Title"
                "As An Example For Rigorous Testing",
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
      padding: const EdgeInsets.all(5),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(child: items[index]);
      },
    );
  }
}

class TourListItem extends StatelessWidget {
  const TourListItem(
      {super.key,
      required this.title,
      required this.thumbnail,
      required this.eta});

  final String title;
  final Image thumbnail;
  final int eta;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.topStart,
            child: SizedBox(
              width: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset("assets/images/placeholder.webp"),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
              width: 220,
              child: Flexible(
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: AlignmentDirectional.center,
                      child: Flexible(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.bottomCenter,
                      child: Flexible(
                        child: Text(
                          "Estimated Time: ${eta}m",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
