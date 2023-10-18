import 'dart:io';
import 'dart:typed_data';

import 'package:cards2_app/boxWidg.dart';
import 'package:cards2_app/cardmodule.dart';
import 'package:cards2_app/cards/card1.dart';
import 'package:cards2_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './col.dart';
import './drawer1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './cardobject.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class HomeScreen2 extends StatefulWidget {
  HomeScreen2({super.key});

  @override
  State<HomeScreen2> createState() => _HomeScreenState2();
}

class _HomeScreenState2 extends State<HomeScreen2> {
  List<Widget> card_list = [];
  List<cardModule> module_card = [];
  List<bool> _ispageready = [];
  List<int> _indexList = [];
  List<int> _cardind = [];
  final _sendtoEmailController = TextEditingController();
  int _cardlen = 0;
  int doclen = 0;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final user = FirebaseAuth.instance.currentUser;
  late Future<int> count;
  int _selectedindex = 0;
  void _onitemtap(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

  List<bool> _isChecked = [];

  String imageNetUrlFront = '';
  String imageNetUrlBack = '';

  int count1 = 1;

  Future<Map<String, dynamic>?> readTitle(int index) async {
    Map<String, dynamic>? titleMap;
    try {
      final docSnap = await FirebaseFirestore.instance
          .collection(user!.email!)
          .doc('card$index')
          .get();

      if (docSnap.exists) {
        titleMap = {
          'title': docSnap.data()?['title'],
          'is_done': docSnap.data()?['is_done'],
        };
      }
    } catch (e) {
      print('Error reading data: $e');
    }

    return titleMap;
  }

  Future<void> deleteDocument(int documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection(user!.email!)
          .doc('card$documentId')
          .delete();
      print('Document successfully deleted');
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  Future<void> _DownloadAndStorageImages(int index) async {
    final client = http.Client();
    final urlBack = Uri.parse(imageNetUrlBack);
    final urlFront = Uri.parse(imageNetUrlFront);
    try {
      final storageFront = FirebaseStorage.instance.ref().child(
          'images/${_sendtoEmailController.text.trim()}/$index/card$index/front');
      final storageBack = FirebaseStorage.instance.ref().child(
          'images/${_sendtoEmailController.text.trim()}/$index/card$index/back');
      final bytesFront = await client.readBytes(urlFront);
      final bytesBack = await client.readBytes(urlBack);
      storageFront.putData(bytesFront);
      storageBack.putData(bytesBack);
    } catch (e) {
      print('error accoured in downloading and putting files $e');
    }
  }

  Future<void> deleteDocument2(int documentId) async {
    try {
      final col =
          await FirebaseFirestore.instance.collection(user!.email!).get();
      final doc = col.docs;
      final docreference = doc[documentId].reference;
      await docreference.delete();
      print('Document successfully deleted');
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  Future<void> reloadData() async {
    print("now");
    final SharedPreferences prefs = await _prefs;
    final int? counter = prefs.getInt('counter');
    print(counter);
    print(card_list.length);
    if (counter != null && card_list.isEmpty && module_card.isEmpty) {
      final query = await FirebaseFirestore.instance
          .collection(user!.email!)
          .orderBy('cardnum', descending: false)
          .get();
      final List<DocumentSnapshot> document = query.docs;
      doclen = document.length;
      if (doclen != 0) {
        print("new here");
        print(document.last['cardnum'] ?? 0);
      }
      _cardlen = doclen == 0 ? 0 : document.last['cardnum'];
      print("here counter");
      print(counter);
      for (int i = 0; i < doclen; i++) {
        var cardnum = document[i];
        print("here");
        print(cardnum);
        if (cardnum != null && cardnum['is_done'] == true) {
          setState(() {
            card_list.add(Card(
              key: ValueKey(cardnum['title']),
              color: COLOR_DARK_BLUE,
              child: Center(
                child: Text(
                  cardnum['title'],
                  style: const TextStyle(color: COLOR_WHITE),
                ),
              ),
            ));
            print(cardnum['title']);
            module_card.add(
                cardModule(card_num: cardnum["cardnum"], key: UniqueKey()));
            _isChecked.add(false);
          });
          print("module len");
          print(module_card.length);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    orderindex();
    reloadData();
  }

  Future<void> _incrementcount() async {
    final SharedPreferences prefs = await _prefs;
    final int counter = (prefs.getInt('counter') ?? 0) + 1;
    doclen++;
    print("increment");
    print(counter);
    setState(() {
      count = prefs.setInt('counter', counter).then((bool success) {
        return counter;
      });
    });
  }

  Future<void> _decreasecount() async {
    final SharedPreferences prefs = await _prefs;
    int counter = (prefs.getInt('counter') ?? 0) - 1;
    doclen--;
    if (counter < 0) {
      counter = 0;
    }
    print('decrease');
    print(counter);
    setState(() {
      count = prefs.setInt('counter', counter).then((bool success) {
        return counter;
      });
    });
  }

  Future<void> _deleteMessage(BuildContext context, int index) async {
    // ignore: use_build_context_synchronously
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete card?"),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[Text('Delete the card?')],
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('cancel')),
              TextButton(
                  onPressed: () async {
                    await _decreasecount();
                    try {
                      final images = FirebaseStorage.instance
                          .ref()
                          .child('images/${user!.email!.trim()}/$index');
                      final card = await FirebaseFirestore.instance
                          .collection(user!.email!.trim())
                          .get();
                      final card_num = card.docs.elementAt(index);
                      final card_ind = card_num['cardnum'] as int;
                      await deleteFolder(
                          'images/${user!.email!.trim()}/${card_ind}/card${card_ind}/');
                    } catch (e) {
                      print('error in deleting folder $e');
                    }

                    setState(() {
                      card_list.removeAt(index);
                      module_card.removeAt(index);
                      _isChecked.removeAt(index);
                      _ispageready.clear();
                      deleteDocument2(index);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Delete'))
            ],
          );
        });
  }

  Future<void> deleteFolder(String folderPath) async {
    final storage = FirebaseStorage.instance;
    final reference = storage.ref(folderPath);

    try {
      final items = await reference.listAll();

      for (final item in items.items) {
        await item.delete();
      }

      await reference.delete();
    } catch (e) {
      print('error deleting folder $e');
    }
  }

  Future<void> _editCard(BuildContext context, int ind) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Edit card?"),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text("Edit the card?"),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('cancel')),
              TextButton(
                  onPressed: () {
                    module_card[ind] = cardModule(
                      card_num: module_card[ind].card_num,
                      key: module_card[ind].key!,
                      is_done: false,
                      front_description: module_card[ind].front_description,
                      back_description: module_card[ind].back_description,
                      title: module_card[ind].title,
                      is_update: true,
                    );
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            settings: const RouteSettings(name: '/home2'),
                            builder: (BuildContext context) =>
                                module_card[ind])).then((value) {
                      if (value != null) {
                        setState(() {
                          card_list[ind] = Card(
                            color: COLOR_DARK_BLUE,
                            key: UniqueKey(),
                            child: Center(
                                child: Text(
                              value,
                              style: const TextStyle(color: COLOR_WHITE),
                            )),
                          );
                        });
                      }
                    });
                  },
                  child: const Text("Edit"))
            ],
          );
        });
  }

  Future<void> _fetchNetworkImageUrl(int index) async {
    try {
      final storage = FirebaseStorage.instance.ref();
      final images = storage.child('images/${user!.email!.trim()}/$index');
      final dashImageRefFront = images.child('card$index/front');
      final dashImageRefBack = images.child('card$index/back');
      final networkImageUrlFront = await dashImageRefFront.getDownloadURL();
      final networkImageUrlBack = await dashImageRefBack.getDownloadURL();
      setState(() {
        imageNetUrlFront = networkImageUrlFront;
        imageNetUrlBack = networkImageUrlBack;
      });
    } catch (e) {
      print('error in fetching storage $e');
      imageNetUrlBack = '';
      imageNetUrlFront = '';
    }
  }

  Widget _sendButton(double? height, double? width, BuildContext context) {
    return ElevatedButton.icon(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Send card?'),
                  content: Container(
                    height: height! * 0.3,
                    child: Column(
                      children: [
                        const Text(
                            'Please enter the email of the user you want to send the card to.'),
                        SizedBox(
                          height: height * 0.02,
                        ),
                        TextFormField(
                          controller: _sendtoEmailController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.text_fields),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 3,
                                color: COLOR_BlACK,
                                style: BorderStyle.solid,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height * 0.1,
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                                onPressed: () async {
                                  await _sendCard(_indexList);
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.send),
                                label: const Text('Send Card')),
                            SizedBox(
                              width: width! * 0.03,
                            ),
                            ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.cancel),
                                label: const Text('Cancel'))
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
        icon: const Icon(Icons.send),
        label: const Text('Send Card'));
  }

  Future<void> copyFireData(int indsource, int indDest) async {
    print('this is it:');
    print(indDest);
    print(indsource);
    cardPage map1;
    final snap = await FirebaseFirestore.instance
        .collection(user!.email!)
        .doc('card$indsource')
        .get()
        .then((value) => value);
    map1 = cardPage.fromFireStore(snap);
    final card = cardPage(
        title: map1.title,
        frontText: map1.frontText,
        frontImagepath: map1.frontImagepath,
        backText: map1.backImagepath,
        backImagepath: map1.backImagepath,
        is_done: map1.is_done);
    print('to to');
    print(map1.title);
    final json = card.toFireStore();
    await FirebaseFirestore.instance
        .collection(user!.email!)
        .doc('card$indDest')
        .set(json);
    deleteDocument(indsource);
  }

  Future<void> updateFire(int index) async {
    for (int i = index; i <= card_list.length; i++) {
      await copyFireData(i + 1, i);
    }
  }

  Future<void> _sendCard(List<int> list) async {
    final card = await FirebaseFirestore.instance
        .collection(user!.email!)
        .orderBy('cardnum')
        .get();
    final card2 = await FirebaseFirestore.instance
        .collection(_sendtoEmailController.text.trim());
    List<Map<String, dynamic>> cardDataList = [];
    for (final index in list) {
      var cardNum = card.docs.elementAt(index);
      int num = cardNum['cardnum'];
      print('num');
      print(num);
      await _fetchNetworkImageUrl(num);
      print('fronturl');
      print(imageNetUrlFront);
      Reference images = FirebaseStorage.instance
          .ref()
          .child('images/${_sendtoEmailController.text.trim()}/$num');
      Reference dashImageRefFront = images.child('card$num/front');
      /*var fileFront = imageNetUrlFront != ''
          ? File.fromUri(Uri.parse(imageNetUrlFront))
          : null;
      Reference dashImageRefBack = images.child('card$num/back');
      File? fileBack = imageNetUrlBack != ''
          ? File.fromUri(Uri.parse(imageNetUrlBack))
          : null;
      
      if (fileFront != null && fileFront.existsSync()) {
        await dashImageRefFront.putFile(fileFront);
      }
      if (fileBack != null && fileBack.existsSync()) {
        await dashImageRefBack.putFile(fileBack);
      }*/
      var cardind = await card2.orderBy('cardnum', descending: false).get();
      int ind = cardind.docs.last['cardnum'];
      print(ind);
      _DownloadAndStorageImages(ind + 1);
      cardDataList.add(card.docs[index].data());
      final cardD = card.docs[index].data();

      createCard(
          cardD['frontText'] ?? "",
          cardD['backText'] ?? "",
          ind++ + 1,
          cardD['frontImagepath'] ?? "",
          cardD['backImagepath'] ?? "",
          cardD['is_done'] ?? "",
          cardD['title'] ?? "");
    }
  }

  Future createCard(String ques, String ans, int cardNum, String frontImagePath,
      String backImagePath, bool is_done, String title) async {
    final docCard = FirebaseFirestore.instance
        .collection(_sendtoEmailController.text.trim())
        .doc('card${cardNum}');

    final card = cardPage(
        title: title,
        frontText: ques,
        backText: ans,
        frontImagepath: frontImagePath,
        backImagepath: backImagePath,
        is_done: true,
        cardnum: cardNum);

    final json = card.toFireStore();

    await docCard.set(json);
  }

  Future<void> orderindex() async {
    await FirebaseFirestore.instance
        .collection(user!.email!)
        .orderBy('cardnum', descending: false)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final currentContext = context;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final allign = MediaQuery.of(context).orientation;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 172, 203, 241),
      appBar: AppBar(
        toolbarHeight: height * 0.09,
        title: const Text("home"),
        titleTextStyle: const TextStyle(color: COLOR_BlACK, fontSize: 22),
        iconTheme: const IconThemeData(color: COLOR_BlACK, size: 40),
        actions: [
          _sendButton(height, width, context),
        ],
      ),
      drawer: Mydrawer(),
      body: Column(
        children: [
          SizedBox(
            height: height * 0.01,
          ),
          Expanded(
            child: GridView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150,
                childAspectRatio: 3.5 / 5,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: const EdgeInsets.all(5),
                  child: card_list[index] == const SizedBox()
                      ? const SizedBox()
                      : Stack(
                          children: [
                            card_list[index],
                            InkWell(
                              onTap: () {
                                print("asddsd");
                                print(index);
                                print(module_card.length);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            module_card[index])).then((value) {
                                  if (value != null) {
                                    setState(() {
                                      card_list[index] = Card(
                                        color: COLOR_DARK_BLUE,
                                        key: UniqueKey(),
                                        child: Center(
                                            child: Text(
                                          value,
                                          style: const TextStyle(
                                              color: COLOR_WHITE),
                                        )),
                                      );
                                    });
                                  }
                                });
                              },
                            ),
                            Positioned(
                                top: height * 0.01,
                                right: width * 0.01,
                                child: Checkbox(
                                  value: _isChecked[index],
                                  onChanged: (bool? val) {
                                    setState(() {
                                      _isChecked[index] = val!;
                                    });
                                    if (_isChecked[index] == true) {
                                      _indexList.add(index);
                                    } else {
                                      _indexList.removeWhere(
                                          (element) => element == index);
                                    }
                                    print(_indexList.length);
                                  },
                                )),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    margin: EdgeInsets.all(6),
                                    alignment: Alignment.bottomLeft,
                                    child: ElevatedButton(
                                      child: const Icon(
                                        Icons.delete,
                                        color: COLOR_RED,
                                      ),
                                      onPressed: () async {
                                        await _deleteMessage(context, index);
                                      },
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    margin: const EdgeInsets.all(6),
                                    alignment: Alignment.bottomRight,
                                    child: ElevatedButton(
                                        child: const Icon(Icons.edit),
                                        onPressed: () {
                                          _editCard(context, index);
                                        }),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                );
              },
              itemCount: card_list.length,
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                final SharedPreferences pref = await _prefs;
                await _incrementcount();
                setState(() {
                  card_list.add(Card(
                    key: UniqueKey(),
                    color: COLOR_DARK_BLUE,
                    child: InkWell(
                      onTap: () {
                        count1++;
                      },
                    ),
                  ));
                  _ispageready.add(false);
                  _isChecked.add(false);
                  print("len");
                  print(_isChecked.length);
                  module_card.add(cardModule(
                    card_num: _cardlen++ + 1,
                    key: UniqueKey(),
                  ));
                  _cardind.add(_cardlen);
                  pref.setInt("cardlen", _cardlen);
                  print("cards");
                  print(module_card.length);
                  print("onee");
                  print(card_list.length);
                });
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(COLOR_WHITE)),
              child: Column(
                children: const [
                  Text(
                    "Add new card",
                    style: TextStyle(color: COLOR_BlACK),
                  ),
                  Icon(
                    Icons.add,
                    color: COLOR_BlACK,
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
