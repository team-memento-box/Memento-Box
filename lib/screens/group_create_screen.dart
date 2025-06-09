import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:convert' show utf8;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../user_provider.dart';
import '../widgets/family_dropdown.dart';

class GroupCreateScreen extends StatefulWidget {
  const GroupCreateScreen({super.key});

  @override
  State<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final TextEditingController codeInputController = TextEditingController();
  final TextEditingController familyNameController = TextEditingController();
  String? familyCode;
  String? familyId;
  String? familyName;
  String? error;
  bool showRelationDropdown = false;
  bool isCreating = true; // true: 생성 모드, false: 가입 모드

  Future<void> _generateCode() async {
    if (isCreating && familyNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('가족 그룹명을 입력해주세요')),
      );
      return;
    }

    final baseUrl = dotenv.env['BASE_URL']!;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/family/create'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'family_name': familyNameController.text.trim(),
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          familyCode = data['family_code'];
          familyId = data['family_id'];
          familyName = data['family_name'];
          showRelationDropdown = true;
        });
        Provider.of<UserProvider>(context, listen: false).setFamilyCreate(
          familyId: data['family_id'],
          familyCode: data['family_code'],
          familyName: data['family_name'],
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('가족 코드 발급 실패: \n${utf8.decode(response.bodyBytes)}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
    }
  }

  Future<void> _joinFamily() async {
    final code = codeInputController.text.trim();
    final baseUrl = dotenv.env['BASE_URL']!;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/join/family'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'family_code': code}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          familyId = data['family_id'];
          familyCode = data['family_code'];
          familyName = data['family_name'];  // 그룹명도 저장
          showRelationDropdown = true;
        });
        Provider.of<UserProvider>(context, listen: false).setFamilyJoin(
          familyId: data['family_id'],
          familyCode: data['family_code'],
          familyName: data['family_name'],  // Provider에도 저장
        );
        error = null;
      } else {
        setState(() {
          error = '가족 코드가 올바르지 않습니다.';
          showRelationDropdown = false;
        });
      }
    } catch (e) {
      setState(() {
        error = '네트워크 오류: $e';
        showRelationDropdown = false;
      });
    }
  }

  Future<void> _onRelationSelected(String? value) async {
    if (value != null && value.isNotEmpty) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setFamilyInfo(familyRole: value);

      final userData = {
        'kakao_id': userProvider.kakaoId,
        'username': userProvider.username,
        'profile_img': userProvider.profileImg,
        'gender': userProvider.gender,
        'birthday': userProvider.birthday,
        'email': userProvider.email,
        'phone_number': userProvider.phone_number,
        'family_id': userProvider.familyId,
        'family_code': userProvider.familyCode,
        'family_role': userProvider.familyRole,
        'family_name': userProvider.familyName,
        'created_at': userProvider.createdAt,
        'is_guardian': userProvider.isGuardian,
      };

      try {
        final baseUrl = dotenv.env['BASE_URL']!;
        final response = await http.post(
          Uri.parse('$baseUrl/auth/register_user'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(userData),
        );
        if (response.statusCode == 200) {
          Navigator.pushNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원정보 저장 실패: \n${utf8.decode(response.bodyBytes)}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('네트워크 오류: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // 상단 타이틀
                Text(
                  isCreating ? '가족 그룹 생성하기' : '가족 그룹 가입하기',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isCreating 
                    ? '가족 그룹을 생성하고 코드를 발급받으세요.'
                    : '가족 그룹 코드를 입력하여 가입하세요.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 32),
                
                // 모드 전환 버튼
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildModeButton('생성하기', isCreating),
                        _buildModeButton('가입하기', !isCreating),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 생성/가입 컨텐츠
                if (isCreating) ...[
                  if (familyCode == null) ...[
                    TextField(
                      controller: familyNameController,
                      decoration: InputDecoration(
                        hintText: '가족 그룹명을 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _generateCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C8B8),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '가족 코드 발급받기',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    _buildCodeDisplay(),
                  ],
                ] else ...[
                  TextField(
                    controller: codeInputController,
                    decoration: InputDecoration(
                      hintText: '가족 코드를 입력하세요',
                      errorText: error,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _joinFamily,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C8B8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '가족 코드 확인',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ),
                  ),
                ],

                if (showRelationDropdown) ...[
                  const SizedBox(height: 32),
                  const Text(
                    '가족 관계를 선택해주세요',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FamilyRelationDropdown(
                    onChanged: _onRelationSelected,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isCreating = text == '생성하기';
          familyCode = null;
          familyId = null;
          showRelationDropdown = false;
          error = null;
          codeInputController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00C8B8) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Pretendard',
          ),
        ),
      ),
    );
  }

  Widget _buildCodeDisplay() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            '발급된 가족 코드',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            familyCode ?? '',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Pretendard',
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '가족 그룹명: ${familyName ?? ''}',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Pretendard',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '이 코드를 가족 구성원들과 공유해주세요.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }
}