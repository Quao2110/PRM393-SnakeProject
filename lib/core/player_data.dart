class PlayerData {
  static int totalMoney = 100; // Mặc định ban đầu có 100 xu

  // 1. Hàm cộng tiền (Dùng khi Thắng)
  static void addMoney(int amount) {
    totalMoney += amount;
  }

  // 2. Hàm trừ tiền (Dùng khi Thua)
  static void subtractMoney(int amount) {
    totalMoney -= amount;
  }

  // Dùng khi người chơi hết tiền hoặc muốn chơi lại từ đầu
  static void resetData() {
    totalMoney = 100; // Trả về mức mặc định
  }
}