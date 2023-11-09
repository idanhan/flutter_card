import 'package:cards2_app/constants.dart';
import 'package:flutter/material.dart';

class NewCard extends StatelessWidget {
  final int cardnum;
  int foldernum;
  String? cardName;
  NewCard(
      {super.key,
      required this.cardnum,
      required this.foldernum,
      this.cardName});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: COLOR_DARK_BLUE,
      child: cardName != null
          ? Center(
              child: Text(
                cardName!,
                style: TextStyle(color: COLOR_WHITE),
              ),
            )
          : const SizedBox(),
    );
  }
}
