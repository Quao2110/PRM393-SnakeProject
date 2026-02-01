import 'package:flutter/material.dart';
import 'screens/menu_screen.dart';
import 'screens/lobby_screen.dart';
// import 'screens/intro_screen.dart';
// import 'screens/betting_screen.dart';
import 'screens/race_screen.dart';
// import 'screens/result_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Racing Game',
      theme: ThemeData(primarySwatch: Colors.orange, fontFamily: 'Roboto'),
      initialRoute: '/',
      routes: {
        '/': (context) => const MenuScreen(),
        '/lobby': (context) => const LobbyScreen(),
        // '/intro': (context) => const IntroScreen(),
        // '/betting': (context) => const BettingScreen(),
        '/race': (context) => const RaceScreen(),
        // '/result': (context) => const ResultScreen(),

        // để tạm
        '/intro': (context) => Scaffold(appBar: AppBar(title: Text("Intro"))),
      },
    );
  }
}
