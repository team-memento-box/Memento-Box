import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart'; // ✅ Provider import
import '../user_provider.dart'; // ✅ 사용자 Provider import


class KakaoSigninScreen extends StatelessWidget {
  const KakaoSigninScreen({super.key});

  Future<void> _kakaoLoginAndSendToBackend(BuildContext context) async {
  try {
    bool isInstalled = await isKakaoTalkInstalled();
    OAuthToken token;
    if (isInstalled) {
      token = await UserApi.instance.loginWithKakaoTalk();
      print('카카오톡으로 로그인 성공: ${token.accessToken}');
    } else {
      token = await UserApi.instance.loginWithKakaoAccount();
      print('카카오계정으로 로그인 성공: ${token.accessToken}');
    }

    // 1. 백엔드로 access token 전송
    final baseUrl = dotenv.env['BASE_URL']!;
    print('Sending request to: $baseUrl/kakao_login');
    print('Access token: ${token.accessToken}');

    final response = await http.post(
      Uri.parse('$baseUrl/kakao_login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'access_token': token.accessToken}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final userInfo = jsonDecode(utf8.decode(response.bodyBytes));
      print('백엔드 응답 데이터: $userInfo');
      
      // Provider에 저장
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUserInfo(
        kakaoId: userInfo['kakao_id'].toString(),
        username: userInfo['username'].toString(),
        profileImg: userInfo['profile_img'].toString(),
        gender: userInfo['gender'].toString(),
        birthday: userInfo['birthday'].toString(),
        email: userInfo['email'].toString(),
        phone_number: userInfo['phone_number'].toString(),
      );

      // 이미 가입된 사용자인 경우
      if (userInfo['is_registered'] == true) {
        // 가족 정보도 Provider에 저장
        userProvider.setFamilyJoin(
          familyId: userInfo['family_id'],
          familyCode: userInfo['family_code'],
          familyName: userInfo['family_name'],
        );
        userProvider.setFamilyInfo(
          familyRole: userInfo['family_role'],
        );
        
        // 바로 홈 화면으로 이동
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        // 새로운 사용자인 경우 isGuardian 값에 따라 분기 이동
        if (userProvider.isGuardian == true) {
          Navigator.pushNamed(context, '/0-3-1');
        } else if (userProvider.isGuardian == false) {
          Navigator.pushNamed(context, '/0-3-2');
        } else {
          // 예외: 값이 없는 경우
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('역할 정보가 없습니다. 처음 화면으로 돌아갑니다.')),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('서버 오류: ${response.body}')),
      );
    }
  } catch (e) {
    print('카카오 로그인 실패: $e');
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