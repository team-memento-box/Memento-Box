// 작성자: gwona
// 작성일: 2025.06.05
// 목적: 피보호자 가족 코드 입력 화면 리팩토링

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../user_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/routes.dart';
class FamilyCodeInputScreen extends StatefulWidget {
  const FamilyCodeInputScreen({super.key});

  @override
  State<FamilyCodeInputScreen> createState() => _FamilyCodeInputScreenState();
}

class _FamilyCodeInputScreenState extends State<FamilyCodeInputScreen> {
  final TextEditingController codeController = TextEditingController();

  bool get isCodeEntered => codeController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    codeController.addListener(() => setState(() {}));
  }

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
    print('🔑 [Token Request] status: ${response.statusCode}');
    print('🔑 [Token Request] body: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('🔑 [Token Request] access_token: ${data['access_token']}');
      return data['access_token'];
    } else {
      print('❌ [Token Request] Failed to get token');
      return null;
    }
  }



  Future<void> _submitFamilyCode() async {
    final code = codeController.text.trim();
    final baseUrl = dotenv.env['BASE_URL']!;
    
    try {
      // 1. 가족 코드 유효성 확인
      final checkResponse = await http.post(
        Uri.parse('$baseUrl/family/join'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'family_code': code}),
      );

      if (checkResponse.statusCode == 200) {
        final familyData = jsonDecode(utf8.decode(checkResponse.bodyBytes));
        
        // 2. 가족 정보를 Provider에 저장
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setFamilyJoin(
          familyId: familyData['family_id'],
          familyCode: familyData['family_code'],
          familyName: familyData['family_name'],
        );

        // 3. 성별에 따른 역할 설정
        String? gender = userProvider.gender;
        String familyRole = '';
        if (gender == 'male') {
          familyRole = '아빠';
        } else if (gender == 'female') {
          familyRole = '엄마';
        } else {
          familyRole = '가족';
        }
        userProvider.setFamilyInfo(familyRole: familyRole);

        // 4. 사용자 정보 저장
        final userData = {
          'kakao_id': userProvider.kakaoId,
          'name': userProvider.name,
          'profile_img': userProvider.profileImg,
          'gender': userProvider.gender,
          'birthday': userProvider.birthday,
          'email': userProvider.email,
          'phoner': userProvider.phone,
          'family_id': familyData['family_id'],
          'family_code': familyData['family_code'],
          'family_name': familyData['family_name'],
          'family_role': familyRole,
          'created_at': userProvider.createdAt,
          'is_guardian': userProvider.isGuardian,
        };

        final registerResponse = await http.post(
          Uri.parse('$baseUrl/auth/register_user'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(userData),
        );

        if (registerResponse.statusCode == 200) {

          // ✅ accessToken 발급 및 저장
          final kakaoId = userProvider.kakaoId ?? '';
          final accessToken = await _fetchAccessToken(kakaoId);
          if (accessToken != null) {
            userProvider.setAccessToken(accessToken);
          }
          
          Navigator.pushNamed(context, Routes.home);
          
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원정보 저장 실패: \n${utf8.decode(registerResponse.bodyBytes)}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('유효하지 않은 가족 코드입니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
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
            _buildLogo(),
            _buildTextSection(),
            _buildInputField(),
            _buildSubmitButton(),
            _buildHomeIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
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

  Widget _buildTextSection() {
    return const Positioned(
      top: 269,
      left: 30,
      right: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안녕하세요 피보호자님,',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w500,
              fontFamily: 'Pretendard',
            ),
          ),
          SizedBox(height: 16),
          Text(
            '보호자님께 전달 받은 가족 코드를 입력해주세요.',
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

  Widget _buildInputField() {
    return Positioned(
      top: 406,
      left: 30,
      right: 30,
      child: TextField(
        controller: codeController,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Pretendard',
        ),
        decoration: InputDecoration(
          hintText: '가족 코드를 입력해주세요',
          hintStyle: const TextStyle(
            fontSize: 18,
            color: Color(0xFF888888),
            fontFamily: 'Pretendard',
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          filled: true,
          fillColor: Color(0xFFF4F4F4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFAEAEAE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFAEAEAE)),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Positioned(
      top: 482,
      left: 30,
      right: 30,
      child: GestureDetector(
        onTap: isCodeEntered
            ? _submitFamilyCode
            : null,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isCodeEntered
                ? const Color(0xFF00C8B8)
                : const Color(0xFFDFF3F2),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            '가족 코드 입력',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeIndicator() {
    return const Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: 139,
          height: 5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),
          ),
        ),
      ),
    );
  }
}
