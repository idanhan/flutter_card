import 'package:cards2_app/drawer1.dart';
import 'package:cards2_app/modules/cardsObject.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cards2_app/constants.dart';
import 'package:provider/provider.dart';
import './home2.dart';
import './modules/cardsM.dart';
import './modules/cardsObject.dart';
import 'cardmodule.dart';
import './newCard.dart';

class HomePage extends StatefulWidget {
  bool is_updated = false;
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> _listCards = [];
  List<HomeScreen2> _listFolders = [];
  final _foldersNamed = TextEditingController();
  String name = '';
  final user = FirebaseAuth.instance.currentUser;
  int _folderCardLen = 0;
  List<int> _folderIndex = [];
  CardList cardlist = CardList();
  cardModulePro cardModPro = cardModulePro();

  Future<void> _fetchData() async {
    if (cardlist.isEmpty() &&
        cardModPro.isEmpty() &&
        widget.is_updated == false) {
      try {
        final current = await FirebaseFirestore.instance
            .collection(user!.email!)
            .orderBy('foldernum')
            .get();
        final folderlen = current.docs.last['foldernum'];
        _folderCardLen = folderlen;
        for (int i = 0; i <= folderlen; i++) {
          final ind =
              current.docs.indexWhere((element) => element['foldernum'] == i);
          if (ind != -1) {
            final title = current.docs.firstWhere(
                (element) => element['foldernum'] == i)['folderTitle'];
            setState(() {
              _listCards.add(Card(
                color: COLOR_BlACK,
                child: Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: COLOR_WHITE,
                    ),
                  ),
                ),
              ));
            });
            print('first i $i');
            _folderIndex.add(i);
          }
        }
        widget.is_updated = true;
      } catch (e) {
        print('getting data didnt work because $e');
      }
    }
  }

  Future<void> reloadData(CardList card, cardModulePro modulePro) async {
    if (card.isEmpty() && modulePro.isEmpty() && widget.is_updated == false) {
      final query = await FirebaseFirestore.instance
          .collection(user!.email!)
          .orderBy('foldernum')
          .orderBy('cardnum')
          .get();
      final List<DocumentSnapshot> document = query.docs;
      final doclen = document.length;
      print("doclen1 ${doclen}");
      for (int i = 0; i < doclen; i++) {
        var cardnum = document[i];
        if (cardnum['is_done'] == true) {
          card.addCard(NewCard(
            cardnum: cardnum['cardnum'],
            foldernum: cardnum['foldernum'],
            cardName: cardnum['title'],
          ));
          modulePro.add(cardModule(
              card_num: cardnum['cardnum'],
              folderNum: cardnum['foldernum'],
              folderTitle: cardnum['folderTitle'],
              is_done: true,
              key: UniqueKey()));
        }
      }
      widget.is_updated = true;
    }
  }

  Future<void> deleteFolderImage(String folderPath) async {
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

  Future<void> _deleteFolder(BuildContext context, int foldernum, int index,
      CardList card, cardModulePro modulePro) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Delete Folder?"),
            content: SingleChildScrollView(
              child: ListBody(
                children: const [Text("Do you like to delete the folder?")],
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () async {
                    try {
                      final firedata = await FirebaseFirestore.instance
                          .collection(user!.email!)
                          .orderBy("foldernum")
                          .orderBy("cardnum")
                          .get();
                      final firstcardnum = firedata.docs.indexWhere(
                          (element) => (element['foldernum'] == foldernum));
                      final lastcardnum = firedata.docs.lastIndexWhere(
                          (element) => (element['foldernum'] == foldernum));
                      for (int i = firstcardnum; i <= lastcardnum; i++) {
                        if (firedata.docs[i]['cardnum'] != -1) {
                          deleteFolderImage(
                              'images/${user!.email!.trim()}/foldernum$foldernum/${firedata.docs[i]['cardnum']}/card${firedata.docs[i]['cardnum']}');
                        }
                      }
                    } catch (e) {
                      print('deleting folder images failed $e');
                    }
                    try {
                      final firedata = await FirebaseFirestore.instance
                          .collection(user!.email!)
                          .orderBy("foldernum")
                          .orderBy("cardnum")
                          .get();
                      final firstcardnum = modulePro.cardModulepro.indexWhere(
                          (element) => (element.folderNum == foldernum));
                      final lastcardnum = modulePro.cardModulepro
                          .lastIndexWhere(
                              (element) => (element.folderNum == foldernum));
                      for (int i = firstcardnum; i <= lastcardnum; i++) {
                        card.cardList.removeAt(firstcardnum);
                        modulePro.cardModulepro.removeAt(firstcardnum);
                        firedata.docs[i].reference.delete();
                      }
                      _folderIndex
                          .removeWhere((element) => element == foldernum);
                      final lastall = firedata.docs.length;
                    } catch (e) {
                      print('delete folder $e');
                    }
                    setState(() {
                      _listCards.removeAt(index);
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text("Delete"))
            ],
          );
        });
  }

  Future<void> updateCardname(BuildContext context, int index) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Text("Change folder's name?"),
            actions: [
              Column(
                children: [
                  TextField(
                    enabled: true,
                    controller: _foldersNamed,
                    decoration: const InputDecoration(
                      hintText: 'Folder Name',
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                          onPressed: () async {
                            final userIns = await FirebaseFirestore.instance
                                .collection(user!.email!.trim())
                                .get();
                            final firstind = userIns.docs.indexWhere(
                                (element) =>
                                    element['foldernum'] ==
                                    _folderIndex[index]);
                            final lastind = userIns.docs.lastIndexWhere(
                                (element) =>
                                    element['foldernum'] ==
                                    _folderIndex[index]);
                            for (int i = firstind; i <= lastind; i++) {
                              userIns.docs[i].reference.update(
                                  {'folderTitle': _foldersNamed.text.trim()});
                            }
                            setState(() {
                              name = _foldersNamed.text.trim();
                              if (_foldersNamed.text.isNotEmpty) {
                                _listCards[index] = Card(
                                  color: COLOR_BlACK,
                                  child: Center(
                                    child: Text(
                                      name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: COLOR_WHITE,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            });
                            final card = await FirebaseFirestore.instance
                                .collection(user!.email!.trim())
                                .get();
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.edit),
                          label: Text('submit')),
                      ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.cancel),
                          label: Text('cancel')),
                    ],
                  ),
                ],
              ),
            ],
          );
        });
  }

  @override
  initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    print("cardModPro len 1 ${cardModPro.cardLen()}");
    return Scaffold(
        drawer: Mydrawer(),
        backgroundColor: Color.fromARGB(255, 172, 203, 241),
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: height * 0.09,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20)),
          ),
          title: const Text(
            "HomePage",
            textAlign: TextAlign.center,
          ),
          titleTextStyle: const TextStyle(color: COLOR_BlACK, fontSize: 22),
          iconTheme: const IconThemeData(color: COLOR_BlACK, size: 40),
        ),
        body: Consumer2<cardModulePro, CardList>(builder: (BuildContext context,
            cardModulePro modulevalue, CardList cardvalue, Widget? child) {
          reloadData(cardvalue, modulevalue);
          return Column(
            children: [
              SizedBox(
                height: height * 0.01,
              ),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    childAspectRatio: 3.5 / 5,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: height * 0.2,
                      width: width * 0.3,
                      margin: const EdgeInsets.all(5),
                      child: Stack(
                        children: [
                          _listCards.isEmpty
                              ? const SizedBox()
                              : _listCards[index],
                          InkWell(
                            onTap: () {
                              print("folder index $index");
                              if (name == '') {
                                final temp = modulevalue.cardModulepro.where(
                                    (element) =>
                                        element.folderNum ==
                                        _folderIndex[index]);
                                name = temp.first.folderTitle ??
                                    temp.first.folderTitle!;
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      settings: const RouteSettings(
                                          name: '/HomePage'),
                                      builder: (context) => HomeScreen2(
                                            foldernum: _folderIndex[index],
                                            homeTitle: name,
                                          )));
                            },
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                flex: 1,
                                child: Container(
                                  margin: const EdgeInsets.all(6),
                                  alignment: Alignment.bottomRight,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        _deleteFolder(
                                            context,
                                            _folderIndex[index],
                                            index,
                                            cardvalue,
                                            modulevalue);
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        color: COLOR_RED,
                                      )),
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: Container(
                                  margin: const EdgeInsets.all(6),
                                  alignment: Alignment.bottomRight,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        updateCardname(context, index);
                                      },
                                      child: const Icon(
                                        Icons.edit,
                                      )),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: _listCards.length,
                ),
              ),
              Container(
                margin: EdgeInsets.all(height * 0.01),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Create Folder?'),
                        content: const Text('enter file name'),
                        actions: <Widget>[
                          TextField(
                            enabled: true,
                            controller: _foldersNamed,
                            decoration: const InputDecoration(
                              hintText: 'Folder Name',
                            ),
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                  onPressed: () {
                                    name = _foldersNamed.text.trim();
                                    setState(() {
                                      _listCards.add(Container(
                                        child: Card(
                                          color: COLOR_BlACK,
                                          child: Center(
                                            child: Text(
                                              name,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: COLOR_WHITE,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ));
                                    });
                                    if (_folderIndex.isNotEmpty) {
                                      print(
                                          'last fol ${_folderIndex.last + 1}');
                                      _folderIndex.add(_folderIndex.last + 1);
                                    } else {
                                      _folderIndex.add(0);
                                    }
                                    _listFolders.add(HomeScreen2(
                                        foldernum: _folderCardLen++));
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(Icons.check),
                                  label: Text('create')),
                              ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: Icon(Icons.close),
                                  label: Text('cancel'))
                            ],
                          )
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.create_new_folder),
                  label: const Text('create new folder'),
                ),
              ),
            ],
          );
        }));
  }
}
