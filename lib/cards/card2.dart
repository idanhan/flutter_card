import 'package:flutter/material.dart';
import '../cardmodule.dart';

class card2 extends StatefulWidget {
  const card2({super.key});

  @override
  State<card2> createState() => _card2State();
}

class _card2State extends State<card2> {
  @override
  Widget build(BuildContext context) {
    return cardModule(
      key: UniqueKey(),
      card_num: 2,
    );
  }
}
