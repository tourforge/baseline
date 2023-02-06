import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../models/data.dart';
import '../widgets/asset_image_builder.dart';
import '../widgets/gallery.dart';

class PoiDetails extends StatefulWidget {
  const PoiDetails(this.poi, {super.key});

  final PoiModel poi;

  @override
  State<PoiDetails> createState() => _PoiDetailsState();
}

class _PoiDetailsState extends State<PoiDetails>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: MultiSliver(
              pushPinnedChildren: false,
              children: [
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: kToolbarHeight + 5,
                  expandedHeight: 200.0,
                  leading: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: "Back",
                    icon: Icon(Icons.adaptive.arrow_back),
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.passthrough,
                      children: [
                        if (widget.poi.gallery.isNotEmpty)
                          AssetImageBuilder(
                            widget.poi.gallery.first,
                            builder: (image) {
                              return Image(
                                image: image,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        Positioned.fill(
                          child: Container(
                              color: const Color.fromARGB(64, 0, 0, 0)),
                        ),
                      ],
                    ),
                    centerTitle: true,
                    expandedTitleScale: 1.0,
                    title: LayoutBuilder(builder: (context, constraints) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 56.0),
                        child: Text(
                          widget.poi.name,
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: Theme.of(context)
                                        .appBarTheme
                                        .foregroundColor,
                                  ),
                          textAlign: TextAlign.center,
                          maxLines: constraints.maxHeight > 90 ? 3 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ),
                  forceElevated: innerBoxIsScrolled,
                ),
              ],
            ),
          ),
        ],
        body: Builder(builder: (context) {
          return CustomScrollView(
            slivers: [
              SliverOverlapInjector(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 6)),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Material(
                    elevation: 3,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    type: MaterialType.card,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 12.0, bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Description",
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.poi.desc,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 250,
                  child: Gallery(images: widget.poi.gallery),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 6)),
            ],
          );
        }),
      ),
    );
  }
}
