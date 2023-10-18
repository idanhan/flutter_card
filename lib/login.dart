import 'package:cards2_app/constants.dart';
import 'package:cards2_app/forgot_password_page.dart';
import 'package:cards2_app/home2.dart';
import 'package:cards2_app/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onClickedSignUp;

  const LoginPage({super.key, required this.onClickedSignUp});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String _email = '';
    String _password = '';

    Future<void> _signInWithEmail() async {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ));
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        User? user = userCredential.user;
      } catch (e) {
        // Handle sign-in errors here (e.g., show an error message to the user).
        print('Error: $e');
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
                return HomeScreen2();
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
                          Column(
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
                                style:
                                    TextStyle(color: COLOR_WHITE, fontSize: 16),
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                child: TextField(
                                  controller: usernameController,
                                  style: const TextStyle(color: COLOR_WHITE),
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
                                ),
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                child: TextField(
                                  controller: passwordController,
                                  obscureText: true,
                                  style: const TextStyle(color: COLOR_WHITE),
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
                                ),
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              GestureDetector(
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 18),
                                ),
                                onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPasswordPage())),
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              RichText(
                                  textAlign: TextAlign.end,
                                  text: TextSpan(
                                      style:
                                          const TextStyle(color: COLOR_WHITE),
                                      text: 'No account?',
                                      children: [
                                        TextSpan(
                                            text: ' Sign up',
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = widget.onClickedSignUp,
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
                                          _signInWithEmail();
                                        },
                                        label: const Text(
                                          'log in',
                                          style: TextStyle(fontSize: 24),
                                        )),
                                  ],
                                ),
                              ),
                            ],
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
