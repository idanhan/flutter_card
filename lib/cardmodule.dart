import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import './constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flip_card/flip_card.dart';
import './cardobject.dart';
import './homecard.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

import 'dart:io';

class cardModule extends StatefulWidget {
  PlatformFile? pickFile;
  bool? is_done;
  final front_description;
  final back_description;
  final title;
  int card_num;
  bool is_data_sent = false;
  bool? is_update = false;
  bool is_hebrew_title = false;
  bool is_once_title = false;
  bool is_hebrew_ques = false;
  bool is_once_ques = false;
  bool is_hebrew_ans = false;
  bool is_once_ans = false;
  int folderNum;
  String? folderTitle;

  cardModule(
      {this.is_done,
      this.front_description,
      this.back_description,
      this.title,
      required this.card_num,
      required this.folderNum,
      this.is_update,
      this.folderTitle,
      required Key key})
      : super(key: key);

  @override
  State<cardModule> createState() => cardModuleState();
}

class cardModuleState extends State<cardModule>
    with AutomaticKeepAliveClientMixin<cardModule> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? title;
  String? question;
  String? answer;
  File? _selectedImage;
  final controller1 = TextEditingController();
  final controller2 = TextEditingController();
  final controller3 = TextEditingController();
  String imageNetUrlFront = '';
  String imageNetUrlBack = '';
  bool _isready = false;
  String? imageStrAns;
  String? imageStrQue;
  bool? is_que;
  Map<String, Object> cardMap = {};
  final user = FirebaseAuth.instance.currentUser;
  final storage = FirebaseStorage.instance.ref();
  bool is_loading = false;

  Future<void> _showCircularProg(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        barrierDismissible: false);

    await createCard(datatitle: title!);

    Navigator.of(context).pop();
  }

  Future<File?> _cropImage({required XFile imageFile}) async {
    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return File(croppedImage.path);
  }

  Future<void> _selecteImage(bool? is_que) async {
    final picker = ImagePicker();
    final PickedFile = await picker.pickImage(source: ImageSource.gallery);
    File? image1 = File(PickedFile!.path);
    File? image2 = await _cropImage(imageFile: PickedFile);
    setState(() {
      if (is_que! && image2 != null) {
        imageStrQue = image2.path;
      } else {
        imageStrAns = image1.path;
      }
    });
  }

  Future createCard({required String datatitle}) async {
    final docCard = FirebaseFirestore.instance
        .collection(user!.email!)
        .doc('foldernum${widget.folderNum}card${widget.card_num}');

    final card = cardPage(
        title: datatitle,
        frontText: question,
        backText: answer,
        frontImagepath: imageStrQue,
        backImagepath: imageStrAns,
        is_done: true,
        cardnum: widget.card_num,
        foldernum: widget.folderNum,
        folderTitle: widget.folderTitle);
    final json = card.toFireStore();
    final images = storage.child(
        'images/${user!.email!.trim()}/foldernum${widget.folderNum}/${widget.card_num}');
    final dashImageRefFront = images.child('card${widget.card_num}/front');
    final fileFront = imageStrQue != null ? File(imageStrQue!) : null;
    final dashImageRefBack = images.child('card${widget.card_num}/back');
    final fileBack = imageStrAns != null ? File(imageStrAns!) : null;
    if (fileFront != null) {
      await dashImageRefFront.putFile(fileFront);
    }
    if (fileBack != null) {
      await dashImageRefBack.putFile(fileBack);
    }

    docCard.set(json);
    widget.is_data_sent = true;
  }

  Future<void> updateCard() async {
    DocumentReference docref = FirebaseFirestore.instance
        .collection(user!.email!)
        .doc('foldernum${widget.folderNum}card${widget.card_num}');
    dynamic cardval = await docref.get().then((value) => value);

    Map<String, dynamic> updatedata = {
      'is_done': true,
    };
    if (title != null && title != "") {
      updatedata.addAll({'title': title});
    } else {
      title = cardval['title'];
      print("cardval");
      print(title);
    }
    if (question != null && question != "") {
      updatedata.addAll({'frontText': question});
    }
    if (answer != null && answer != "") {
      updatedata.addAll({'backText': answer});
    }
    if (imageStrQue != null && imageStrQue != "") {
      updatedata.addAll({'frontImagepath': imageStrQue});
    }
    if (imageStrAns != null && imageStrAns != "") {
      updatedata.addAll({'backImagepath': imageStrAns});
    }

    try {
      await docref.update(updatedata);
      print("doc updated successfuly");
    } catch (error) {
      print("error updating doc: $error");
    }
  }

  Stream<List<cardPage>> readCard() => FirebaseFirestore.instance
      .collection(user!.email!)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((e) => cardPage.fromFireStore(e)).toList());

  Stream<cardPage> readcard() {
    return FirebaseFirestore.instance
        .collection(user!.email!)
        .doc('card${widget.card_num}')
        .snapshots()
        .map((event) => cardPage.fromFireStore(event));
  }

  Future<void> _fetchNetworkImageUrl() async {
    final storage = FirebaseStorage.instance.ref();
    try {
      final images = storage.child(
          'images/${user!.email!.trim()}/foldernum${widget.folderNum}/${widget.card_num}');
      final dashImageRefFront = images.child('card${widget.card_num}/front');
      final networkImageUrlFront = await dashImageRefFront.getDownloadURL();
      setState(() {
        imageNetUrlFront = networkImageUrlFront;
      });
    } catch (e) {
      print('error in fetching storage front $e');
    }
    try {
      final images = storage.child(
          'images/${user!.email!.trim()}/foldernum${widget.folderNum}/${widget.card_num}');
      final dashImageRefBack = images.child('card${widget.card_num}/back');
      final networkImageUrlBack = await dashImageRefBack.getDownloadURL();
      setState(() {
        imageNetUrlBack = networkImageUrlBack;
      });
    } catch (e) {
      print('error in fetching storage back $e');
    }
    try {
      final images = storage.child(
          'images/${user!.email!.trim()}/folderreceived/${widget.card_num}');
      final dashImageRefBack = images.child('card${widget.card_num}/back');
      final networkImageUrlBack = await dashImageRefBack.getDownloadURL();
      setState(() {
        imageNetUrlBack = networkImageUrlBack;
      });
    } catch (e) {
      print('error in fetching storage back received $e');
    }
    try {
      final images = storage.child(
          'images/${user!.email!.trim()}/folderreceived/${widget.card_num}');
      final dashImageRefFront = images.child('card${widget.card_num}/front');
      final networkImageUrlFront = await dashImageRefFront.getDownloadURL();
      setState(() {
        imageNetUrlFront = networkImageUrlFront;
      });
    } catch (e) {
      print('error in fetching storage front received $e');
    }
  }

  Stream<cardPage> readcard2() async* {
    final cards = await FirebaseFirestore.instance
        .collection(user!.email!)
        .orderBy('foldernum')
        .orderBy('cardnum')
        .get();
    print("widget");
    print(widget.card_num);
    final ind = cards.docs.indexWhere((element) =>
        (element["cardnum"] == widget.card_num &&
            element['foldernum'] == widget.folderNum));
    print("index");
    print(ind);
    print(widget.card_num);
    if (cards.docs[ind]["is_done"]) {
      widget.is_done = true;
    }
    final card = cards.docs[ind];
    yield cardPage.fromFireStore(card);
  }

  Widget buildCardFront(cardPage card, BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return InteractiveViewer(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: ListView(
          shrinkWrap: true,
          children: [
            card.title != null
                ? Container(
                    margin: EdgeInsets.all(height * 0.02),
                    child: Container(
                      alignment: Alignment.topCenter,
                      margin: EdgeInsets.only(
                          top: height * 0.02, bottom: height * 0.02),
                      child: Text(
                        "Question",
                        style: TextStyle(fontSize: height * 0.03),
                      ),
                    ),
                  )
                : const SizedBox(),
            card.frontText != null
                ? Container(
                    margin: EdgeInsets.only(
                        top: height * 0.02, bottom: height * 0.02),
                    width: width * 0.4,
                    child: Text(
                      card.frontText!,
                      style: TextStyle(fontSize: height * 0.03),
                      textAlign: _hebrew(widget.is_hebrew_ques),
                    ),
                  )
                : const SizedBox(),
            imageNetUrlFront != ''
                ? Container(
                    margin: EdgeInsets.all(height * 0.01),
                    height: height * 0.3,
                    width: width * 0.5,
                    child: CachedNetworkImage(
                      imageUrl: imageNetUrlFront,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget buildCardBack(cardPage card, BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return InteractiveViewer(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              margin: EdgeInsets.all(height * 0.02),
              child: Container(
                alignment: Alignment.center,
                margin:
                    EdgeInsets.only(top: height * 0.02, bottom: height * 0.02),
                child: Text(
                  "Answer",
                  style: TextStyle(fontSize: height * 0.03),
                ),
              ),
            ),
            card.backText != null
                ? Container(
                    margin: EdgeInsets.only(
                        top: height * 0.02, bottom: height * 0.02),
                    child: Text(
                      card.backText!,
                      style: TextStyle(fontSize: height * 0.03),
                      textAlign: _hebrew(widget.is_hebrew_ans),
                    ),
                  )
                : const SizedBox(),
            imageNetUrlBack != ''
                ? Container(
                    margin: EdgeInsets.all(height * 0.01),
                    height: height * 0.3,
                    width: width * 0.5,
                    child: CachedNetworkImage(
                      imageUrl: imageNetUrlBack,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  )
                : const SizedBox(),
            SizedBox(
              height: height * 0.3,
            ),
            Container(
              width: width * 0.01,
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  "Back",
                  style: TextStyle(fontSize: height * 0.03),
                ),
                SizedBox(
                  width: width * 0.03,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.home)),
              ]),
            )
          ],
        ),
      ),
    );
  }

  Future<void> fetchDataFirebase() async {
    final query =
        await FirebaseFirestore.instance.collection(user!.email!).get();
    final List<DocumentSnapshot> document = query.docs;
    final docind = document.where((element) =>
        (int.parse(element["cardnum"].toString()) == widget.card_num) &&
        element['foldernum'] == widget.folderNum);
    if (docind.isNotEmpty && widget.is_update != true) {
      setState(() {
        widget.is_done = true;
      });
    } else {
      setState(() {
        widget.is_done = false;
      });
    }
  }

  TextAlign _hebrew(bool is_he) {
    print("hebrew here");
    print(is_he);
    return is_he ? TextAlign.right : TextAlign.left;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement didChangeDependencies
    super.initState();
    fetchDataFirebase();
    _fetchNetworkImageUrl();
  }

  String? text = '';

  bool isRTL(String text) {
    return intl.Bidi.detectRtlDirectionality(text);
  }

  @override
  Widget build(BuildContext context) {
    TextDirection textdireLtr = TextDirection.ltr;
    super.build(context);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    TextDirection textDirection =
        intl.Bidi.isRtlLanguage(Localizations.localeOf(context).languageCode)
            ? TextDirection.rtl
            : TextDirection.ltr;
    widget.is_done == null
        ? widget.is_done = false
        : widget.is_done = widget.is_done;
    return widget.is_done!
        ? Scaffold(
            backgroundColor: const Color.fromARGB(255, 228, 237, 248),
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Card(
                  color: COLOR_GREY,
                  child: FlipCard(
                    fill: Fill.fillBack,
                    front: Scaffold(
                      backgroundColor: const Color.fromARGB(255, 228, 237, 248),
                      body: StreamBuilder<cardPage>(
                        stream: readcard2(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                                'something went wrong! ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            final card = snapshot.data!;
                            return buildCardFront(card, context);
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
                    back: Scaffold(
                      backgroundColor: const Color.fromARGB(255, 228, 237, 248),
                      body: StreamBuilder<cardPage>(
                        stream: readcard2(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                                'something went wrong! ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            final card = snapshot.data!;
                            return buildCardBack(card, context);
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ))
        : GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              backgroundColor: const Color.fromARGB(255, 228, 237, 248),
              body: SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "title: ",
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                            TextFormField(
                              onChanged: (text) {
                                if (text.isNotEmpty &&
                                    text.codeUnitAt(0) >= 0x0590 &&
                                    text.codeUnitAt(0) <= 0x05FF &&
                                    widget.is_once_title == false) {
                                  print('its hebrew!!!');
                                  setState(() {
                                    widget.is_hebrew_title = true;
                                  });
                                } else {
                                  setState(() {
                                    widget.is_hebrew_title = false;
                                  });
                                }
                              },
                              textAlign: _hebrew(widget.is_hebrew_title),
                              minLines: 1,
                              maxLines: 20,
                              controller: controller1,
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
                              height: height * 0.025,
                            ),
                            const Text("Question Input: "),
                            TextFormField(
                              onChanged: (text) {
                                if (text.isNotEmpty &&
                                    text.codeUnitAt(0) >= 0x0590 &&
                                    text.codeUnitAt(0) <= 0x05FF &&
                                    widget.is_once_ques == false) {
                                  print('its hebrew!!!');
                                  setState(() {
                                    widget.is_hebrew_ques = true;
                                  });
                                } else {
                                  setState(() {
                                    widget.is_hebrew_ques = false;
                                  });
                                }
                              },
                              textAlign: _hebrew(widget.is_hebrew_ques),
                              minLines: 1,
                              maxLines: 100,
                              controller: controller2,
                              decoration: const InputDecoration(
                                hintText: 'Question',
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
                              height: height * 0.025,
                            ),
                            const Text("Answer Input: "),
                            TextFormField(
                              onChanged: (text) {
                                if (text.isNotEmpty &&
                                    text.codeUnitAt(0) >= 0x0590 &&
                                    text.codeUnitAt(0) <= 0x05FF &&
                                    widget.is_once_ans == false) {
                                  print('its hebrew!!!');
                                  setState(() {
                                    widget.is_hebrew_ans = true;
                                  });
                                } else {
                                  setState(() {
                                    widget.is_hebrew_ans = false;
                                  });
                                }
                                print("is_hebrew");
                                print(widget.is_hebrew_ans);
                              },
                              textAlign: _hebrew(widget.is_hebrew_ans),
                              minLines: 1,
                              maxLines: 100,
                              controller: controller3,
                              decoration: const InputDecoration(
                                hintText: 'Answer',
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
                              height: height * 0.04,
                            ),
                            Row(
                              children: [
                                const Text(
                                    "choose an image for question page: "),
                                ElevatedButton(
                                    onPressed: () {
                                      _selecteImage(true);
                                      print("here");
                                      print(imageStrQue);
                                    },
                                    child: const Icon(Icons.add_a_photo))
                              ],
                            ),
                            SizedBox(
                              height: height * 0.04,
                            ),
                            Row(
                              children: [
                                const Text("choose an image for answer page: "),
                                ElevatedButton(
                                    onPressed: () {
                                      _selecteImage(false);
                                    },
                                    child: const Icon(Icons.add_a_photo))
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: height * 0.1,
                      ),
                      Column(
                        children: [
                          const Text("Save card"),
                          ElevatedButton(
                              onPressed: () async {
                                if (widget.is_update == true) {
                                  if (controller1.text.isNotEmpty) {
                                    title = controller1.text;
                                  }
                                  question = controller2.text;
                                  answer = controller3.text;
                                  widget.is_done = true;
                                  await updateCard();
                                  print("title");
                                  print(title);
                                  widget.is_update = false;
                                  Navigator.of(context).pop(title);
                                } else {
                                  title = controller1.text;
                                  question = controller2.text;
                                  answer = controller3.text;
                                  widget.is_done = true;
                                  await _showCircularProg(context);
                                  Navigator.of(context).pop(title);
                                }
                              },
                              child: const Icon(Icons.save)),
                          SizedBox(
                            height: height * 0.04,
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Back'),
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          is_loading
                              ? const CircularProgressIndicator()
                              : SizedBox(),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
