import 'package:flutter/material.dart';
import './constants.dart';
import './boxWidg.dart';

class ColWidget extends StatefulWidget {
  const ColWidget({super.key});

  @override
  State<ColWidget> createState() => _ColWidgetState();
}

class _ColWidgetState extends State<ColWidget> {
  int count = 0;
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 3 / 4,
          mainAxisExtent: 22,
          crossAxisCount: 22,
        ),
        itemBuilder: (BuildContext context, int index) {});
  }
}
