import 'package:flutter/material.dart';
import 'kakao_signin_screen.dart'; //홍원추가
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart'; // ✅ Provider import
import '../user_provider.dart'; // ✅ 사용자 Provider import
import '../utils/routes.dart';

final String apiBaseUrl = dotenv.env['BASE_URL']!;

class StartSelectScreen extends StatelessWidget {
  const StartSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const SizedBox(height: 40),
            SizedBox(
              width: 188,
              height: 188,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/temp_logo.png',
                  width: 188,
                  height: 188,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: '우리 가족의 소중한 ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Pretendard',
                        letterSpacing: -1,
                      ),
                    ),
                    const TextSpan(
                      text: '추억 보관함\n메멘토 박스',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Pretendard',
                        letterSpacing: -1,
                      ),
                    ),
                    const TextSpan(
                      text: '에 이야기를 담아 볼까요?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Pretendard',
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 90),
            ElevatedButton(
              onPressed: () {
                // Provider에 보호자 역할 저장
                Provider.of<UserProvider>(
                  context,
                  listen: false,
                ).setIsGuardian(true);
                Navigator.pushNamed(context, Routes.kakaoSignIn);
              },
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
                  fontFamily: 'Pretendard',
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                // Provider에 피보호자 역할 저장
                Provider.of<UserProvider>(
                  context,
                  listen: false,
                ).setIsGuardian(false);
                Navigator.pushNamed(context, Routes.kakaoSignIn);
              },
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
                  fontFamily: 'Pretendard',
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
