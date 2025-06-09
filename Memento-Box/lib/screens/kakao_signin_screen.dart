import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KakaoSigninScreen extends StatelessWidget {
  const KakaoSigninScreen({super.key});

  Future<void> _kakaoLoginAndSendToBackend(BuildContext context) async {
    try {
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      final baseUrl = dotenv.env['BASE_URL']!;
      final response = await http.post(
        Uri.parse('$baseUrl/kakao_login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'access_token': token.accessToken}),
      );

      if (response.statusCode == 200) {
        final userInfo = jsonDecode(response.body);
        Navigator.pushNamed(context, '/intro', arguments: userInfo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카카오 로그인 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            _buildWelcomeText(),
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return const Positioned(
      top: 100,
      left: 30,
      right: 30,
      child: Text(
        '소중한 우리 가족의 추억 기록을 위해\n카카오로 간편하게 로그인하세요.',
        style: TextStyle(fontSize: 18, fontFamily: 'Pretendard'),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Positioned(
      top: 200,
      left: 30,
      right: 30,
      child: Column(
        children: [
          _buildLoginButton(
            '카카오로 계속하기',
            const Color(0xFFF9E007),
            Colors.black,
            onTap: () => _kakaoLoginAndSendToBackend(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(
    String text,
    Color bgColor,
    Color textColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Pretendard',
            color: textColor,
          ),
        ),
      ),
    );
  }
}