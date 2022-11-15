import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '/models.dart';

class Gallery extends StatefulWidget {
  const Gallery({
    super.key,
    required this.images,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  final List<AssetModel> images;
  final EdgeInsetsGeometry padding;

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: widget.padding,
      itemCount: widget.images.length,
      itemBuilder: (context, index) {
        return InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
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
            child: Image.file(File(widget.images[index].fullPath)),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(width: 8);
      },
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
  late int currentPage = widget.initialImage;

  @override
  void initState() {
    super.initState();

    controller.addListener(_onPageControllerUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(_onPageControllerUpdate);

    super.dispose();
  }

  void _onPageControllerUpdate() {
    if (!controller.hasClients) return;

    if (controller.page != null && controller.page!.round() != currentPage) {
      setState(() {
        currentPage = controller.page!.round();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var currentImage = widget.images[currentPage];

    return Scaffold(
      body: Stack(
        children: [
          PhotoViewGallery(
            pageController: controller,
            pageOptions: [
              for (var image in widget.images)
                PhotoViewGalleryPageOptions(
                  imageProvider: FileImage(File(image.fullPath)),
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
          ),
          if (currentImage.meta?.alt != null)
            IgnorePointer(
              ignoring: true,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Material(
                    color: Colors.black45,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          widget.images[currentPage].meta!.alt!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (currentImage.meta?.alt != null ||
              currentImage.meta?.attribution != null)
            IgnorePointer(
              ignoring: true,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Material(
                    color: Colors.black45,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (currentImage.meta?.alt != null)
                              Text(
                                currentImage.meta!.alt!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            if (currentImage.meta?.alt != null &&
                                currentImage.meta?.attribution != null)
                              const SizedBox(height: 8.0),
                            if (currentImage.meta?.attribution != null)
                              Text(
                                currentImage.meta!.attribution!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
