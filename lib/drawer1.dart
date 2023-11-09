import 'package:flutter/material.dart';
import 'package:cards2_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import './modules/cardsM.dart';
import './modules/cardsObject.dart';

class Mydrawer extends StatelessWidget {
  Mydrawer({super.key});
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Consumer2<cardModulePro, CardList>(builder: (BuildContext context,
        cardModulePro modulevalue, CardList cardvalue, Widget? child) {
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
                decoration: BoxDecoration(color: COLOR_DARK_BLUE),
                child: Text(
                  "Sign out",
                  style: TextStyle(fontSize: 24, color: COLOR_WHITE),
                )),
            ListTile(
              iconColor: COLOR_RED,
              leading: Icon(Icons.logout_rounded),
              title: Text("Sign out"),
              onTap: () {
                modulevalue.removeAll();
                cardvalue.removeAll();
                FirebaseAuth.instance.signOut();
              },
            )
          ],
        ),
      );
    });
  }
}
