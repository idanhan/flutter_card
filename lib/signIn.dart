import 'package:cards2_app/constants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class signIn extends StatefulWidget {
  final VoidCallback onClickedSignUp;
  const signIn({super.key, required this.onClickedSignUp});

  @override
  State<signIn> createState() => _signInState();
}

class _signInState extends State<signIn> {
  bool is_login = true;
  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final Function onClickSignedUp = () {
      Navigator.pushNamed(context, 'login');
    };
    final passwordController = TextEditingController();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String _email = '';
    String _password = '';

    void login() {
      Navigator.pushNamed(context, 'login');
    }

    Future<void> _signInWithEmail() async {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: usernameController.text.trim(),
          password: passwordController.text.trim(),
        );
        User? user = userCredential.user;
      } catch (e) {
        // Handle sign-in errors here (e.g., show an error message to the user).
        print('Error: $e');
      }
    }

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
            child: ListView(children: [
              Column(
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: TextFormField(
                      style: TextStyle(color: COLOR_WHITE),
                      controller: usernameController,
                      decoration: InputDecoration(
                        fillColor: COLOR_WHITE,
                        hintText: 'email',
                        hintStyle: TextStyle(color: COLOR_WHITE),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: COLOR_WHITE)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: TextFormField(
                      style: TextStyle(color: COLOR_WHITE),
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        fillColor: COLOR_WHITE,
                        hintText: 'password',
                        hintStyle: TextStyle(color: COLOR_WHITE),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: COLOR_WHITE)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                    width: 300,
                    height: 70,
                    decoration: BoxDecoration(
                      color: COLOR_BlACK,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(COLOR_BlACK),
                        ),
                        onPressed: () async {
                          await _signInWithEmail();
                        },
                        child: const Text(
                          'sign in',
                          style: TextStyle(color: COLOR_WHITE),
                        )),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  RichText(
                      text: TextSpan(
                          style: TextStyle(color: COLOR_WHITE),
                          text: 'alredy have an account?',
                          children: [
                        TextSpan(
                            text: ' Log in',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: COLOR_RED),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, 'login');
                              })
                      ])),
                  SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
