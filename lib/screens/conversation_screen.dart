// 0603 고권아 작업
// 사용자 챗봇 화면

import 'package:flutter/material.dart';
import '../widgets/assistant_bubble.dart'; // 챗봇 말풍선 위젯
import '../widgets/photo_box.dart'; // 고정된 사진 영역 위젯
import '../widgets/user_speech_bubble.dart'; // 사용자 음성 말풍선 위젯
import '../data/user_data.dart'; // 질문/응답/사진 정보가 담긴 데이터 파일
import '../utils/routes.dart';

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

  @override
  void initState() {
    super.initState();

    // 예시: 첫 번째 회상 대화 데이터를 불러옴
    final convo = photoConversations[0];

    assistantText = convo.assistantText;
    userSpeechText = convo.userSpeechText;
    photoPath = convo.photoPath;
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
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              // 챗봇 질문 말풍선
              AssistantBubble(text: assistantText, isActive: isTTSActive),
              const SizedBox(height: 30),

              // 사진 영역 (375x375)
              PhotoBox(photoPath: photoPath),
              const SizedBox(height: 80),

              // 사용자 음성 응답 말풍선
              UserSpeechBubble(text: userSpeechText, isActive: isSTTActive),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  /// 사용자 정의 상단 타이틀 바
  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 30), // 왼쪽 공백
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.chat_bubble, color: Color(0xFF333333), size: 24),
                SizedBox(width: 8),
                Text(
                  '사진 회상 대화 중',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.pushReplacementNamed(context, Routes.gallery);
              }, // 갤러리로 이동
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
}
