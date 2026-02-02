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
          child: Column(
            children: [
              _buildHeader(), // Đã thu nhỏ
              _buildBetInfo(), // Đã thu nhỏ
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double laneHeight = constraints.maxHeight / 3;
                    return _buildRaceTrack(constraints.maxWidth, laneHeight);
                  },
                ),
              ),
              _buildLeaderboard(), // Đã thu nhỏ
              _buildBottomButtons(), // Đã thu nhỏ
            ],
          ),
        ),
      ),
    );
  }

  // THU NHỎ HEADER
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Giảm vertical padding
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), // Giảm size icon
          ),
          const Spacer(),
          const Text(
              '🏁 ĐUA THÔI AI THẮNG 🏁',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white) // Giảm fontSize
          ),
          const Spacer(),
          IconButton(
            onPressed: _restartRace,
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // THU NHỎ KHUNG CHỮ CƯỢC
  Widget _buildBetInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2), // Giảm margin
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12), // Giảm padding
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'BẠN CƯỢC: ${betInfo?.racer.name}',
            style: const TextStyle(color: Colors.white70, fontSize: 12), // Giảm fontSize
          ),
          const SizedBox(width: 15),
          const Icon(Icons.monetization_on, color: Colors.amber, size: 14),
          Text(
            ' ${betInfo?.betAmount}\$',
            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ĐƯỜNG ĐUA TO RA (Sử dụng LayoutBuilder)
  Widget _buildRaceTrack(double width, double laneHeight) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade900,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          children: [
            _buildTrackBackground(),
            _buildFinishLine(),
            ..._buildRacers(width, laneHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackBackground() {
    return Positioned.fill(
      child: Column(
        children: [
          Expanded(child: Container(color: Colors.transparent)),
          Container(height: 2, color: Colors.white24),
          Expanded(child: Container(color: Colors.transparent)),
          Container(height: 2, color: Colors.white24),
          Expanded(child: Container(color: Colors.transparent)),
        ],
      ),
    );
  }

  Widget _buildFinishLine() {
    return Positioned(
      right: 30, top: 0, bottom: 0,
      child: Container(width: 8, color: Colors.white30),
    );
  }

  List<Widget> _buildRacers(double trackWidth, double laneHeight) {
    double usableWidth = trackWidth - 80;

    return List.generate(racers.length, (index) {
      final racer = racers[index];
      final position = racerPositions[index];
      final isBetCar = betInfo?.racer.id == racer.id;

      return AnimatedPositioned(
        duration: const Duration(milliseconds: 50),
        left: 20 + (usableWidth * position),
        top: index * laneHeight,
        height: laneHeight,
        child: Center(
          child: _buildSnakeWidget(racer, isBetCar, laneHeight),
        ),
      );
    });
  }

  Widget _buildSnakeWidget(Racer racer, bool isBetCar, double laneHeight) {
    final isWinner = raceFinished && winnerId == racer.id;
    double snakeSize = laneHeight * 0.7; // Tăng kích thước rắn so với làn đường

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isBetCar)
          const Text('BẠN LÀ BẠN ĐÓ CHÍNH BẠN', style: TextStyle(color: Colors.amber, fontSize: 8, fontWeight: FontWeight.bold)),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isWinner ? snakeSize * 1.1 : snakeSize,
          height: isWinner ? snakeSize * 1.1 : snakeSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: isBetCar ? Colors.amber : racer.color, width: 2),
          ),
          child: ClipOval(
            child: Image.asset(_getSnakeImage(racer.id), fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  // THU NHỎ BẢNG XẾP HẠNG
  Widget _buildLeaderboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: racers.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
              '${(racerPositions[e.key] * 100).toInt()}%',
              style: const TextStyle(color: Colors.white60, fontSize: 10) // Thu nhỏ text %
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
          isRacing ? "🔥 ĐANG ĐUA 🔥" : "🏁 KẾT THÚC 🏁",
          style: const TextStyle(color: Colors.white38, fontSize: 10) // Thu nhỏ nhãn trạng thái
      ),
    );
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

  Widget _buildCountdownOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Text(
            countdown > 0 ? '$countdown' : 'GO!',
            style: const TextStyle(fontSize: 60, color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
}