// 작성자: gwona
// 작성일: 2025.05.30
// 수정자: OH
// 수정일: 2025.06.02

import 'package:flutter/material.dart';
import '../widgets/tap_widget.dart'; // OH 추가

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(children: [const SizedBox(height: 10), _buildMainBox()]),
      // bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  // Widget _buildStatusBar() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         const Text(
  //           '9:41',
  //           style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
  //         ),
  //         Row(
  //           children: [
  //             Container(
  //               width: 25,
  //               height: 13,
  //               decoration: BoxDecoration(
  //                 border: Border.all(color: Colors.black, width: 1),
  //                 borderRadius: BorderRadius.circular(4.3),
  //               ),
  //             ),
  //             const SizedBox(width: 4),
  //             Container(
  //               width: 21,
  //               height: 9,
  //               decoration: BoxDecoration(
  //                 color: Colors.black,
  //                 borderRadius: BorderRadius.circular(2.5),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildMainBox() {
    return Container(
      width: 315,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: const Color(0x1900C8B8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00C8B8), width: 3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add_circle, color: Color(0xFF00C8B8), size: 36),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '우리 가족만의 보관함을\n만들어 주세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF00C8B8),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 100,
            height: 100,
            child: Image.asset("assets/images/temp_logo.png"),
          ),
        ],
      ),
    );
  }
}

// 하단 네비게이션 아이템 모델
class BottomNavItem {
  final String label;
  final IconData icon;

  BottomNavItem({required this.label, required this.icon});
}
