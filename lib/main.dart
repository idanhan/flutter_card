import 'package:cards2_app/Auth.dart';
import 'package:cards2_app/cards/verifyEmailPage.dart';
import 'package:cards2_app/homecard.dart';
import 'package:cards2_app/modules/cardsM.dart';
import 'package:cards2_app/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import './homecard.dart';
import './signIn.dart';
import './HomePage.dart';
import './login.dart';
import './login.dart';
import './home2.dart';
import 'package:intl/intl.dart';
import 'package:flutter_langdetect/flutter_langdetect.dart' as langdetect;
import './modules/cardsObject.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await langdetect.initLangDetect();
  await Firebase.initializeApp(
      name: 'cards', options: DefaultFirebaseOptions.currentPlatform);
  print("intialize successful");
  runApp(Main());
}

final navigatorKey = GlobalKey<NavigatorState>();

class Main extends StatelessWidget {
  Main({super.key});
  final locale = const Locale("en");

  final kColorScheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(250, 97, 97, 147),
      background: const Color.fromARGB(249, 77, 77, 122));

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CardList()),
        ChangeNotifierProvider(create: (context) => cardModulePro())
      ],
      child: MaterialApp(
        locale: locale,
        supportedLocales: const [
          Locale('en'),
          Locale('he'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: Utils.messengerKey,
        navigatorKey: navigatorKey,
        title: 'cards',
        theme: ThemeData(fontFamily: 'Montserrat').copyWith(
          useMaterial3: true,
          colorScheme: kColorScheme,
        ),
        home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text("something went wrong!"),
                );
              } else if (snapshot.hasData) {
                return const VerifyEmailPage();
              } else {
                return const AuthPage();
              }
            }),
        routes: {
          "homePage": (context) => HomePage(),
        },
      ),
    );
  }
}
