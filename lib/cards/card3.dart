import 'package:flutter/material.dart';
import '../cardmodule.dart';

class card3 extends StatefulWidget {
  const card3({super.key});

  @override
  State<card3> createState() => _card3State();
}

class _card3State extends State<card3> {
  @override
  Widget build(BuildContext context) {
    return cardModule(
      key: UniqueKey(),
      card_num: 3,
    );
  }
}
