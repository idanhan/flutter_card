import 'package:flutter/material.dart';
import 'package:cards2_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Mydrawer2 extends StatelessWidget {
  Mydrawer2({super.key});
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
              decoration: BoxDecoration(color: COLOR_DARK_BLUE),
              child: Text(
                "Menu",
                style: TextStyle(fontSize: 24, color: COLOR_WHITE),
              )),
          ListTile(
            iconColor: COLOR_DARK_BLUE,
            leading: const Icon(Icons.arrow_forward),
            title: const Text("Home Page"),
            onTap: () {
              Navigator.of(context).popUntil((route) {
                return route.isFirst;
              });
            },
          )
        ],
      ),
    );
  }
}
