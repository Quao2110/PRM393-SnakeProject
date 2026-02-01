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
    setState(() {
      showCountdown = false;
    });
    _startRace();
  }

  void _startRace() {
    setState(() {
      isRacing = true;
    });

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

      if (someoneFinished) {
        _finishRace();
      }
    });
  }

  void _finishRace() {
    raceTimer?.cancel();
    setState(() {
      isRacing = false;
      raceFinished = true;
    });
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
      context,
      '/result',
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
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _countdownStarted = true;
        _startCountdown();
      }
    });
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
              if (raceFinished) _buildResultOverlay(),
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _goBack,
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
          ),
          const Spacer(),
          // Title
          const Text(
            '🏁 RACE TIME 🏁',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Colors.orange, blurRadius: 10)],
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _restartRace,
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBetInfo() {
    if (betInfo == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [betInfo!.racer.color.withOpacity(0.3), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: betInfo!.racer.color, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, color: Colors.amber, size: 28),
          const SizedBox(width: 8),
          Text(
            'BẠN CƯỢC: ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: betInfo!.racer.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              betInfo!.racer.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.monetization_on, color: Colors.amber, size: 24),
          const SizedBox(width: 4),
          Text(
            '${betInfo!.betAmount}\$',
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.green.shade900,
            Colors.green.shade800,
            Colors.brown.shade700,
          ],
        ),
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
                  Center(
                    child: Container(
                      height: 4,
                      color: Colors.yellow.withOpacity(0.5),
                    ),
                  ),
                  Positioned.fill(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(15, (i) {
                        return Container(
                          width: 20,
                          height: 4,
                          color: i % 2 == 0
                              ? Colors.white54
                              : Colors.transparent,
                        );
                      }),
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
      left: 30,
      top: 0,
      bottom: 0,
      child: Container(
        width: 6,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildFinishLine() {
    return Positioned(
      right: 20,
      top: 0,
      bottom: 0,
      child: SizedBox(
        width: 24,
        child: Column(
          children: List.generate(20, (row) {
            return Expanded(
              child: Row(
                children: List.generate(3, (col) {
                  bool isBlack = (row + col) % 2 == 0;
                  return Expanded(
                    child: Container(
                      color: isBlack ? Colors.black : Colors.white,
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  List<Widget> _buildRacers() {
    final trackWidth = MediaQuery.of(context).size.width - 32 - 80;

    final yOffsets = [-60.0, 0.0, 60.0];

    return List.generate(racers.length, (index) {
      final racer = racers[index];
      final position = racerPositions[index];
      final isBetCar = betInfo?.racer.id == racer.id;

      return AnimatedPositioned(
        duration: const Duration(milliseconds: 50),
        left: 40 + (trackWidth * position * 0.85),
        top: 0,
        bottom: 0,
        child: Center(
          child: Transform.translate(
            offset: Offset(0, yOffsets[index]),
            child: _buildCarWidget(racer, isBetCar, index),
          ),
        ),
      );
    });
  }

  Widget _buildCarWidget(Racer racer, bool isBetCar, int index) {
    final isWinner = raceFinished && winnerId == racer.id;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isWinner) const Text('🏆', style: TextStyle(fontSize: 20)),

        if (isBetCar)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'YOU',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isWinner ? 55 : 45,
          height: isWinner ? 55 : 45,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [racer.color, racer.color.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isBetCar ? Colors.amber : Colors.white54,
              width: isBetCar ? 3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: racer.color.withOpacity(0.6),
                blurRadius: 12,
                spreadRadius: 2,
              ),
              if (isRacing)
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(-10, 0),
                ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.directions_car,
                color: Colors.white,
                size: isWinner ? 32 : 26,
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboard() {
    final sortedRacers = List.generate(racers.length, (i) => i);
    sortedRacers.sort((a, b) => racerPositions[b].compareTo(racerPositions[a]));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            '📊 BẢNG XẾP HẠNG',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(sortedRacers.length, (rank) {
              final racerIndex = sortedRacers[rank];
              final racer = racers[racerIndex];
              final isBetCar = betInfo?.racer.id == racer.id;
              final progress = (racerPositions[racerIndex] * 100).toInt();

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isBetCar
                        ? Colors.amber.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isBetCar ? Colors.amber : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        rank == 0
                            ? '🥇'
                            : rank == 1
                            ? '🥈'
                            : '🥉',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: racer.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$progress%',
                        style: TextStyle(
                          color: isBetCar ? Colors.amber : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isRacing
                    ? [Colors.green.shade600, Colors.green.shade400]
                    : raceFinished
                    ? [Colors.blue.shade600, Colors.blue.shade400]
                    : [Colors.orange.shade600, Colors.orange.shade400],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color:
                      (isRacing
                              ? Colors.green
                              : raceFinished
                              ? Colors.blue
                              : Colors.orange)
                          .withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isRacing
                      ? Icons.speed
                      : raceFinished
                      ? Icons.flag
                      : Icons.hourglass_empty,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isRacing
                      ? '🔥 ĐANG ĐUA...'
                      : raceFinished
                      ? '🏁 KẾT THÚC!'
                      : '⏳ CHUẨN BỊ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(countdown),
          tween: Tween(begin: 0.3, end: 1.2),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: countdown > 1
                        ? [Colors.orange, Colors.deepOrange]
                        : [Colors.green, Colors.lightGreen],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (countdown > 1 ? Colors.orange : Colors.green)
                          .withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    countdown > 0 ? '$countdown' : 'GO!',
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultOverlay() {
    if (winnerId == null) return const SizedBox.shrink();

    final winner = racers.firstWhere((r) => r.id == winnerId);
    final isPlayerWin = betInfo?.racer.id == winnerId;

    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon kết quả
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Text(
                    isPlayerWin ? '🎉🏆🎉' : '😢💔😢',
                    style: const TextStyle(fontSize: 60),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Text kết quả
            Text(
              isPlayerWin ? 'CHIẾN THẮNG!' : 'THUA CUỘC!',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: isPlayerWin ? Colors.amber : Colors.red,
                shadows: [
                  Shadow(
                    color: isPlayerWin ? Colors.orange : Colors.red,
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Xe thắng
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: winner.color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: winner.color, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    'Xe thắng: ${winner.name}',
                    style: TextStyle(
                      color: winner.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Tiền thắng/thua
            Text(
              isPlayerWin
                  ? '+${betInfo!.betAmount}\$'
                  : '-${betInfo!.betAmount}\$',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isPlayerWin ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 30),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Nút chơi lại
                ElevatedButton.icon(
                  onPressed: _restartRace,
                  icon: const Icon(Icons.refresh),
                  label: const Text('CHƠI LẠI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Nút về menu
                ElevatedButton.icon(
                  onPressed: _goBack,
                  icon: const Icon(Icons.home),
                  label: const Text('VỀ MENU'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
