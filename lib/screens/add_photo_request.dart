import 'package:flutter/material.dart';
import '../widgets/tap_widget.dart'; // ✅ 하단 탭 위젯 불러오기

class AddPhotoRequestScreen extends StatelessWidget {
  const AddPhotoRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          const SizedBox(height: 40), // 상태바 여백
          _buildStatusBar(),
          const SizedBox(height: 20),
          _buildMainBox(),
          const Spacer(),
          _buildHomeIndicator(),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 2,
      ), // ✅ 탭 적용 위치
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
            SizedBox(
              width: 100,
              height: 100,
              child: Image.asset("assets/images/heart.png"),
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '아직 생성된\n보관함이 없어요.\n\n보호자에게 보관함 만들기를 요청해주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF00C8B8),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Pretendard',
                  height: 1.4,
                ),
              ),
            ),
          ],
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
