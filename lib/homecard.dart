import 'package:cards2_app/boxWidg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cards2_app/cardmodule.dart';
import 'package:cards2_app/cards/card1.dart';
import 'package:cards2_app/constants.dart';
import 'package:flutter/material.dart';
import './col.dart';
import './drawer1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './cardobject.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Widget> card_list = [];
  List<cardModule> module_card = [];
  List<bool> _ispageready = [];
  List<int> _indexList = [];
  int _cardlen = 1;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<int> count;
  int _selectedindex = 0;
  final user = FirebaseAuth.instance.currentUser;
  void _onitemtap(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

  int count1 = 1;

  Future<Map<String, dynamic>?> readTitle(int index) async {
    Map<String, dynamic>? titleMap;
    try {
      final docSnap = await FirebaseFirestore.instance
          .collection('cards2')
          .doc('card$index')
          .get();

      if (docSnap.exists) {
        titleMap = {
          'title': docSnap.data()?['title'],
          'is_done': docSnap.data()?['is_done'],
          'card_num': docSnap.data()?['cardnum'],
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
          .collection('cards2')
          .doc('card$documentId')
          .delete();
      print('Document successfully deleted');
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  Future<void> reloadData() async {
    print("now");
    final SharedPreferences prefs = await _prefs;
    final int? counter = prefs.getInt('counter');
    _cardlen = (counter ?? 1);
    print(counter);
    print(card_list.length);
    if (counter != null && card_list.isEmpty && module_card.isEmpty) {
      for (int i = 0; i < counter; i++) {
        var cardnum = await readTitle(i + 1);
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
            module_card.add(cardModule(
              card_num: cardnum["card_num"],
              key: UniqueKey(),
              is_done: true,
            ));
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    reloadData();
  }

  Future<void> _incrementcount() async {
    final SharedPreferences prefs = await _prefs;
    final int counter = (prefs.getInt('counter') ?? 0) + 1;
    _cardlen = counter;
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
    int counter = (prefs.getInt('counter') ?? 0) - 2;
    if (counter < 0) {
      counter = 0;
    }
    print('decrease');
    print(counter);
    _cardlen = counter;
    setState(() {
      count = prefs.setInt('counter', counter).then((bool success) {
        return counter;
      });
    });
  }

  Future<void> _deleteMessage(BuildContext context, int index) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
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
                    setState(() {
                      card_list.removeAt(index);
                      module_card.removeAt(index);
                      _ispageready.clear();
                      _indexList.clear();
                      deleteDocument(index + 1);
                      updateFire(index + 1);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Delete'))
            ],
          );
        });
  }

  Future<void> copyFireData(int indsource, int indDest) async {
    print('this is it:');
    print(indDest);
    print(indsource);
    cardPage map1;
    final snap = await FirebaseFirestore.instance
        .collection('cards2')
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
        .collection('cards2')
        .doc('card$indDest')
        .set(json);
    deleteDocument(indsource);
  }

  Future<void> updateFire(int index) async {
    for (int i = index; i <= card_list.length; i++) {
      await copyFireData(i + 1, i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final allign = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(
        title: const Text("home"),
        backgroundColor: COLOR_WHITE,
        titleTextStyle: const TextStyle(color: COLOR_BlACK, fontSize: 22),
        iconTheme: const IconThemeData(color: COLOR_BlACK, size: 40),
        leading: ElevatedButton.icon(
          style:
              ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          onPressed: () => FirebaseAuth.instance.signOut(),
          label: const Text(
            'Sign out',
            style: TextStyle(fontSize: 24),
          ),
          icon: const Icon(
            Icons.arrow_back,
            size: 32,
          ),
        ),
      ),
      drawer: Mydrawer(),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150,
                childAspectRatio: 3 / 4,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 20,
                  width: 20,
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
                                          style: TextStyle(color: COLOR_WHITE),
                                        )),
                                      );
                                    });
                                  }
                                });
                              },
                            ),
                            Container(
                              alignment: Alignment.bottomCenter,
                              child: ElevatedButton(
                                child: const Icon(Icons.delete),
                                onPressed: () async {
                                  await _deleteMessage(context, index);
                                },
                              ),
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
                  module_card.add(cardModule(
                    card_num: _cardlen,
                    key: UniqueKey(),
                  ));
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
                    "Add new project",
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
