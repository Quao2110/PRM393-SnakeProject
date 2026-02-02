// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/menu_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/betting_screen.dart';
import 'screens/race_screen.dart';
import 'screens/result_screen.dart';
import 'models/bet_info.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Sử dụng onGenerateRoute để truyền dữ liệu vào ResultScreen dễ dàng hơn
        if (settings.name == '/result') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ResultScreen(
              betInfo: args['betInfo'] as BetInfo,
              winnerId: args['winnerId'] as String,
              isWin: args['isWin'] as bool,
              winAmount: args['winAmount'] as int,
            ),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => const MenuScreen(),
        '/intro': (context) => const IntroScreen(),
        '/lobby': (context) => const LobbyScreen(),
        '/betting': (context) => const BettingScreen(),
        '/race': (context) => const RaceScreen(),
      },
    );
  }
}