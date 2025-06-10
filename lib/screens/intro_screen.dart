import 'package:flutter/material.dart';
import 'add_photo_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildMainBox(context),
            ),
          ),
        ],
      ),
    );
  }



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
}
