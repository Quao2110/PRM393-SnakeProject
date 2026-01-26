MINI RACING GAME – FLUTTER UI PROJECT

SNAKE PROJECT

Mục tiêu dự án
Dự án nhằm giúp sinh viên vận dụng tổng hợp kiến thức từ Module 1 đến Module 4 của môn Flutter để xây dựng một mini game mô phỏng đua xe/đua ngựa, tập trung vào:
•	Tư duy Widget-based UI của Flutter
•	Quản lý state và logic game cơ bản
•	Điều hướng giữa các màn hình (Navigation)
•	Mô phỏng animation đơn giản thông qua UI (không dùng game engine)
Đây là UI Game + Logic Game, không phải game thời gian thực hay game engine.


cấu trúc dự án 
snakeproject/
├── assets/
│   ├── images/         # Chứa ảnh xe, ngựa, background
│   └── audios/         # Chứa nhạc nền, hiệu ứng (nếu có làm bonus)
lib/
├── models/
│   └── racer_model.dart      # Chứa class Racer (tên, ảnh, tiền cược)
├── screens/
│   ├── menu_screen.dart      # Màn hình chính
│   ├── intro_screen.dart     # Màn hình giới thiệu
│   ├── lobby_screen.dart     # Màn hình Start Game (chuẩn bị)
│   ├── betting_screen.dart   # Màn hình đặt cược
│   ├── race_screen.dart      # Màn hình đua (Logic chính ở đây)
│   └── result_screen.dart    # Màn hình kết quả
├── widgets/
│   └── custom_button.dart    # Tái sử dụng các nút bấm
└── main.dart                 # Cấu hình Route (tuyến đường)


- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
