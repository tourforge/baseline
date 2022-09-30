import 'package:flutter/material.dart';

class ItemDetails extends StatelessWidget {
  const ItemDetails({
    super.key,
    required this.name,
    required this.desc,
    required this.gallery,
  });

  final String name;
  final String desc;
  final List<String> gallery;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
