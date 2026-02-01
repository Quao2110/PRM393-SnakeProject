import 'package:flutter/material.dart';
import '../core/constants.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ===== BACKGROUND =====
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

          // ===== WOOD PANEL =====
          Center(
            child: Stack(
              children: [
                Container(
                  width: 550,
                  padding: const EdgeInsets.fromLTRB(50, 50, 40, 50),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Center(
                          child: Text(
                            'HƯỚNG DẪN GAME',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Cách chơi:\n'
                              '1) Vào đua và chọn cược trước khi bắt đầu.\n'
                              '2) Có 3 tay đua/thú tham gia, mỗi ván chỉ có 1 người thắng.\n'
                              '3) Nếu bạn cược đúng người thắng, bạn nhận thưởng; cược sai sẽ mất tiền cược.\n\n'
                              'Mẹo:\n'
                              '- Theo dõi tốc độ/di chuyển để chọn cược hợp lý.\n'
                              '- Quản lý tiền cược để chơi được lâu hơn.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== CLOSE BUTTON =====
                Positioned(
                  top: 25,
                  right: 35,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
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
