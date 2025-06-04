import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data/user_data.dart'; // userType enum 정의 위치

class KakaoSigninScreen extends StatelessWidget {
  const KakaoSigninScreen({super.key});

  Future<void> _launchKakaoLogin(BuildContext context) async {
    final clientId = dotenv.env['KAKAO_CLIENT_ID'];
    final redirectUri = dotenv.env['KAKAO_REDIRECT_URI'];

    final Uri url = Uri.parse(
      "https://kauth.kakao.com/oauth/authorize"
      "?client_id=$clientId"
      "&redirect_uri=$redirectUri"
      "&response_type=code",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);

      // ✅ 로그인 후 redirect 된 것으로 간주하고, selectedRole 기준 분기
      if (selectedRole == FamilyRole.guardian) {
        Navigator.pushNamed(context, '/intro'); // 보호자 → 인트로 화면
      } else {
        Navigator.pushNamed(context, '/addphoto-request'); // 피보호자 → 사진요청
      }
    } else {
      throw 'URL을 열 수 없습니다: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            _buildStatusBar(),
            _buildProfileImage(),
            _buildWelcomeText(),
            _buildButtons(context),
            _buildHomeIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      ),
    );
  }

  Widget _buildProfileImage() {
    return Positioned(
      top: 153,
      left: 30,
      child: SizedBox(
        width: 88,
        height: 88,
        child: Image.asset("assets/images/temp_logo.png", fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Positioned(
      top: 269,
      left: 30,
      right: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '보호자/피보호자님,',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w500,
              fontFamily: 'Pretendard',
            ),
          ),
          SizedBox(height: 16),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '소중한 '),
                TextSpan(
                  text: '우리 가족의 추억 기록',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: '을 위해 간편 가입으로 '),
                TextSpan(
                  text: '메멘토 박스',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: '를 시작하세요.'),
              ],
            ),
            style: TextStyle(
              fontSize: 19,
              fontFamily: 'Pretendard',
              height: 1.5,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Positioned(
      top: 459,
      left: 30,
      right: 30,
      child: Column(
        children: [
          _buildLoginButton(
            '카카오로 계속하기',
            const Color(0xFFF9E007),
            Colors.black,
            onTap: () => _launchKakaoLogin(context),
          ),
          const SizedBox(height: 15),
          _buildLoginButton('네이버로 계속하기', const Color(0xFF57B04B), Colors.white),
          const SizedBox(height: 15),
          _buildLoginButton(
            '구글로 계속하기',
            Colors.white,
            const Color(0xFF111111),
            border: const BorderSide(color: Color(0xFFAEAEAE), width: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(
    String text,
    Color bgColor,
    Color textColor, {
    BorderSide? border,
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
          border: border != null ? Border.fromBorderSide(border) : null,
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

  Widget _buildHomeIndicator() {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 139,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}
