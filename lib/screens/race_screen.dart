import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/bet_info.dart';
import '../models/racer.dart';
import '../core/constants.dart';
import '../core/audio_manager.dart';
import '../core/player_data.dart';

class RaceScreen extends StatefulWidget {
  const RaceScreen({super.key});

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> with TickerProviderStateMixin {
  late List<Racer> racers;
  late List<double> racerPositions;
  BetInfo? betInfo;
  Timer? raceTimer;
  bool isRacing = false;
  bool raceFinished = false;
  String? winnerId;

  int countdown = 3;
  bool showCountdown = true;
  bool _countdownStarted = false;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    racers = Racer.dummyRacers;
    racerPositions = List.filled(racers.length, 0.0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is BetInfo) {
      betInfo = args;
    } else {
      betInfo = BetInfo.dummyBet;
    }

    if (!_countdownStarted) {
      _countdownStarted = true;
      _startCountdown();
    }
  }

  @override
  void dispose() {
    raceTimer?.cancel();
    super.dispose();
  }

  String _getSnakeImage(String id) {
    switch (id) {
      case '1': return 'assets/images/snake_red.jpg';
      case '2': return 'assets/images/snake_blue.jpg';
      case '3': return 'assets/images/snake_green.jpg';
      default: return 'assets/images/snake_red.jpg';
    }
  }

  void _startCountdown() async {
    for (int i = 3; i > 0; i--) {
      if (!mounted) return;
      setState(() {
        countdown = i;
        showCountdown = true;
      });
      AudioManager.playSFX('click.mp3');
      await Future.delayed(const Duration(seconds: 1));
    }
    if (!mounted) return;
    setState(() => showCountdown = false);
    _startRace();
  }

