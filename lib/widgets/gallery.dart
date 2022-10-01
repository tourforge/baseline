import 'package:flutter/material.dart';

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
          return Material(
            elevation: 3,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(widget.images[index].fullPath),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(width: 8);
        },
      ),
    );
  }
}
