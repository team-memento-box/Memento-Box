// 0603 고권아 작업
// 사용자 챗봇 화면
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import '../widgets/assistant_bubble.dart'; // 챗봇 말풍선 위젯
import '../widgets/photo_box.dart'; // 고정된 사진 영역 위젯
import '../widgets/user_speech_bubble.dart'; // 사용자 음성 말풍선 위젯
import '../data/user_data.dart'; // 질문/응답/사진 정보가 담긴 데이터 파일
import '../utils/routes.dart';
import '../utils/styles.dart';

Future<String> startConversation(String imageId, String accessToken) async {
  final baseUrl = 'http://YOUR_BASE_URL'; // .env 또는 상수로 관리하세요
  final url = Uri.parse('$baseUrl/api/start');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({'image_id': imageId}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return data['question'] ?? '질문이 없습니다.';
  } else {
    throw Exception('대화 시작 실패: ${response.statusCode}');
  }
}

class PhotoConversationScreen extends StatefulWidget {
  const PhotoConversationScreen({super.key});

  @override
  State<PhotoConversationScreen> createState() =>
      _PhotoConversationScreenState();
}

class _PhotoConversationScreenState extends State<PhotoConversationScreen> {
  // TTS, STT 기능이 동작 중인지 여부를 저장하는 상태 변수
  bool isTTSActive = false;
  bool isSTTActive = false;

  // 대화 관련 변수들: 질문, 응답, 사진 경로
  String assistantText = '';
  String userSpeechText = '';
  String photoPath = '';
  bool isLoading = true; // 로딩 상태 추가

  final String photoId = '받아온_사진_ID'; // 실제 사진 ID로 교체 필요
  final String accessToken = '유저_액세스토큰'; // Provider 또는 다른 방식으로 받아오세요

  @override
  void initState() {
    super.initState();
    _initConversation();

    // // 예시: 첫 번째 회상 대화 데이터를 불러옴
    // final convo = photoConversations[0];

    // assistantText = convo.assistantText;
    // userSpeechText = convo.userSpeechText;
    // photoPath = convo.photoPath;
  }

  Future<void> _initConversation() async {
    try {
      // API 호출해서 질문 받아오기
      final question = await startConversation(photoId, accessToken);

      setState(() {
        assistantText = question;
        // 기존 더미 userSpeechText, photoPath 등도 같이 초기화 가능
        photoPath = '사진_경로'; // 필요에 따라 세팅
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        assistantText = '대화 시작 중 오류가 발생했습니다.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(114),
        child: Column(
          children: [
            _buildCustomAppBar(context), // 상단 타이틀 바
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 30),

            // 챗봇 질문 말풍선
            AssistantBubble(text: assistantText, isActive: isTTSActive),
            // const SizedBox(height: 30),

            // 사진 영역 (375x375)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: PhotoBox(photoPath: photoPath),
            ),
            // const SizedBox(height: 80),

            // 사용자 음성 응답 말풍선
            UserSpeechBubble(text: userSpeechText, isActive: isSTTActive),
          ],
        ),
      ),
    );
  }

  /// 사용자 정의 상단 타이틀 바
  Widget _buildCustomAppBar(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      height: 80 + statusBarHeight,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 30), // 왼쪽 공백
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '사진 회상 대화 중',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard',
                  ),
                ),
                SizedBox(width: 8),
                Image.asset('assets/icons/Chat.png', color: Color(0xFF333333)),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF333333), size: 30),
              onPressed: () {
                showExitModal();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// TTS 상태 토글 함수 (챗봇 말풍선 강조용)
  void toggleTTS() {
    setState(() {
      isTTSActive = !isTTSActive;
    });
  }

  /// STT 상태 토글 함수 (마이크 아이콘 강조용)
  void toggleSTT() {
    setState(() {
      isSTTActive = !isSTTActive;
    });
  }

  void showExitModal() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: const Color.fromARGB(230, 255, 255, 255),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '정말로 지금 대화를 종료하시겠어요?',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 20,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity, // 너비만 확장하고 싶을 때
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C8B8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    '대화 계속하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity, // 너비만 확장하고 싶을 때
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, Routes.gallery);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: const Color(0xFF00C8B8),
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    '대화 끝내기',
                    style: TextStyle(
                      color: Color(0xFF00C8B8),
                      fontSize: 22,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
