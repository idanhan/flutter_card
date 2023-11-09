import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cardmodule.dart';

class cardModulePro extends ChangeNotifier {
  final List<cardModule> _moduleList = [];

  List<cardModule> get cardModulepro => _moduleList;
  void add(cardModule card) {
    _moduleList.add(card);
    notifyListeners();
  }

  void remove(int index) {
    _moduleList.removeAt(index);
    notifyListeners();
  }

  void removeAll() {
    if (_moduleList.isNotEmpty) {
      _moduleList.removeRange(0, _moduleList.length);
      notifyListeners();
    }
  }

  void changedone(int index) {
    _moduleList[index].is_done = true;
    notifyListeners();
  }

  bool isEmpty() {
    return _moduleList.isEmpty;
  }

  cardModule getModIndex(int index) {
    return _moduleList[index];
  }

  int cardLen() {
    return _moduleList.length;
  }

  void setvalAt(int index, cardModule card) {
    _moduleList[index] = card;
    notifyListeners();
  }

  void insertByFolderNCard(cardModule module, int foldernum) {
    if (_moduleList.isEmpty) {
      _moduleList.add(module);
      return;
    }
    final int lastind =
        _moduleList.lastIndexWhere((element) => element.folderNum == foldernum);
    if (lastind != -1) {
      _moduleList.insert(lastind + 1, module);
    } else {
      final int last = _moduleList
          .lastIndexWhere((element) => element.folderNum == foldernum - 1);
      _moduleList.insert(last + 1, module);
      print('added to card ${last}');
    }

    print("added to card ${lastind}");
    notifyListeners();
  }
}
