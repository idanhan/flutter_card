import 'package:flutter/material.dart';

class cardData {
  final String id;
  final String? title;
  final bool is_done;
  final int key;

  cardData(
      {required this.id, required this.is_done, this.title, required this.key});
}