  void _startRace() {
    setState(() => isRacing = true);
    AudioManager.playSFX('race_start.mp3');

    raceTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      bool someoneFinished = false;
      setState(() {
        for (int i = 0; i < racers.length; i++) {
          if (racerPositions[i] < 1.0) {
            double baseSpeed = 0.008;
            double randomFactor = _random.nextDouble() * 0.015;
            racerPositions[i] += baseSpeed + randomFactor;

            if (racerPositions[i] >= 1.0) {
              racerPositions[i] = 1.0;
              if (winnerId == null) {
                winnerId = racers[i].id;
                someoneFinished = true;
              }
            }
          }
        }
      });

      if (someoneFinished) _finishRace();
    });
  }

  void _finishRace() {
    raceTimer?.cancel();
    setState(() {
      isRacing = false;
      raceFinished = true;
    });
    Future.delayed(const Duration(milliseconds: 800), () => _navigateToResult());
  }

  void _navigateToResult() {
    if (betInfo == null || winnerId == null) return;
    bool isWin = betInfo!.racer.id == winnerId;
    int betAmount = betInfo!.betAmount;

    if (isWin) {
      PlayerData.addMoney(betAmount);
    } else {
      PlayerData.subtractMoney(betAmount);
    }

    Navigator.pushReplacementNamed(
      context, '/result',
      arguments: {
        'isWin': isWin,
        'winnerId': winnerId,
        'betInfo': betInfo,
        'winAmount': isWin ? betAmount : -betAmount,
      },
    );
  }

  void _goBack() {
    raceTimer?.cancel();
    Navigator.pop(context);
  }

  void _restartRace() {
    raceTimer?.cancel();
    setState(() {
      racerPositions = List.filled(racers.length, 0.0);
      isRacing = false;
      raceFinished = false;
      winnerId = null;
      countdown = 3;
      showCountdown = true;
      _countdownStarted = false;
    });
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  _buildBetInfo(),
                  Expanded(child: _buildRaceTrack()),
                  _buildLeaderboard(),
                  _buildBottomButtons(),
                ],
              ),
              if (showCountdown) _buildCountdownOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(onPressed: _goBack, icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white)),
          const Spacer(),
          const Text('🏁 RACE TIME 🏁', style: AppConstants.titleStyle),
          const Spacer(),
          IconButton(onPressed: _restartRace, icon: const Icon(Icons.refresh, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildBetInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: betInfo?.racer.color ?? Colors.white24, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('BẠN CƯỢC: ', style: TextStyle(color: Colors.white70)),
          Text(betInfo?.racer.name ?? '', style: TextStyle(color: betInfo?.racer.color, fontWeight: FontWeight.bold)),
          const SizedBox(width: 20),
          const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
          Text(' ${betInfo?.betAmount}\$', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRaceTrack() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          children: [
            _buildTrackBackground(),
            _buildStartLine(),
            _buildFinishLine(),
            ..._buildRacers(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackBackground() {
    return Positioned.fill(
      child: Column(
        children: [
          Expanded(flex: 1, child: Container(color: Colors.green.shade800)),
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                border: const Border.symmetric(
                  horizontal: BorderSide(color: Colors.white, width: 3),
                ),
              ),
              child: Stack(
                children: [
                  Center(child: Container(height: 4, color: Colors.yellow.withOpacity(0.5))),
                  Positioned.fill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(15, (i) => Container(
                        width: 20, height: 4,
                        color: i % 2 == 0 ? Colors.white54 : Colors.transparent,
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(flex: 1, child: Container(color: Colors.green.shade800)),
        ],
      ),
    );
  }

  Widget _buildStartLine() {
    return Positioned(
      left: 30, top: 0, bottom: 0,
      child: Container(width: 6, color: Colors.white70),
    );
  }

  Widget _buildFinishLine() {
    return Positioned(
      right: 20, top: 0, bottom: 0,
      child: SizedBox(
        width: 24,
        child: Column(
          children: List.generate(20, (row) => Expanded(
            child: Row(
              children: List.generate(3, (col) => Expanded(
                child: Container(color: (row + col) % 2 == 0 ? Colors.black : Colors.white),
              )),
            ),
          )),
        ),
      ),
    );
  }

  List<Widget> _buildRacers() {
    // Chiều rộng đường đua thực tế tính từ sau vạch xuất phát đến vạch đích
    final trackWidth = MediaQuery.of(context).size.width - 160;
    // Offset dọc cố định để chia 3 làn cân xứng tuyệt đối
    final yOffsets = [-75.0, 0.0, 75.0];

    return List.generate(racers.length, (index) {
      final racer = racers[index];
      final position = racerPositions[index];
      final isBetCar = betInfo?.racer.id == racer.id;

      return AnimatedPositioned(
        duration: const Duration(milliseconds: 50),
        // Nhân vật bắt đầu từ sau vạch xuất phát (40)
        left: 40 + (trackWidth * position),
        top: 0, bottom: 0,
        child: Center(
          child: Transform.translate(
            offset: Offset(0, yOffsets[index]), // Căn chỉnh đối xứng theo trục Y
            child: _buildSnakeWidget(racer, isBetCar),
          ),
        ),
      );
    });
  }

  Widget _buildSnakeWidget(Racer racer, bool isBetCar) {
    final isWinner = raceFinished && winnerId == racer.id;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Nhãn "YOU" cố định phía trên để không làm lệch vị trí ảnh
        SizedBox(
          height: 15,
          child: isBetCar
              ? const Text('YOU', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold))
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isWinner ? 60 : 50,
          height: isWinner ? 60 : 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: isBetCar ? Colors.amber : racer.color, width: 3),
            boxShadow: [BoxShadow(color: racer.color.withOpacity(0.5), blurRadius: 10)],
          ),
          child: ClipOval(
            child: Image.asset(_getSnakeImage(racer.id), fit: BoxFit.cover),
          ),
        ),
        // Cúp thắng cuộc hiển thị phía dưới
        SizedBox(
          height: 20,
          child: isWinner ? const Text('🏆', style: TextStyle(fontSize: 16)) : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildLeaderboard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: racers.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('${(racerPositions[e.key] * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 12)),
        )).toList(),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(isRacing ? "🔥 ĐANG ĐUA 🔥" : "🏁 KẾT THÚC 🏁", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCountdownOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Text(countdown > 0 ? '$countdown' : 'GO!', style: const TextStyle(fontSize: 80, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}