import 'package:cards2_app/constants.dart';
import 'package:cards2_app/home2.dart';
import 'package:cards2_app/homePage.dart';
import 'package:cards2_app/main.dart';
import 'package:cards2_app/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';

class SignupPage extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const SignupPage({super.key, required this.onClickedSignUp});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final formkey = GlobalKey<FormState>();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String _email = '';
    String _password = '';

    Future<void> _signUp() async {
      final isValid = formkey.currentState!.validate();
      if (!isValid) {
        return;
      }
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ));
      try {
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: _email, password: _password);
      } on FirebaseAuthException catch (error) {
        print(error);

        Utils.showSnackBar(error.message);
      }

      navigatorKey.currentState!.popUntil((route) => route.isFirst);
    }

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return HomePage();
              } else {
                return GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: Scaffold(
                    body: SafeArea(
                      child: Container(
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                              Color.fromRGBO(50, 5, 47, 1),
                              Color.fromRGBO(60, 29, 164, 1)
                            ])),
                        child: ListView(shrinkWrap: false, children: [
                          Form(
                            key: formkey,
                            child: Column(
                              children: [
                                const SizedBox(height: 50),
                                const Icon(
                                  Icons.lock,
                                  size: 100,
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                                const Text(
                                  'welcomeBack',
                                  style: TextStyle(
                                      color: COLOR_WHITE, fontSize: 16),
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: TextFormField(
                                    style: const TextStyle(color: COLOR_WHITE),
                                    controller: usernameController,
                                    decoration: InputDecoration(
                                      fillColor: COLOR_WHITE,
                                      hintText: 'Username',
                                      hintStyle:
                                          const TextStyle(color: COLOR_WHITE),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: COLOR_WHITE),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade400),
                                      ),
                                    ),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (email) => email != null &&
                                            !EmailValidator.validate(email)
                                        ? 'Enter a valid Email'
                                        : null,
                                  ),
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: TextFormField(
                                    controller: passwordController,
                                    obscureText: true,
                                    style: TextStyle(color: COLOR_WHITE),
                                    decoration: InputDecoration(
                                      fillColor: COLOR_WHITE,
                                      hintText: 'Password',
                                      hintStyle:
                                          const TextStyle(color: COLOR_WHITE),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: COLOR_WHITE),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade400),
                                      ),
                                    ),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) =>
                                        value != null && value.length < 6
                                            ? 'Enter a min 6 characters'
                                            : null,
                                  ),
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                RichText(
                                    textAlign: TextAlign.end,
                                    text: TextSpan(
                                        style: TextStyle(color: COLOR_WHITE),
                                        text: 'Already have an account?',
                                        children: [
                                          TextSpan(
                                              text: ' Log in',
                                              recognizer: TapGestureRecognizer()
                                                ..onTap =
                                                    widget.onClickedSignUp,
                                              style: const TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  color: COLOR_RED)),
                                        ])),
                                const SizedBox(
                                  height: 50,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                          icon: const Icon(
                                            Icons.lock_open,
                                            size: 32,
                                          ),
                                          style: const ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                                    Colors.black54),
                                          ),
                                          onPressed: () {
                                            _email =
                                                usernameController.text.trim();
                                            _password =
                                                passwordController.text.trim();
                                            _signUp();
                                          },
                                          label: const Text(
                                            'Sign Up',
                                            style: TextStyle(fontSize: 24),
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                );
              }
            }),
      ),
    );
  }
}
