import 'package:flutter/material.dart';

class AppConstants {
  // 1. CẤU HÌNH GAME (Luật chơi)
  static const int defaultBalance = 100; // Tiền mặc định ban đầu
  static const int minBet = 10; // Cược tối thiểu
  static const int maxBet = 1000; // Cược tối đa
  static const int raceDuration = 30; // Thời gian đua trung bình (giây)

  // 2. MÀU SẮC CHỦ ĐẠO (Theme)
  static const Color primaryColor = Color(0xFFE65100); // Cam đậm (Màu nút bấm)
  static const Color secondaryColor = Color(0xFF1565C0); // Xanh dương (Màu phụ)
  static const Color backgroundGame = Color(0xFF212121); // Màu nền tối cho ngầu

  // 3. TEXT STYLES (Font chữ dùng chung)
  static const TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle normalText = TextStyle(
    fontSize: 16,
    color: Colors.white70,
  );

  // 4. AVATAR PATHS (Danh sách avatar để chọn)
  static const List<String> avatarPaths = [
    'assets/images/avatar_animal_1.png',
    'assets/images/avatar_animal_2.png',
    'assets/images/avatar_animal_3.png',
    'assets/images/avatar_animal_4.png',
  ];
}
