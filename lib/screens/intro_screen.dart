import 'package:flutter/material.dart';
import '../widgets/tap_widget.dart'; // OH 추가
import 'add_photo_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          _buildStatusBar(),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildMainBox(context),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '9:41',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              // 신호 아이콘
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 2),
              Container(
                width: 4,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 2),
              Container(
                width: 4,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 2),
              Container(
                width: 4,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              // WiFi 아이콘
              const Icon(Icons.wifi, size: 18, color: Colors.black),
              const SizedBox(width: 8),
              // 배터리 아이콘
              Container(
                width: 25,
                height: 13,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(4.3),
                ),
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Positioned(
                      right: -2,
                      top: 4,
                      child: Container(
                        width: 2,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD

  Widget _buildMainBox(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddPhotoScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(vertical: 60),
        decoration: BoxDecoration(
          color: const Color(0x1900C8B8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00C8B8), width: 3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle, color: Color(0xFF00C8B8), size: 48),
            const SizedBox(height: 40),
            const Text(
              '우리 가족만의 보관함을\n만들어 주세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF00C8B8),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Pretendard',
                height: 1.4,
              ),
            ),
            const SizedBox(height: 60),
            // 보관함 아이콘
            SizedBox(
              width: 120,
              height: 120,
              child: Image.asset("assets/images/temp_logo.png"),
            ),
          ],
        ),
      ),
    );
  }
=======
>>>>>>> b88273e94fa02fdfc78e753fa88bccacb20ce6d0
}
