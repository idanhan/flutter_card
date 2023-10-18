import 'package:flutter/material.dart';
import '../cardmodule.dart';

class card4 extends StatefulWidget {
  const card4({super.key});

  @override
  State<card4> createState() => _card4State();
}

class _card4State extends State<card4> {
  @override
  Widget build(BuildContext context) {
    return cardModule(
      key: UniqueKey(),
      card_num: 4,
    );
  }
}
