import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cardmodule.dart';
import '../newCard.dart';

class CardList extends ChangeNotifier {
  final List<NewCard> _cardsList = [];
  List<NewCard> get cardList => _cardsList;

  void addCard(NewCard card) {
    _cardsList.add(card);
    notifyListeners();
  }

  Widget getCardIndex(int index) {
    return _cardsList[index];
  }

  bool isEmpty() {
    return _cardsList.isEmpty;
  }

  void removeCardAtIndex(int index) {
    _cardsList.removeAt(index);
    notifyListeners();
  }

  void removeAll() {
    if (_cardsList.isNotEmpty) {
      _cardsList.removeRange(0, _cardsList.length);
      notifyListeners();
    }
  }

  int cardLen() {
    return _cardsList.length;
  }

  void setCardValAt(int index, NewCard card) {
    _cardsList[index].cardName = card.cardName;
    notifyListeners();
  }

  void insertByFolderNCard(NewCard card, int foldernum) {
    if (_cardsList.isEmpty) {
      _cardsList.add(card);
      return;
    }
    final int lastind =
        _cardsList.lastIndexWhere((element) => element.foldernum == foldernum);
    if (lastind != -1) {
      _cardsList.insert(lastind + 1, card);
    } else {
      final int last = _cardsList
          .lastIndexWhere((element) => element.foldernum == foldernum - 1);
      _cardsList.insert(last + 1, card);
      print('added to card ${_cardsList.length}');
    }
    print("added to card ${lastind}");
    notifyListeners();
  }
}
