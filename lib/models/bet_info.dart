import 'racer.dart';

class BetInfo {
  final Racer racer; // Con xe được chọn
  final int betAmount; // Số tiền cược

  BetInfo({required this.racer, required this.betAmount});

  static BetInfo get dummyBet => BetInfo(
    racer: Racer.dummyRacers[0], // Giả vờ cược vào con xe đầu tiên
    betAmount: 50, // Giả vờ cược 50 xu
  );
}
