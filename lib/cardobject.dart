import 'package:cloud_firestore/cloud_firestore.dart';

class cardPage {
  final String? title;
  final String? frontText;
  final String? backText;
  final String? frontImagepath;
  final String? backImagepath;
  final bool? is_done;
  final int? cardnum;

  cardPage(
      {this.backImagepath,
      this.backText,
      this.frontImagepath,
      this.frontText,
      this.title,
      this.is_done,
      this.cardnum});
  factory cardPage.fromFireStore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    return cardPage(
        title: data?['title'],
        frontText: data?['frontText'],
        backText: data?['backText'],
        frontImagepath: data?['frontImagepath'],
        backImagepath: data?['backImagepath'],
        is_done: data?['is_done'],
        cardnum: data?['cardnum']);
  }
  Map<String, dynamic> toFireStore() {
    return {
      if (title != null) "title": title,
      if (frontText != null) "frontText": frontText,
      if (frontImagepath != null) "frontImagepath": frontImagepath,
      if (backText != null) "backText": backText,
      if (backImagepath != null) "backImagepath": backImagepath,
      if (is_done != null) "is_done": is_done,
      if (cardnum != null) "cardnum": cardnum,
    };
  }
}
