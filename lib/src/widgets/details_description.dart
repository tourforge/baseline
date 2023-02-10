import 'package:flutter/material.dart';

class DetailsDescription extends StatelessWidget {
  const DetailsDescription({
    super.key,
    this.header = "Description",
    required this.desc,
  });

  final String? header;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 20.0, right: 20.0, top: 20.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null)
            Text(
              header!,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: Colors.grey),
            ),
          if (header != null) const SizedBox(height: 6),
          Text(
            desc,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
