import 'package:flutter/material.dart';
import 'kakao_signin_screen.dart'; // 중간 로그인 스크린 경로
import '../data/user_data.dart'; // enum FamilyRole 및 selectedRole 정의된 파일

class StartSelectScreen extends StatelessWidget {
  const StartSelectScreen({super.key});

  void _navigateToLogin(BuildContext context, String familyRole) {
    // ✅ 전역 상태 설정
    selectedRole = familyRole == 'guardian'
        ? FamilyRole.guardian
        : FamilyRole.elderly;

    // ✅ 로그인 화면으로 이동 (familyRole 넘길 필요 없음)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const KakaoSigninScreen(), // 변경: 인자 제거
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("🟢 StartSelectScreen build 실행됨");
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 188,
              height: 188,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/temp_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '우리 가족의 소중한 ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: '추억 보관함\n메멘토 박스',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: '에 이야기를 담아 볼까요?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 90),
            ElevatedButton(
              onPressed: () => _navigateToLogin(context, 'guardian'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C8B8),
                minimumSize: const Size(315, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                '보호자예요',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => _navigateToLogin(context, 'elder'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(width: 2, color: Color(0xFF00C8B8)),
                minimumSize: const Size(315, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                '피보호자예요',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00C8B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
