import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/player_data.dart';
import '../widgets/custom_button.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedAvatar;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _nameController.text.trim().isNotEmpty && _selectedAvatar != null;

  void _onContinue() {
    if (_formKey.currentState!.validate() && _selectedAvatar != null) {
      PlayerData.setUserName(_nameController.text.trim());
      PlayerData.setUserAvatar(_selectedAvatar!);
      Navigator.pushNamed(context, '/betting');
    } else if (_selectedAvatar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một avatar!'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy chiều rộng màn hình để tính toán kích thước item
    final screenWidth = MediaQuery.of(context).size.width;
    // Tính toán để hiển thị khoảng 2.5 items trên màn hình (để người dùng biết là có thể vuốt)
    final itemWidth = (screenWidth - 48 - 32) / 2.5;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppConstants.backgroundGame,
              image: DecorationImage(
                image: AssetImage('assets/images/bg_menu.jpg'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'CHỌN NHÂN VẬT',
                      style: AppConstants.titleStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Tên của bạn:',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Nhập tên...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.person, color: Colors.white70),
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập tên!' : null,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Chọn Avatar (Vuốt ngang):',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),

                    // KHUNG AVATAR ĐÃ ĐƯỢC FIT
                    SizedBox(
                      height: itemWidth, // Chiều cao bằng chiều rộng để tạo hình vuông
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: AppConstants.avatarPaths.length,
                        itemBuilder: (context, index) {
                          final avatarPath = AppConstants.avatarPaths[index];
                          final isSelected = _selectedAvatar == avatarPath;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedAvatar = avatarPath),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: itemWidth,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? AppConstants.primaryColor : Colors.white24,
                                  width: isSelected ? 4 : 2,
                                ),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: AppConstants.primaryColor.withOpacity(0.4), blurRadius: 10, spreadRadius: 1)]
                                    : null,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset(avatarPath, fit: BoxFit.cover),
                                    if (isSelected)
                                      Container(
                                        color: Colors.black38,
                                        child: const Icon(Icons.check_circle, color: Colors.white, size: 40),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 40),
                    GameButton(
                      text: 'TIẾP TỤC',
                      onPressed: _onContinue,
                      isEnabled: _isFormValid,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}