import 'package:flutter/material.dart';
import '../core/audio_manager.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({Key? key}) : super(key: key);

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool isMusicOn;
  late double musicVolume;

  @override
  void initState() {
    super.initState();
    isMusicOn = AudioManager.isMusicOn;
    musicVolume = AudioManager.musicVolume;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Stack(
        children: [
          // ===== MAIN PANEL =====
          Container(
            width: 400,
            padding: const EdgeInsets.fromLTRB(40, 40, 40, 40),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/wood_panel.png'),
                fit: BoxFit.fill,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 12,
                  offset: Offset(4, 6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ===== TITLE =====
                  const Text(
                    'CÀI ĐẶT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                      shadows: [
                        Shadow(color: Colors.black26, blurRadius: 2),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== MUSIC SWITCH =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nhạc nền',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      Switch(
                        value: isMusicOn,
                        activeColor: const Color(0xFF6D4C41),        // nút tròn (nâu đậm)
                        activeTrackColor: const Color(0xFF8B5A2B),   // thanh khi ON
                        inactiveThumbColor: Colors.brown.shade300,  // nút khi OFF
                        inactiveTrackColor: Colors.brown.shade100,  // thanh khi OFF
                        onChanged: (v) {
                          setState(() => isMusicOn = v);
                          AudioManager.toggleMusic(v);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ===== VOLUME =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Âm lượng',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      Text(
                        '${(musicVolume * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                  ),

                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF8B5A2B),
                      inactiveTrackColor: Colors.brown.shade200,
                      thumbColor: const Color(0xFF6D4C41),
                    ),
                    child: Slider(
                      value: musicVolume,
                      min: 0,
                      max: 1,
                      divisions: 10,
                      onChanged: (v) {
                        setState(() => musicVolume = v);
                        AudioManager.setMusicVolume(v);
                      },
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),

          // ===== CLOSE X BUTTON =====
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.close,
                  size: 25,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
