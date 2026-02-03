import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/racer.dart';
import '../models/bet_info.dart';
import '../core/player_data.dart';
import '../core/audio_manager.dart';

class BettingScreen extends StatefulWidget {
  const BettingScreen({super.key});

  @override
  State<BettingScreen> createState() => _BettingScreenState();
}

class _BettingScreenState extends State<BettingScreen> {
  final TextEditingController _betController = TextEditingController();
  Racer? _selectedRacer;
  String _errorMessage = '';

  final List<Racer> _racers = Racer.dummyRacers;

  @override
  void dispose() {
    _betController.dispose();
    super.dispose();
  }

  String? _validateBetAmount(String value) {
    if (value.isEmpty) {
      return 'Vui lòng nhập số tiền cược';
    }

    // Kiểm tra có phải số không
    final betAmount = int.tryParse(value);
    if (betAmount == null) {
      return 'Vui lòng chỉ nhập số';
    }

    // Kiểm tra số âm
    if (betAmount <= 0) {
      return 'Số tiền phải lớn hơn 0';
    }

    // Kiểm tra không vượt quá số tiền hiện có
    if (betAmount > PlayerData.totalMoney) {
      return 'Không đủ tiền! Bạn chỉ có \$${PlayerData.totalMoney}';
    }

    return null;
  }

  void _handlePlaceBet() {
    setState(() {
      _errorMessage = '';
    });

    if (_selectedRacer == null) {
      setState(() {
        _errorMessage = 'Vui lòng chọn một xe!';
      });
      return;
    }

    final validationError = _validateBetAmount(_betController.text);
    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      return;
    }

    final betAmount = int.parse(_betController.text);
    final betInfo = BetInfo(
      racer: _selectedRacer!,
      betAmount: betAmount,
    );

    Navigator.pushNamed(
      context,
      '/race',
      arguments: betInfo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5DC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(height: 16),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🐍', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 8),
                          Text(
                            'CHỌN RẮN VÀ ĐẶT CƯỢC',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF5722),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16),
                      
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Chọn rắn của bạn:',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 12),

                      ..._racers.map((racer) => _buildRacerCard(racer)),

                      SizedBox(height: 20),

                      _buildBettingInput(),

                      if (_errorMessage.isNotEmpty) ...[
                        SizedBox(height: 8),
                        _buildErrorMessage(),
                      ],

                      SizedBox(height: 20),

                      _buildBetButton(),
                    ],
                  ),
              ),
            ),
            ],
          ),
      ),
    );
  }

  Widget _buildQuickBetButton(String label, int amount) {
    return Expanded(
      child: SizedBox(
        height: 42,
        child: OutlinedButton(
          onPressed: () {
            // Play sound
            AudioManager.playSFX('click.mp3');
            setState(() {
              _betController.text = amount.toString();
              _errorMessage = '';
            });
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Color(0xFFFFE4B5),
            side: BorderSide(color: Color(0xFFFFD700), width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Color(0xFFFF5722),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF2C3E50),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.amber,
            backgroundImage: PlayerData.userAvatar.isNotEmpty
                ? AssetImage(PlayerData.userAvatar)
                : null,
            child: PlayerData.userAvatar.isEmpty
                ? const Text('😊', style: TextStyle(fontSize: 28))
                : null,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                PlayerData.userName.isNotEmpty
                    ? PlayerData.userName
                    : 'Người chơi',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '💵',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '\$${PlayerData.totalMoney}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBettingInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Số tiền cược:',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _betController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            hintText: '1000',
            hintStyle: TextStyle(color: Colors.grey),
            prefixText: '\$    ',
            prefixStyle: TextStyle(
              color: Colors.grey,
              fontSize: 18,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFFF5722), width: 2),
            ),
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Cược nhanh:',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            _buildQuickBetButton('\$10', 10),
            SizedBox(width: 8),
            _buildQuickBetButton('\$25', 25),
            SizedBox(width: 8),
            _buildQuickBetButton('\$50', 50),
            SizedBox(width: 8),
            _buildQuickBetButton('Tất cả', PlayerData.totalMoney),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: EdgeInsets.only(left: 12),
      child: Text(
        _errorMessage,
        style: TextStyle(
          color: Colors.red,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildBetButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          AudioManager.playSFX('click.mp3');
          _handlePlaceBet();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF5722),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              'BẮT ĐẦU ĐUA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSnakeImage(String id) {
    switch (id) {
      case '1':
        return 'assets/images/snake_red.jpg';
      case '2':
        return 'assets/images/snake_blue.jpg';
      case '3':
        return 'assets/images/snake_green.jpg';
      default:
        return 'assets/images/snake_red.jpg';
    }
  }

  Widget _buildRacerCard(Racer racer) {
    final isSelected = _selectedRacer?.id == racer.id;

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          // Play sound
          AudioManager.playSFX('click.mp3');
          setState(() {
            _selectedRacer = racer;
            _errorMessage = '';
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFFFFF9E6) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Color(0xFFFFD700) : Colors.grey.shade300,
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: racer.color, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    _getSnakeImage(racer.id),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        // ignore: deprecated_member_use
                        color: racer.color.withOpacity(0.2),
                        child: Icon(Icons.image_not_supported, color: racer.color),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      racer.name,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Số ${racer.id}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}