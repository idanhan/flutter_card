import 'package:flutter/material.dart';
import '../cardmodule.dart';

class card1 extends StatefulWidget {
  const card1({super.key});

  @override
  State<card1> createState() => _card1State();
}

class _card1State extends State<card1> {
  @override
  Widget build(BuildContext context) {
    return cardModule(
      card_num: 1,
      key: UniqueKey(),
    );
  }
}
