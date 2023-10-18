import 'package:flutter/material.dart';
import '../cardmodule.dart';

class card5 extends StatefulWidget {
  const card5({super.key});

  @override
  State<card5> createState() => _card5State();
}

class _card5State extends State<card5> {
  @override
  Widget build(BuildContext context) {
    return cardModule(
      key: UniqueKey(),
      card_num: 5,
    );
  }
}
