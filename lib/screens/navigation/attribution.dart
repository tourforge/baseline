import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

List<_Attribution> get _attributions => [
      _Attribution(
        text: "© TomTom",
        usage: "satellite imagery",
        uri: Uri.parse("https://www.tomtom.com/"),
      ),
      _Attribution(
        text: "© OpenMapTiles",
        usage: "map styles",
        uri: Uri.parse("https://openmaptiles.org/"),
      ),
      _Attribution(
        text: "© OpenStreetMap",
        usage: "map data",
        uri: Uri.parse("https://www.openstreetmap.org/copyright"),
      ),
    ];

class _Attribution {
  const _Attribution({
    required this.text,
    required this.usage,
    required this.uri,
  });

  final String text;
  final String usage;
  final Uri uri;
}

class AttributionInfo extends StatefulWidget {
  const AttributionInfo({super.key});

  @override
  State<AttributionInfo> createState() => _AttributionInfoState();
}

class _AttributionInfoState extends State<AttributionInfo> {
  late final Timer _autoHideTimer;

  bool _hidden = false;

  void _autoHide() {
    if (!mounted) return;

    setState(() => _hidden = true);
  }

  @override
  void initState() {
    super.initState();
    _autoHideTimer = Timer(const Duration(seconds: 5), _autoHide);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        IgnorePointer(
          ignoring: _hidden,
          child: AnimatedOpacity(
            opacity: _hidden ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastLinearToSlowEaseIn,
            child: Material(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius:
                  const BorderRadius.only(topRight: Radius.circular(16.0)),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(DialogRoute(
                      context: context,
                      builder: (context) => const AttributionDialog()));
                },
                borderRadius:
                    const BorderRadius.only(topRight: Radius.circular(16.0)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Maps",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(
                            width: 32,
                            height: 32,
                          )
                        ],
                      ),
                      const SizedBox(width: 6.0),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var attrib in _attributions)
                            Text(
                              attrib.text,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            _autoHideTimer.cancel;
            setState(() => _hidden = !_hidden);
          },
          iconSize: 32,
          color: const Color.fromARGB(255, 100, 177, 255),
          icon: const Icon(Icons.info),
        ),
      ],
    );
  }
}

class AttributionDialog extends StatelessWidget {
  const AttributionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Maps Attribution"),
      children: [
        for (var attrib in _attributions)
          InkWell(
            onTap: () {
              launchUrl(attrib.uri, mode: LaunchMode.externalApplication);
            },
            child: SimpleDialogOption(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: Text(
                "${attrib.text} (${attrib.usage})",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
      ],
    );
  }
}
