import 'package:flutter/material.dart';

class DetailsButton extends StatefulWidget {
  const DetailsButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final void Function() onPressed;

  @override
  State<StatefulWidget> createState() => DetailsButtonState();
}

class DetailsButtonState extends State<DetailsButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Material(
        type: MaterialType.card,
        child: InkWell(
          onTap: widget.onPressed,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Icon(
                  size: 32,
                  widget.icon,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
