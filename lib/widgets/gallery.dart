import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '/models.dart';

class Gallery extends StatefulWidget {
  const Gallery({
    super.key,
    required this.images,
  });

  final List<AssetModel> images;

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GalleryPage(
                    images: widget.images,
                    initialImage: index,
                  ),
                ),
              );
            },
            child: Material(
              elevation: 3,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(widget.images[index].fullPath),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(width: 8);
        },
      ),
    );
  }
}

class GalleryPage extends StatefulWidget {
  const GalleryPage({
    super.key,
    required this.images,
    required this.initialImage,
  });

  final List<AssetModel> images;
  final int initialImage;

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late final PageController controller =
      PageController(initialPage: widget.initialImage);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PhotoViewGallery(
            pageController: controller,
            pageOptions: [
              for (var image in widget.images)
                PhotoViewGalleryPageOptions(
                  imageProvider: AssetImage(image.fullPath),
                ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(64, 0, 0, 0),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    tooltip: "Close",
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}