import 'package:flutter/material.dart';
import '../core/audio_manager.dart';
import '../core/constants.dart';
import '../widgets/custom_button.dart';
import '../models/bet_info.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    AudioManager.playBackground();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppConstants.backgroundGame,
              image: DecorationImage(
                image: AssetImage('assets/images/bg_menu.jpg'),
                fit: BoxFit.cover,
                opacity: 0.4,
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pets, size: 100, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  "ĐUA XE THÚ",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.orange,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                // LOBBY
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GameButton(
                    text: "VÀO ĐUA NGAY",
                    onPressed: () {
                      AudioManager.stopBackground();
                      Navigator.pushNamed(context, '/lobby').then((_) {
                        AudioManager.playBackground();
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                //INTRO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GameButton(
                    text: "HƯỚNG DẪN",
                    color: Colors.blueGrey,
                    onPressed: () {
                      AudioManager.stopBackground();
                      Navigator.pushNamed(context, '/intro').then((_) {
                        AudioManager.playBackground();
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GameButton(
                    text: "🏎️ TEST RACE",
                    color: Colors.purple,
                    onPressed: () {
                      AudioManager.stopBackground();
                      Navigator.pushNamed(
                        context,
                        '/race',
                        arguments: BetInfo.dummyBet,
                      ).then((_) {
                        AudioManager.playBackground();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
