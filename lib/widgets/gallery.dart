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
        padding: const EdgeInsets.all(8),
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(24, 0, 0, 0),
                  offset: Offset(1.5, 1.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              child: Image.asset(widget.images[index].fullPath),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(width: 12);
        },
      ),
    );
  }
}
