import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Provider import
import '../user_provider.dart'; // ✅ 사용자 Provider import
import '../widgets/tap_widget.dart';
class IntroScreen extends StatefulWidget { // ✅ StatefulWidget으로 변경
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState(); // ✅ 상태 생성자 연결
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  void initState() {
    super.initState();
    // Provider 데이터가 이미 저장되어 있으므로 추가 작업 불필요
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    print('IntroScreen - Provider 데이터:');
    print('kakaoId: ${user.kakaoId}');
    print('username: ${user.name}');
    print('profileImg: ${user.profileImg}');
    print('gender: ${user.gender}');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          Text("✅ 카카오ID: ${user.kakaoId}"),
          Text("✅ 이름: ${user.name}"),
          Text("✅ 프로필: ${user.profileImg}"),
          Text("✅ 성별: ${user.gender}"),
          const SizedBox(height: 40),
          _buildStatusBar(),
          const SizedBox(height: 10),
          Expanded(child: Center(child: _buildMainBox())),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
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
