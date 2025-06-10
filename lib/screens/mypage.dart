import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../user_provider.dart';
import '../widgets/tap_widget.dart';
import '../utils/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '나의 정보',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00C8B8),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 209,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0C000000),
                    blurRadius: 20,
                    offset: const Offset(0, -1),
                  )
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 18,
                    child: Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFFFFC9B3),
                        backgroundImage: userProvider.profileImg != null && userProvider.profileImg!.isNotEmpty
                            ? NetworkImage(userProvider.profileImg!)
                            : null,
                        child: (userProvider.profileImg == null || userProvider.profileImg!.isEmpty)
                            ? const Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 120,
                    child: Center(
                      child: Text(
                        userProvider.name ?? '이름 없음',
                        style: const TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 22,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 159,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF777777),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          userProvider.familyRole ?? '역할 없음',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 329,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x33555555),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '발급된 가족 코드',
                    style: TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 14,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userProvider.familyCode ?? '코드 없음',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '가족 그룹명: ${userProvider.familyName ?? '그룹명 없음'}',
                    style: const TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '회원 정보',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _InfoRow(label: '이름', value: userProvider.name ?? '이름 없음'),
                  _InfoRow(label: '이메일', value: userProvider.email ?? '이메일 없음'),
                  _InfoRow(label: '연락처', value: userProvider.phone ?? '연락처 없음'),
                  _InfoRow(label: '피보호자와의 관계', value: userProvider.familyRole ?? '역할 없음'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  text: '회원 탈퇴',
                  onTap: () async {
                    final userProvider = Provider.of<UserProvider>(context, listen: false);
                    final kakaoId = userProvider.kakaoId;
                    
                    if (kakaoId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('카카오 ID를 찾을 수 없습니다.')),
                      );
                      return;
                    }

                    try {
                      final response = await http.delete(
                        Uri.parse('${dotenv.env['BASE_URL']}/auth/delete_by_kakao_id/$kakaoId'),
                        headers: {
                          'Authorization': 'Bearer ${userProvider.accessToken}',
                          'Accept': 'application/json',
                        },
                      );

                      if (response.statusCode == 200) {
                        // 회원 탈퇴 성공
                        userProvider.clearUser(); // UserProvider 데이터 초기화
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            Routes.signin,
                            (route) => false, // 모든 이전 화면 제거
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('회원 탈퇴에 실패했습니다.')),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('서버와 통신 중 오류가 발생했습니다.')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 15,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 15,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _ActionButton({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFDFF3F2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF00C8B8),
              fontSize: 16,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}