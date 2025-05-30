import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          const SizedBox(height: 40), // 상태바 여백
          _buildStatusBar(),
          const SizedBox(height: 10),
          _buildMainBox(),
          const Spacer(),
          _buildBottomNavigationBar(),
          _buildHomeIndicator(),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '9:41',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              Container(
                width: 25,
                height: 13,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(4.3),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 21,
                height: 9,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainBox() {
    return Center(
      child: Container(
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
            const Icon(
              Icons.add_circle,
              color: Color(0xFF00C8B8),
              size: 36, // ✅ 위에 표시될 플러스 아이콘
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '우리 가족만의 보관함을\n만들어 주세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF00C8B8),
                  fontSize: 18, // ✅ 다소 작게 조정
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 100,
              height: 100,
              child: Image.asset("assets/images/temp_logo.png"), // ✅ 중앙 아이콘
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final items = [
      {'icon': Icons.home, 'label': '홈'},
      {'icon': Icons.photo, 'label': '사진첩'},
      {'icon': Icons.add_circle_outline, 'label': '사진 추가'},
      {'icon': Icons.receipt_long, 'label': '보고서'},
      {'icon': Icons.person, 'label': '나의 정보'},
    ];

    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x33555555),
            blurRadius: 10,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: SizedBox(
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item['icon'] as IconData, color: Colors.grey),
                const SizedBox(height: 4),
                Text(
                  item['label'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF555555),
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHomeIndicator() {
    return Container(
      width: 139,
      height: 5,
      margin: const EdgeInsets.only(top: 8, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}
