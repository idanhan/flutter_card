import 'package:cards2_app/cardmodule.dart';
import 'package:cards2_app/constants.dart';
import 'package:cards2_app/finishedcard.dart';
import 'package:cards2_app/modules/cardsObject.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './col.dart';
import './drawer1.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './cardobject.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import './drawer2.dart';
import './modules/cardsM.dart';
import './modules/cardsObject.dart';
import './newCard.dart';

class HomeScreen2 extends StatefulWidget {
  int foldernum;
  String? homeTitle;
  HomeScreen2({super.key, required this.foldernum, this.homeTitle});

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

  int finalfoldnum = -1;
  bool isintializedone = false;

  bool is_remove = false;
  CardList? cardlist;
  cardModulePro? cardModPro;

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
          .doc('folder${widget.foldernum}/card$documentId')
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
          'images/${_sendtoEmailController.text.trim()}/folderreceived/$index/card$index/front');
      final bytesFront = await client.readBytes(urlFront);
      storageFront.putData(bytesFront);
    } catch (e) {
      print('error accoured in downloading and putting files front $e');
    }
    try {
      final storageBack = FirebaseStorage.instance.ref().child(
          'images/${_sendtoEmailController.text.trim()}/folderreceived/$index/card$index/back');
      final bytesBack = await client.readBytes(urlBack);
      storageBack.putData(bytesBack);
    } catch (e) {
      print('error accoured in downloading and putting files back $e');
    }
  }

  Future<void> deleteDocument2(int documentId) async {
    try {
      final col =
          await FirebaseFirestore.instance.collection(user!.email!).get();
      final doc =
          col.docs.where((element) => element['foldernum'] == widget.foldernum);
      final docreference = doc.toList()[documentId].reference;
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
    final query = await FirebaseFirestore.instance
        .collection(user!.email!)
        .orderBy('foldernum')
        .orderBy('cardnum')
        .get();
    final List<DocumentSnapshot> document = query.docs;
    doclen = document.length;
    if (doclen != 0) {
      print("new here");
      print(document.last['cardnum'] ?? 0);
    }
    try {
      final lastFolderindex = document.lastIndexWhere(
          (element) => element['foldernum'] == widget.foldernum);
      final firstFolder = document
          .firstWhere((element) => element['foldernum'] == widget.foldernum);
      final firstFolderIndex = document.indexWhere((element) =>
          (element['foldernum'] == firstFolder['foldernum'] &&
              element['cardnum'] == firstFolder['cardnum']));
      _cardlen =
          lastFolderindex == -1 ? 0 : lastFolderindex - firstFolderIndex + 1;
      print("here counter");
      print(lastFolderindex);
      int checkint = 0;
      for (int i = firstFolderIndex; i <= lastFolderindex; i++) {
        var cardnum = document[i];
        print("here last and first $lastFolderindex $firstFolderIndex");
        print(cardnum);
        if (cardnum != null && cardnum['is_done'] == true) {
          checkint++;
          setState(() {
            cardlist!.addCard(NewCard(
              cardnum: cardnum['cardnum'],
              foldernum: cardnum['foldernum'],
              cardName: cardnum['title'],
              key: UniqueKey(),
            ));
            print(cardnum['title']);
            cardModPro!.add(cardModule(
                card_num: cardnum['cardnum'],
                folderNum: cardnum['foldernum'],
                folderTitle: cardnum['folderTitle'],
                is_done: true,
                key: UniqueKey()));
            print("is_checked ${_isChecked.length}");
          });
          print("module len ${cardModPro!.cardLen()}");
        }
      }
    } catch (e) {
      print('exception occured in reload $e');
    }
  }

  Future<void> reloadData2() async {
    print('widget num ${widget.foldernum}');
    final query = await FirebaseFirestore.instance
        .collection(user!.email!)
        .orderBy('foldernum')
        .orderBy('cardnum')
        .get();
    final List<DocumentSnapshot> document = query.docs;
    doclen = document.length;
    final lastCardind = document
        .lastIndexWhere((element) => element['foldernum'] == widget.foldernum);
    print('lastindd $lastCardind');
    final firstCardind = document
        .indexWhere((element) => element['foldernum'] == widget.foldernum);
    print('firstinddd $firstCardind');
    final finalfolder = document
        .lastIndexWhere((element) => element['foldernum'] == widget.foldernum);
    _cardlen = lastCardind == -1 ? 0 : document[lastCardind]['cardnum'];
  }

  void intialize(CardList card, cardModulePro modulePro) {
    int first = modulePro.cardModulepro
        .indexWhere((element) => element.folderNum == widget.foldernum);
    int last = modulePro.cardModulepro
        .lastIndexWhere((element) => element.folderNum == widget.foldernum);
    print('answer? first ${first}');
    print('answer? last $last');
    if (card.cardList.isNotEmpty &&
        card_list.isEmpty &&
        first != -1 &&
        last != -1) {
      print('first inddd ${first}');
      print('last inddd ${last}');
      print('finalfold ${finalfoldnum}');
      _cardlen = modulePro.cardModulepro[last].card_num;

      for (int i = first; i <= last; i++) {
        _isChecked.add(false);
        card_list.add(Card(
          color: COLOR_DARK_BLUE,
          child: Center(
            child: card.cardList[i].cardName != null
                ? Text(
                    card.cardList[i].cardName!,
                    style: TextStyle(color: COLOR_WHITE),
                  )
                : const SizedBox(),
          ),
        ));
        module_card.add(modulePro.cardModulepro[i]);
        print('i $i');
      }
    } else if (first == -1) {
      first = 0;
    }
    isintializedone = true;
  }

  @override
  void initState() {
    super.initState();
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

  Future<void> _deleteMessage(BuildContext context, int index, CardList card,
      cardModulePro modulePro, int first, int last) async {
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
                      final card = await FirebaseFirestore.instance
                          .collection(user!.email!.trim())
                          .get();
                      final card_num = card.docs.elementAt(index + first);
                      final card_ind = card_num['cardnum'] as int;
                      print('cardnum in fol ${card_ind} ind ${index}');
                      await deleteFolder(
                          'images/${user!.email!.trim()}/foldernum${widget.foldernum}/${card_ind}/card${card_ind}/');
                    } catch (e) {
                      print('error in deleting folder $e');
                    }
                    is_remove = true;
                    await deleteDocument2(index);
                    card_list.removeAt(index);
                    card.removeCardAtIndex(index + first);
                    module_card.removeAt(index);
                    modulePro.remove(index + first);
                    _isChecked.removeAt(index);
                    _ispageready.clear();
                    if (card_list.isEmpty) {
                      reloadData2();
                    } else {
                      reloadData2();
                      intialize(card, modulePro);
                    }
                    is_remove = false;
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

  Future<void> _editCard(BuildContext context, int ind, CardList cardList,
      cardModulePro cardModPro, int first, int last) {
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
                  onPressed: () async {
                    module_card[ind] = cardModule(
                      folderNum: widget.foldernum,
                      card_num: module_card[ind].card_num,
                      key: module_card[ind].key!,
                      is_done: false,
                      front_description: module_card[ind].front_description,
                      back_description: module_card[ind].back_description,
                      title: module_card[ind].title,
                      is_update: true,
                      folderTitle: module_card[ind].folderTitle,
                    );
                    /*cardModPro.setvalAt(
                        ind + first,
                        cardModule(
                          folderNum: widget.foldernum,
                          card_num:
                              cardModPro.cardModulepro[ind + first].card_num,
                          key: cardModPro.cardModulepro[ind + first].key!,
                          is_done: false,
                          front_description: cardModPro
                              .cardModulepro[ind + first].front_description,
                          back_description: cardModPro
                              .cardModulepro[ind + first].back_description,
                          title: cardModPro.cardModulepro[ind + first].title,
                          is_update: true,
                          folderTitle:
                              cardModPro.cardModulepro[ind + first].folderTitle,
                        ));*/
                    Navigator.of(context).pop();
                    Map<String, dynamic> map = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            settings: const RouteSettings(name: '/home2'),
                            builder: (BuildContext context) =>
                                module_card[ind]));

                    if (map['title'] != null && map['title'] != '') {
                      setState(() {
                        card_list[ind] = Card(
                          color: COLOR_DARK_BLUE,
                          key: UniqueKey(),
                          child: Center(
                              child: Text(
                            map['title'],
                            style: const TextStyle(color: COLOR_WHITE),
                          )),
                        );
                        cardList.setCardValAt(
                            ind + first,
                            NewCard(
                              cardnum: ind + first,
                              foldernum: widget.foldernum,
                              cardName: map['title'],
                              key: UniqueKey(),
                            ));
                      });
                    }
                    if (map['done'] != null && map['done'] == true) {
                      cardModPro.cardModulepro[ind + first].is_done = true;
                      ;
                      module_card[ind].is_done = true;
                    }
                    /*then((value) {
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
                          cardList.setCardValAt(
                              ind + first,
                              NewCard(
                                cardnum: ind + first,
                                foldernum: widget.foldernum,
                                cardName: value,
                                key: UniqueKey(),
                              ));
                        });
                      }
                      /*if (value['is_done'] != null &&
                          value['is_done'] == true) {
                        cardModPro.changedone(ind + first);
                        module_card[ind].is_done = true;
                      }*/
                    });*/
                  },
                  child: const Text("Edit"))
            ],
          );
        });
  }

  Future<void> _fetchNetworkImageUrl(int index) async {
    try {
      final storage = FirebaseStorage.instance.ref();
      final images = storage.child(
          'images/${user!.email!.trim()}/foldernum${widget.foldernum}/$index');
      final dashImageRefFront = images.child('card$index/front');

      final networkImageUrlFront = await dashImageRefFront.getDownloadURL();
      setState(() {
        imageNetUrlFront = networkImageUrlFront;
      });
    } catch (e) {
      print('error in front image storage $e');
    }
    try {
      final storage = FirebaseStorage.instance.ref();
      final images = storage.child(
          'images/${user!.email!.trim()}/foldernum${widget.foldernum}/$index');
      final dashImageRefBack = images.child('card$index/back');
      final networkImageUrlBack = await dashImageRefBack.getDownloadURL();
      setState(() {
        imageNetUrlBack = networkImageUrlBack;
      });
    } catch (e) {
      print('error in back image storage $e');
    }
    try {
      final storage = FirebaseStorage.instance.ref();
      final images =
          storage.child('images/${user!.email!.trim()}/folderreceived/$index');
      final dashImageRefFront = images.child('card$index/front');

      final networkImageUrlFront = await dashImageRefFront.getDownloadURL();

      setState(() {
        imageNetUrlFront = networkImageUrlFront;
      });
    } catch (e) {
      print('error in sent card front storage $e');
    }
    try {
      final storage = FirebaseStorage.instance.ref();
      final images =
          storage.child('images/${user!.email!.trim()}/folderreceived/$index');
      final dashImageRefBack = images.child('card$index/back');
      final networkImageUrlBack = await dashImageRefBack.getDownloadURL();
      setState(() {
        imageNetUrlBack = networkImageUrlBack;
      });
    } catch (e) {
      print('error in sent card back storage $e');
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
                          enabled: true,
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
        .doc('foldernum${widget.foldernum}/card$indsource')
        .get()
        .then((value) => value);
    map1 = cardPage.fromFireStore(snap);
    final card = cardPage(
        title: map1.title,
        frontText: map1.frontText,
        frontImagepath: map1.frontImagepath,
        backText: map1.backImagepath,
        backImagepath: map1.backImagepath,
        is_done: map1.is_done,
        foldernum: widget.foldernum);
    print('to to');
    print(map1.title);
    final json = card.toFireStore();
    await FirebaseFirestore.instance
        .collection(user!.email!)
        .doc('foldernum${widget.foldernum}/card$indDest')
        .set(json);
    deleteDocument(indsource);
  }

  Future<void> updateFire(int index) async {
    for (int i = index; i <= card_list.length; i++) {
      await copyFireData(i + 1, i);
    }
  }

  Future<void> _sendCard(List<int> list) async {
    int sentIndexFolderNum = 0;
    int folderTitleNUm = -1;
    int sentCardFolder = -1;
    int lastFolderNum = -1;
    int lastCardnum = -1;
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> tempT;
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> sent1;
    final card = await FirebaseFirestore.instance
        .collection(user!.email!)
        .orderBy('foldernum')
        .orderBy('cardnum')
        .get();
    final card2 = FirebaseFirestore.instance
        .collection(_sendtoEmailController.text.trim());
    List<Map<String, dynamic>> cardDataList = [];
    final firstIndex = card.docs
        .indexWhere((element) => element['foldernum'] == widget.foldernum);
    final sent = await card2.orderBy('foldernum').orderBy('cardnum').get();
    if (sent.size != 0) {
      final tempT = sent.docs.where((element) =>
          element['folderTitle'].toString().compareTo('receivedCards') == 0);
      if (tempT.isNotEmpty) {
        sentCardFolder = tempT.first['foldernum'];
      }
      if (sentCardFolder != -1) {
        lastCardnum = sent.docs.lastWhere((element) =>
                element['folderTitle'].toString().compareTo('receivedCards') ==
                0)['cardnum'] +
            1;
      } else {
        lastCardnum = 0;
      }
      lastFolderNum = sent.docs.last['foldernum'];
      final s = sent.docs.last['cardnum'];
      sentIndexFolderNum =
          sent.docs.lastIndexWhere((element) => element['cardnum'] == s);
      sent1 = sent.docs.where((element) =>
          element['folderTitle'].toString().compareTo('receivedCards') == 0);
      if (sent1.isNotEmpty) {
        folderTitleNUm = sent1.last['cardnum'];
      }
    }
    for (final index in list) {
      var cardNum = card.docs.elementAt(index + firstIndex);
      int num = cardNum['cardnum'];
      print('num');
      print(num);
      await _fetchNetworkImageUrl(num);
      print('fronturl');
      print(imageNetUrlFront);
      Reference images = FirebaseStorage.instance.ref().child(
          'images/${_sendtoEmailController.text.trim()}/foldernum${widget.foldernum}/$num');
      Reference dashImageRefFront = images.child('card$num/front');
      var cardind = await card2
          .orderBy('foldernum')
          .orderBy('cardnum', descending: false)
          .get();
      int ind2 = sentCardFolder != -1 ? sentCardFolder : lastFolderNum + 1;
      int ind = lastCardnum;
      print('ind2');
      print(ind2);
      _DownloadAndStorageImages(lastCardnum);
      cardDataList.add(card.docs[index + firstIndex].data());
      final cardD = card.docs[index + firstIndex].data();
      if (lastCardnum == -1) {
        lastCardnum = 0;
      }
      createCard(
          cardD['frontText'] ?? "",
          cardD['backText'] ?? "",
          lastCardnum++,
          cardD['frontImagepath'] ?? "",
          cardD['backImagepath'] ?? "",
          cardD['is_done'] ?? "",
          cardD['title'] ?? "",
          sentCardFolder != -1 ? sentCardFolder : lastFolderNum + 1,
          'receivedCards');
    }
  }

  Future createCard(
      String ques,
      String ans,
      int cardNum,
      String frontImagePath,
      String backImagePath,
      bool is_done,
      String title,
      int foldernum,
      String folderTitle) async {
    final docCard = FirebaseFirestore.instance
        .collection(_sendtoEmailController.text.trim())
        .doc('receivedCards${cardNum}');

    final card = cardPage(
        title: title,
        frontText: ques,
        backText: ans,
        frontImagepath: frontImagePath,
        backImagepath: backImagePath,
        is_done: true,
        cardnum: cardNum,
        foldernum: foldernum,
        folderTitle: folderTitle);

    final json = card.toFireStore();

    await docCard.set(json);
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
        centerTitle: true,
        title: Text("Card"),
        titleTextStyle: const TextStyle(color: COLOR_BlACK, fontSize: 22),
        iconTheme: const IconThemeData(color: COLOR_BlACK, size: 40),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20)),
        ),
        actions: [
          _sendButton(height, width, context),
        ],
      ),
      drawer: Mydrawer2(),
      body: Consumer2<cardModulePro, CardList>(
        builder: (BuildContext context, cardModulePro modulevalue,
            CardList cardvalue, Widget? child) {
          intialize(cardvalue, modulevalue);
          final card = cardvalue.cardList;
          final module = modulevalue.cardModulepro;
          final firstind = modulevalue.cardModulepro
              .indexWhere((element) => element.folderNum == widget.foldernum);
          final lastind = modulevalue.cardModulepro.lastIndexWhere(
              (element) => element.folderNum == widget.foldernum);
          print('lastindd ${modulevalue.cardLen()} end');
          print('card at ind 0 ${cardvalue.cardLen()}');
          print('foldernum ${widget.foldernum}');
          return Column(
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
                                  onTap: () async {
                                    print("asddsd");
                                    print(index);
                                    print(module_card.length);
                                    Map<String, dynamic> map =
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        module_card[index]));
                                    if (map['title'] != null &&
                                        map['title'] != '') {
                                      setState(() {
                                        card_list[index] = Card(
                                          color: COLOR_DARK_BLUE,
                                          key: UniqueKey(),
                                          child: Center(
                                              child: Text(
                                            map['title'],
                                            style: const TextStyle(
                                                color: COLOR_WHITE),
                                          )),
                                        );
                                        cardvalue.setCardValAt(
                                            index + firstind,
                                            NewCard(
                                              cardnum: cardvalue
                                                  .cardList[index + firstind]
                                                  .cardnum,
                                              foldernum: cardvalue
                                                  .cardList[index + firstind]
                                                  .foldernum,
                                              cardName: map['title'],
                                            ));
                                      });
                                    }
                                    if (map['done'] != null &&
                                        map['done'] == true) {
                                      modulevalue
                                          .cardModulepro[index + firstind]
                                          .is_done = true;
                                      module_card[index].is_done = true;
                                    }
                                    /*then(
                                        (value) {
                                      if (value['title'] != null) {
                                        setState(() {
                                          card_list[index] = Card(
                                            color: COLOR_DARK_BLUE,
                                            key: UniqueKey(),
                                            child: Center(
                                                child: Text(
                                              value['title'],
                                              style: const TextStyle(
                                                  color: COLOR_WHITE),
                                            )),
                                          );
                                          cardvalue.setCardValAt(
                                              index + firstind,
                                              NewCard(
                                                cardnum: cardvalue
                                                    .cardList[index + firstind]
                                                    .cardnum,
                                                foldernum: cardvalue
                                                    .cardList[index + firstind]
                                                    .foldernum,
                                                cardName: value['title'],
                                              ));
                                        });
                                      }
                                      if (value['done'] != null &&
                                          value['done'] == true) {
                                        modulevalue
                                            .cardModulepro[index + firstind]
                                            .is_done = true;
                                        module_card[index].is_done = true;
                                      }
                                    });*/
                                  },
                                ),
                                Positioned(
                                    top: height * 0.01,
                                    right: width * 0.01,
                                    child: Checkbox(
                                      value: _isChecked.isEmpty
                                          ? false
                                          : _isChecked[index],
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
                                            await _deleteMessage(
                                                context,
                                                index,
                                                cardvalue,
                                                modulevalue,
                                                firstind,
                                                lastind);
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
                                              _editCard(
                                                  context,
                                                  index,
                                                  cardvalue,
                                                  modulevalue,
                                                  firstind,
                                                  lastind);
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
                            count1 + 1;
                          },
                        ),
                      ));
                      cardvalue.insertByFolderNCard(
                        NewCard(
                            cardnum: _cardlen + 1, foldernum: widget.foldernum),
                        widget.foldernum,
                      );
                      _ispageready.add(false);
                      _isChecked.add(false);
                      print("len");
                      print(card.length);
                      module_card.add(cardModule(
                        folderNum: widget.foldernum,
                        card_num: _cardlen + 1,
                        key: UniqueKey(),
                        folderTitle: widget.homeTitle,
                      ));
                      modulevalue.insertByFolderNCard(
                          cardModule(
                            folderNum: widget.foldernum,
                            card_num: _cardlen + 1,
                            key: UniqueKey(),
                            folderTitle: widget.homeTitle,
                          ),
                          widget.foldernum);
                      _cardlen++;
                      _cardind.add(_cardlen);
                      pref.setInt("cardlen", _cardlen);
                    });
                    print("cards");
                    print(module_card.length);
                    print("onee");
                    print(_cardlen);
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
          );
        },
      ),
    );
  }
}
