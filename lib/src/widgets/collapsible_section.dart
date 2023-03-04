import 'package:flutter/material.dart';

class CollapsibleSection extends StatefulWidget {
  const CollapsibleSection({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  State<StatefulWidget> createState() => CollapsibleSectionState();
}

class CollapsibleSectionState extends State<CollapsibleSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 64,
          child: Material(
            type: MaterialType.card,
            child: InkWell(
              onTap: () {
                setState(() => _expanded = !_expanded);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? -0.5 : 0,
                      duration: const Duration(milliseconds: 192),
                      child: const Icon(
                        size: 32,
                        Icons.expand_more,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: _expanded ? null : 0,
          child: widget.child,
        )
      ],
    );
  }
}
