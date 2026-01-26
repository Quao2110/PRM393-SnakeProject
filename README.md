# MINI RACING GAME – FLUTTER UI PROJECT
## SNAKE PROJECT

### 1. Mục tiêu dự án
Dự án giúp vận dụng tổng hợp kiến thức từ **Module 1 đến Module 4** của môn Flutter để xây dựng một mini game mô phỏng đua xe/đua ngựa, tập trung vào:
* **Tư duy Widget-based UI** của Flutter.
* **Quản lý state** và logic game cơ bản.
* **Điều hướng** giữa các màn hình (Navigation).
* **Mô phỏng animation** đơn giản thông qua UI (không dùng game engine).

> **Lưu ý:** Đây là UI Game + Logic Game, không phải game thời gian thực hay sử dụng game engine chuyên dụng.

---

### 2. Cấu trúc thư mục dự án
Dự án được tổ chức theo cấu trúc chuẩn để dễ dàng quản lý và làm việc nhóm:

```text
snakeproject/
├── assets/
│   ├── images/          # Chứa ảnh xe, ngựa, background
│   └── audios/          # Chứa nhạc nền, hiệu ứng (Bonus)
├── lib/
│   ├── core/            # Hằng số và cấu hình chung
│   ├── models/
│   │   └── racer_model.dart  # Class Racer (tên, ảnh, tiền cược)
│   ├── screens/
│   │   ├── menu_screen.dart    # Màn hình chính
│   │   ├── intro_screen.dart   # Màn hình giới thiệu
│   │   ├── lobby_screen.dart   # Màn hình Start Game (chuẩn bị)
│   │   ├── betting_screen.dart # Màn hình đặt cược
│   │   ├── race_screen.dart    # Màn hình đua (Logic chính)
│   │   └── result_screen.dart  # Màn hình kết quả
│   ├── widgets/
│   │   └── custom_button.dart  # Các UI component tái sử dụng
│   └── main.dart               # Cấu hình Route và điểm khởi chạy app
