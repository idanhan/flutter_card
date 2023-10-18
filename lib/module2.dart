import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import './constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flip_card/flip_card.dart';
import 'package:firebase_database/firebase_database.dart' as fd;
import './cardobject.dart';
import './homecard.dart';

import 'package:http/http.dart' as http;

import 'dart:io';

class cardModule2 extends StatefulWidget {
  bool? is_done;
  final front_description;
  final back_description;
  final title;
  int card_num;
  bool is_data_sent = false;
  String? frontImagePath;
  String? backImagePath;

  cardModule2(
      {this.is_done,
      this.front_description,
      this.back_description,
      this.title,
      required this.card_num,
      required Key key,
      this.backImagePath,
      this.frontImagePath})
      : super(key: key);

  @override
  State<cardModule2> createState() => cardModuleState2();
}

class cardModuleState2 extends State<cardModule2>
    with AutomaticKeepAliveClientMixin<cardModule2> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? title;
  String? question;
  String? answer;
  File? _selectedImage;
  final controller1 = TextEditingController();
  final controller2 = TextEditingController();
  final controller3 = TextEditingController();
  bool _isready = false;
  String? imageStrAns;
  String? imageStrQue;

  bool? is_que;
  Map<String, Object> cardMap = {};

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
    image1 = await _cropImage(imageFile: PickedFile);
    setState(() {
      if (is_que!) {
        imageStrQue = image1!.path;
      } else {
        imageStrAns = image1!.path;
      }
    });
  }

  Future createCard({required String datatitle}) async {
    final docCard = FirebaseFirestore.instance
        .collection('cards2')
        .doc('card${widget.card_num}');

    final card = cardPage(
        title: datatitle,
        frontText: question,
        backText: answer,
        frontImagepath: imageStrQue,
        backImagepath: imageStrAns,
        is_done: true);

    final json = card.toFireStore();

    await docCard.set(json);
    widget.is_data_sent = true;
  }

  Stream<List<cardPage>> readCard() => FirebaseFirestore.instance
      .collection('cards2')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((e) => cardPage.fromFireStore(e)).toList());

  Stream<cardPage> readcard() {
    return FirebaseFirestore.instance
        .collection('cards2')
        .doc('card${widget.card_num}')
        .snapshots()
        .map((event) => cardPage.fromFireStore(event));
  }

  Widget buildCardFront(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.all(20),
      child: ListView(
        shrinkWrap: true,
        children: [
          widget.title != null
              ? Container(
                  margin: EdgeInsets.all(height * 0.02),
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            top: height * 0.02, bottom: height * 0.02),
                        child: Text(
                          "title: ",
                          style: TextStyle(fontSize: height * 0.03),
                        ),
                      ),
                      SizedBox(
                        width: width * 0.03,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: height * 0.02, bottom: height * 0.02),
                        child: Text(
                          widget.title,
                          style: TextStyle(fontSize: height * 0.03),
                        ),
                      )
                    ],
                  ),
                )
              : const SizedBox(),
          widget.front_description != null
              ? Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: height * 0.02, bottom: height * 0.02),
                      child: Text(
                        "Question: ",
                        style: TextStyle(fontSize: height * 0.03),
                      ),
                    ),
                    SizedBox(
                      width: width * 0.01,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: height * 0.02, bottom: height * 0.02),
                      width: width * 0.4,
                      child: Text(
                        widget.front_description!,
                        style: TextStyle(fontSize: height * 0.03),
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
          widget.frontImagePath != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Image: "),
                    Container(
                      margin: EdgeInsets.all(height * 0.01),
                      height: height * 0.3,
                      width: width * 0.5,
                      child: Image.file(File(widget.frontImagePath!)),
                    ),
                  ],
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Widget buildCardBack(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.all(20),
      child: ListView(
        shrinkWrap: true,
        children: [
          widget.title != null
              ? Container(
                  margin: EdgeInsets.all(height * 0.02),
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            top: height * 0.02, bottom: height * 0.02),
                        child: Text(
                          "title: ",
                          style: TextStyle(fontSize: height * 0.03),
                        ),
                      ),
                      SizedBox(
                        width: width * 0.03,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            top: height * 0.02, bottom: height * 0.02),
                        child: Text(
                          widget.title!,
                          style: TextStyle(fontSize: height * 0.03),
                        ),
                      )
                    ],
                  ),
                )
              : const SizedBox(),
          widget.back_description != null
              ? Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: height * 0.02, bottom: height * 0.02),
                      child: Text(
                        "Answer: ",
                        style: TextStyle(fontSize: height * 0.03),
                      ),
                    ),
                    SizedBox(
                      width: width * 0.03,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: height * 0.02, bottom: height * 0.02),
                      child: Text(
                        widget.back_description!,
                        style: TextStyle(fontSize: height * 0.03),
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
          widget.backImagePath != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("Image: "),
                    Container(
                      margin: EdgeInsets.all(height * 0.01),
                      height: height * 0.3,
                      width: width * 0.5,
                      child: Image.file(File(widget.backImagePath!)),
                    ),
                  ],
                )
              : const SizedBox(),
          SizedBox(
            height: height * 0.4,
          ),
          Container(
            width: width * 0.01,
            child: Row(children: [
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
    );
  }

  Future<void> fetchDataFirebase() async {
    DocumentSnapshot doc1 = await FirebaseFirestore.instance
        .collection('cards2')
        .doc('card${widget.card_num}')
        .get();
    if (doc1.exists) {
      setState(() {
        widget.is_done = doc1['is_done'];
      });
    } else {
      setState(() {
        widget.is_done = false;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    widget.is_done == null
        ? widget.is_done = false
        : widget.is_done = widget.is_done;
    return widget.is_done!
        ? Scaffold(
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Card(
                  color: COLOR_GREY,
                  child: FlipCard(
                    fill: Fill.fillBack,
                    front: Scaffold(
                        body: ListView(children: [
                      buildCardFront(context),
                    ])),
                    back: Scaffold(
                        body: ListView(children: [
                      buildCardBack(context),
                    ])),
                  ),
                ),
              ),
            ))
        : GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
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
                            const SizedBox(
                              height: 20,
                            ),
                            const Text("Question Input: "),
                            TextFormField(
                              minLines: 1,
                              maxLines: 20,
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
                            const SizedBox(
                              height: 20,
                            ),
                            const Text("Answer Input: "),
                            TextFormField(
                              minLines: 1,
                              maxLines: 20,
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
                            const SizedBox(
                              height: 30,
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
                            const SizedBox(
                              height: 30,
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
                      const SizedBox(
                        height: 200,
                      ),
                      Column(
                        children: [
                          const Text("save page"),
                          ElevatedButton(
                              onPressed: () {
                                title = controller1.text;
                                question = controller2.text;
                                answer = controller3.text;
                                createCard(datatitle: title!);
                                widget.is_done = true;
                                Navigator.of(context).pop(controller1.text);
                              },
                              child: const Icon(Icons.save)),
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
