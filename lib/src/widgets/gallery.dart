import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../data.dart';
import '../widgets/asset_image_builder.dart';

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
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        PageView(
          onPageChanged: (index) => setState(() => _currentImageIndex = index),
          children: [
            for (var index in widget.images.asMap().keys)
              InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => GalleryScreen(
                        images: widget.images,
                        initialImage: index,
                      ),
                    ),
                  );
                },
                child: AssetImageBuilder(
                  widget.images[index],
                  builder: (image) {
                    return Image(
                      image: image,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              )
          ],
        ),
        if (widget.images.length > 1)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var index in widget.images.asMap().keys)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          decoration: BoxDecoration(
                            color: index == _currentImageIndex
                                ? Colors.white.withAlpha(192)
                                : Colors.white.withAlpha(96),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({
    super.key,
    required this.images,
    required this.initialImage,
  });

  final List<AssetModel> images;
  final int initialImage;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
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
                  imageProvider: image.imageProvider,
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
          _GalleryScreenMetadataOverlay(image: currentImage),
        ],
      ),
    );
  }
}

class _GalleryScreenMetadataOverlay extends StatelessWidget {
  const _GalleryScreenMetadataOverlay({required this.image});

  final AssetModel image;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
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
                    if (image.alt != "")
                      Text(
                        image.alt,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    if (image.alt != "" && image.attrib != "")
                      const SizedBox(height: 8.0),
                    if (image.attrib != "")
                      Text(
                        image.attrib,
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
    );
  }
}
