import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../user_provider.dart';
import '../utils/routes.dart';

class KakaoSigninScreen extends StatefulWidget {
  const KakaoSigninScreen({super.key});

  @override
  State<KakaoSigninScreen> createState() => _KakaoSigninScreenState();
}

class _KakaoSigninScreenState extends State<KakaoSigninScreen> {
  bool isAgreed = false;

  Future<String?> _fetchAccessToken(String kakaoId) async {
    final baseUrl = dotenv.env['BASE_URL']!;
    final url = Uri.parse('$baseUrl/auth/token');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'username=$kakaoId&password=test1234&grant_type=password',
    );
    print('🔑 [Token Request] status: \\${response.statusCode}');
    print('🔑 [Token Request] body: \\${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('🔑 [Token Request] access_token: \\${data['access_token']}');
      return data['access_token'];
    } else {
      print('❌ [Token Request] Failed to get token');
      return null;
    }
  }

  // 개인정보 동의 팝업을 보여주는 함수
  void _showPrivacyAgreementDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '개인정보 수집 및 이용 동의',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
          content: const SingleChildScrollView(
            child: Text(
              '메멘토박스는 서비스 제공을 위해 다음과 같은 개인정보를 수집 및 이용합니다.\n\n'
              '수집 항목: 카카오 계정 정보(이메일, 프로필 이미지), 이름, 생년월일, 성별, 전화번호\n\n'
              '수집 목적: 회원 식별 및 관리, 개인 맞춤형 서비스 제공, 본인 확인 절차 진행\n\n'
              '보유 및 이용 기간: 서비스 이용 기간 동안 보관하며, 회원 탈퇴 시 즉시 파기됩니다.\n\n'
              '※ 귀하는 위 개인정보 수집 및 이용에 동의하지 않을 권리가 있으나, 동의하지 않을 경우 서비스 이용이 제한될 수 있습니다.',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Pretendard',
                height: 1.5,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                '취소',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  isAgreed = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C8B8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                '동의합니다',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _kakaoLoginAndSendToBackend(BuildContext context) async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token;
      if (isInstalled) {
        token = await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공: \\${token.accessToken}');
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공: \\${token.accessToken}');
      }

      final baseUrl = dotenv.env['BASE_URL']!;
      print('BASE_URL from env: $baseUrl');
      print('Sending request to: $baseUrl/auth/kakao_login');
      print('Access token: \\${token.accessToken}');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/kakao_login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'access_token': token.accessToken}),
      );

      print('Response status: \\${response.statusCode}');
      print('Response body: \\${response.body}');

      if (response.statusCode == 200) {
        final userInfo = jsonDecode(utf8.decode(response.bodyBytes));
        print('백엔드 응답 데이터: \\${userInfo}');
        
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUserInfo(
          kakaoId: userInfo['kakao_id'].toString(),
          name: userInfo['name'].toString(),
          profileImg: userInfo['profile_img'].toString(),
          gender: userInfo['gender'].toString(),
          birthday: userInfo['birthday'].toString(),
          email: userInfo['email'].toString(),
          phone: userInfo['phone'].toString(),
        );

        if (userInfo['is_registered'] == true) {
          userProvider.setFamilyJoin(
            familyId: userInfo['family_id'],
            familyCode: userInfo['family_code'],
            familyName: userInfo['family_name'],
          );
          userProvider.setFamilyInfo(
            familyRole: userInfo['family_role'],
          );
          
          final kakaoId = userProvider.kakaoId ?? '';
          final accessToken = await _fetchAccessToken(kakaoId);
          if (accessToken != null) {
            userProvider.setAccessToken(accessToken);
          }
          Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
        } else {
          if (userProvider.isGuardian == true) {
            Navigator.pushNamed(context, Routes.groupSelect);
          } else if (userProvider.isGuardian == false) {
            Navigator.pushNamed(context, Routes.familyCodeInput);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('역할 정보가 없습니다. 처음 화면으로 돌아갑니다.')),
            );
            Navigator.pushNamedAndRemoveUntil(context, Routes.signin, (route) => false);
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 오류: \\${response.body}')),
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
            Positioned(
              top: 400,
              left: 30,
              right: 30,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!isAgreed) {
                        _showPrivacyAgreementDialog();
                      } else {
                        _kakaoLoginAndSendToBackend(context);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isAgreed ? const Color(0xFF00C8B8) : const Color(0xFFF9E007),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isAgreed ? '로그인' : '카카오로 계속하기',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Pretendard',
                          color: isAgreed ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return const Positioned(
      top: 300,
      left: 30,
      right: 30,
      child: Text(
        '소중한 우리 가족의 추억 기록을 위해\n카카오로 간편하게 로그인하세요.',
        style: TextStyle(fontSize: 18, fontFamily: 'Pretendard'),
        textAlign: TextAlign.center,
      ),
    );
  }
}