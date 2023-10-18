import 'dart:async';

import 'package:cards2_app/home2.dart';
import 'package:cards2_app/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  Timer? timer;
  final userdel = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(Duration(seconds: 3), (_) {
        checkEmailVerified();
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
    } catch (e) {
      Utils.showSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return isEmailVerified
        ? HomeScreen2()
        : Scaffold(
            appBar: AppBar(
              title: Text('Verify Email'),
            ),
            body: Column(
              children: [
                const Center(
                  child: Text('Check and verify your email'),
                ),
                SizedBox(
                  height: 0.8 * height,
                ),
                ElevatedButton.icon(
                  label: const Text('Back'),
                  onPressed: () async {
                    await userdel!.delete();
                  },
                  icon: const Icon(Icons.navigate_before_outlined),
                )
              ],
            ),
          );
  }
}
