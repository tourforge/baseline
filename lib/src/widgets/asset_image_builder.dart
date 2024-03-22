import 'package:flutter/material.dart';

import '../data.dart';

class AssetImageBuilder extends StatefulWidget {
  const AssetImageBuilder(
    this.asset, {
    super.key,
    required this.builder,
  });

  final AssetModel asset;
  final Image Function(ImageProvider provider) builder;

  @override
  State<AssetImageBuilder> createState() => _AssetImageBuilderState();
}

class _AssetImageBuilderState extends State<AssetImageBuilder> {
  late Future<bool> assetIsDownloaded = widget.asset.isDownloaded;

  @override
  void didUpdateWidget(covariant AssetImageBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.asset.id != widget.asset.id) {
      assetIsDownloaded = widget.asset.isDownloaded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: assetIsDownloaded,
      builder: (context, isDownloadedSnapshot) {
        if (isDownloadedSnapshot.data == true) {
          return widget.builder(widget.asset.imageProvider);
        } else if (isDownloadedSnapshot.data == false) {
          return Stack(
            fit: StackFit.passthrough,
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              widget.builder(widget.asset.imageProvider),
            ],
          );
        } else if (isDownloadedSnapshot.error != null) {
          return const Text("Error while checking if image is downloaded");
        } else {
          return widget.builder(widget.asset.imageProvider);
        }
      },
    );
  }
}
