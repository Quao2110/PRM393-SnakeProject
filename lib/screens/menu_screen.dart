import 'package:flutter/material.dart';
import 'package:snakeproject/screens/settings_dialog.dart';
import '../core/audio_manager.dart';
import '../core/constants.dart';
import '../widgets/custom_button.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    AudioManager.playBackground('background.mp3');
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
          Positioned( top: 40, right: 20,
            child: Row( mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 40, color: Colors.yellow),
                  onPressed: () {
                    AudioManager.playSFX('click.mp3');
                    Navigator.pushNamed(context, '/intro');
                  },
                ),
                const SizedBox(width: 8),
                IconButton( icon: const Icon( Icons.settings, size: 40, color: Colors.yellow, ),
                  onPressed: () {
                    AudioManager.playSFX('click.mp3');
                    showDialog(
                      context: context,
                      builder: (_) => const SettingsDialog(),
                    );
                  },
                ),
              ],
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
                      Shadow(blurRadius: 10, color: Colors.orange, offset: Offset(2, 2))
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
                      Navigator.pushNamed(context, '/lobby').then((_) {
                        AudioManager.playBackground('background.mp3');
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