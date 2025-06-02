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
          Expanded(child: Center(child: _buildMainBox())),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 0,
      ), // 홈 탭으로 설정
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
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              fontFamily: 'SF Pro',
            ),
          ),
          _buildBatteryIcon(),
        ],
      ),
    );
  }

  Widget _buildBatteryIcon() {
    return SizedBox(
      width: 25,
      height: 13,
      child: Stack(
        children: [
          Opacity(
            opacity: 0.35,
            child: Container(
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Colors.black),
                  borderRadius: BorderRadius.circular(4.30),
                ),
              ),
            ),
          ),
          Positioned(
            left: 2,
            top: 2,
            child: Container(
              width: 21,
              height: 9,
              decoration: ShapeDecoration(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

// 커스텀 하단 네비게이션 바 위젯 (다른 화면들과 동일)
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({Key? key, required this.currentIndex})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<BottomNavItem> navItems = [
      BottomNavItem(label: '홈', icon: Icons.home),
      BottomNavItem(label: '사진첩', icon: Icons.photo_library),
      BottomNavItem(label: '사진 추가', icon: Icons.add_a_photo),
      BottomNavItem(label: '보고서', icon: Icons.description),
      BottomNavItem(label: '나의 정보', icon: Icons.person),
    ];

    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0x7F999999), width: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33555555),
            blurRadius: 10,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: navItems.asMap().entries.map((entry) {
          int index = entry.key;
          BottomNavItem item = entry.value;
          bool isSelected = index == currentIndex;

          return _buildNavItem(context, item, isSelected, index);
        }).toList(),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    BottomNavItem item,
    bool isSelected,
    int index,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // 네비게이션 로직
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/gallery');
              break;
            case 2:
              Navigator.pushNamed(context, '/addphoto');
              break;
            case 3:
              Navigator.pushNamed(context, '/report');
              break;
            case 4:
              // 나의 정보 페이지 (라우트 추가 필요)
              break;
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 30,
              color: isSelected
                  ? const Color(0xFF00C8B8)
                  : const Color(0xFF555555),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF00C8B8)
                    : const Color(0xFF555555),
                fontSize: 12,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
