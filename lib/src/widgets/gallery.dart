import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../models/data.dart';
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
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        PageView(
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /*IconButton(
              onPressed: () {},
              iconSize: 48,
              icon: const Icon(
                Icons.arrow_left,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {},
              iconSize: 48,
              icon: const Icon(
                Icons.arrow_right,
                color: Colors.white,
              ),
            ),*/
          ],
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

class _GalleryScreenMetadataOverlay extends StatefulWidget {
  const _GalleryScreenMetadataOverlay({required this.image});

  final AssetModel image;

  @override
  State<_GalleryScreenMetadataOverlay> createState() =>
      _GalleryScreenMetadataOverlayState();
}

class _GalleryScreenMetadataOverlayState
    extends State<_GalleryScreenMetadataOverlay> {
  late final Future<AssetMeta?> meta = widget.image.meta;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: meta,
      builder: (context, snapshot) {
        final meta = snapshot.data;

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
                        if (meta?.alt != null)
                          Text(
                            meta!.alt!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        if (meta?.alt != null && meta?.attribution != null)
                          const SizedBox(height: 8.0),
                        if (meta?.attribution != null)
                          Text(
                            meta!.attribution!,
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
      },
    );
  }
}
