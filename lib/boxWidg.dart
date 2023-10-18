import 'package:flutter/material.dart';
import './constants.dart';

class BoxWidget1 extends StatelessWidget {
  final height;
  final card_color;
  final card_size;
  final width;

  const BoxWidget1(
      {@required this.height,
      @required this.card_size,
      @required this.card_color,
      @required this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(20.0),
      child: const Card(
        color: COLOR_GREY,
      ),
    );
  }
}
