import 'package:cards2_app/drawer1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cards2_app/constants.dart';
import './home2.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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

  Future<void> _fetchData() async {
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
        final title = current.docs
            .firstWhere((element) => element['foldernum'] == i)['folderTitle'];
        if (ind != -1) {
          setState(() {
            _listCards.add(Container(
              child: Card(
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
              ),
            ));
          });
        }
      }
    } catch (e) {
      print('getting data didnt work because $e');
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

  Future<void> _deleteFolder(BuildContext context, int foldernum) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text("Delete Folder?"),
            content: SingleChildScrollView(
              child: ListBody(
                children: [Text("Do you like to delete the folder?")],
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
                      firedata.docs.firstWhere((element) => false);
                    } catch (e) {}
                  },
                  child: const Text("Delete"))
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
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: Mydrawer(),
      backgroundColor: Color.fromARGB(255, 172, 203, 241),
      appBar: AppBar(
        toolbarHeight: height * 0.09,
        title: const Text(
          "home",
          textAlign: TextAlign.center,
        ),
        titleTextStyle: const TextStyle(color: COLOR_BlACK, fontSize: 22),
        iconTheme: const IconThemeData(color: COLOR_BlACK, size: 40),
      ),
      body: Column(
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
                      _listCards.isEmpty ? const SizedBox() : _listCards[index],
                      InkWell(
                        onTap: () {
                          print("folder index $index");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  settings:
                                      const RouteSettings(name: '/HomePage'),
                                  builder: (context) => HomeScreen2(
                                        foldernum: index,
                                        homeTitle: name,
                                      )));
                        },
                      ),
                      Positioned(
                        bottom: 0.01 * height,
                        left: 0.07 * width,
                        child: ElevatedButton(
                            onPressed: () {},
                            child: const Icon(
                              Icons.delete,
                              color: COLOR_RED,
                            )),
                      )
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
                    title: Text('Create Folder?'),
                    content: Text('enter file name'),
                    actions: <Widget>[
                      TextField(
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
                                      child: Column(
                                        children: [
                                          Center(
                                            child: Text(
                                              name,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: COLOR_WHITE,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ));
                                });
                                _listFolders.add(
                                    HomeScreen2(foldernum: _folderCardLen++));
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
      ),
    );
  }
}
