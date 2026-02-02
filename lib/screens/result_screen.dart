import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants.dart';
import '../core/player_data.dart';
import '../models/bet_info.dart';
import '../widgets/custom_button.dart';

class _RibbonBanner extends StatelessWidget {
  final String text;
  final List<Color> colors;
  final double fontSize;

  const _RibbonBanner({
    required this.text,
    required this.colors,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: -18,
          child: Transform.rotate(
            angle: -0.2,
            child: Container(
              width: 28,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        Positioned(
          right: -18,
          child: Transform.rotate(
            angle: 0.2,
            child: Container(
              width: 28,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.orange.shade700,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class ResultScreen extends StatefulWidget {
  final BetInfo betInfo;
  final String winnerId;
  final bool isWin;
  final int winAmount;

  const ResultScreen({
    super.key,
    required this.betInfo,
    required this.winnerId,
    required this.isWin,
    required this.winAmount,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    if (widget.isWin) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _backToMenu() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra người chơi có hết sạch tiền hay không
    final bool isBankrupt = PlayerData.totalMoney <= 0;

    return Scaffold(
      backgroundColor: AppConstants.backgroundGame,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: AppConstants.backgroundGame,
                image: DecorationImage(
                  image: AssetImage('assets/images/bg_menu.jpg'),
                  fit: BoxFit.cover,
                  opacity: 0.4,
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxCardWidth = constraints.maxWidth < 520
                    ? constraints.maxWidth
                    : 520.0;
                final accent = widget.isWin
                    ? Colors.amber
                    : Colors.blueGrey.shade800;
                final bannerGradient = widget.isWin
                    ? [Colors.orange.shade600, Colors.amber.shade400]
                    : [Colors.blueGrey, Colors.grey];
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxCardWidth),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 112),
                            padding: const EdgeInsets.fromLTRB(26, 48, 26, 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(65),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.9),
                                width: 5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 4),
                                // Hiển thị mã số hoặc tên tay đua chiến thắng
                                Text(
                                  'Người thắng cuộc: ${widget.winnerId}',
                                  textAlign: TextAlign.center,
                                  style: AppConstants.normalText.copyWith(
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Hiển thị thông tin cược của người chơi
                                Text(
                                  'Lựa chọn: ${widget.betInfo.racer.name} - ${widget.betInfo.betAmount} xu',
                                  textAlign: TextAlign.center,
                                  style: AppConstants.normalText.copyWith(
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Hiển thị số dư hiện tại sau ván đấu
                                Text(
                                  'Số dư: ${PlayerData.totalMoney} xu',
                                  textAlign: TextAlign.center,
                                  style: AppConstants.titleStyle.copyWith(
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: 210,
                                  child: GameButton(
                                    // Thay đổi nội dung nút bấm dựa trên trạng thái túi tiền
                                    text:
                                    isBankrupt ? 'CHƠI LẠI TỪ ĐẦU' : 'TIẾP TỤC ĐUA',
                                    onPressed: () {
                                      if (isBankrupt) {
                                        // Reset lời dữ liệu nếu hết tiền
                                        PlayerData.resetData();
                                      }
                                      _backToMenu();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 6,
                            child: Icon(
                              widget.isWin
                                  ? Icons.emoji_events
                                  : Icons.sentiment_very_dissatisfied,
                              size: 110,
                              color: accent,
                            ),
                          ),
                          Positioned(
                            top: 95,
                            child: _RibbonBanner(
                              // Chuyển biểu ngữ sang tiếng Việt
                              text: widget.isWin ? 'THẮNG RỒI NHA!' : 'THUA THÔI MÌNH LÀM LẠI !',
                              colors: bannerGradient,
                              fontSize: widget.isWin ? 22 : 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.isWin)
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              shouldLoop: false,
              gravity: 0.2,
            ),
        ],
      ),
    );
  }
}