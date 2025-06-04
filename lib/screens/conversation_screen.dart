import 'package:flutter/material.dart';

class PhotoConversationScreen extends StatefulWidget {
  const PhotoConversationScreen({super.key});

  @override
  State<PhotoConversationScreen> createState() =>
      _PhotoConversationScreenState();
}

class _PhotoConversationScreenState extends State<PhotoConversationScreen> {
  bool isTTSActive = false;
  bool isSTTActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(114),
        child: Column(
          children: [_buildStatusBar(), _buildCustomAppBar(context)],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 1,
                color: const Color(0x7F999999),
              ),
              const SizedBox(height: 30),
              _buildAssistantBubble(),
              const SizedBox(height: 30),
              _buildPhotoSection(),
              const SizedBox(height: 80),
              _buildUserSpeechBubble(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 54,
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 시간 (왼쪽 정렬)
              Text(
                '9:41',
                style: TextStyle(
                  color: const Color(0xFF090909),
                  fontSize: 17,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
              // 네트워크 및 배터리 아이콘 (오른쪽 정렬)
              Row(
                children: [
                  // 신호 세기 아이콘 (작은 사각형들)
                  Row(
                    children: List.generate(
                      4,
                      (index) => Container(
                        width: 3,
                        height: 4 + (index * 2.0),
                        margin: const EdgeInsets.only(right: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF090909),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.wifi, size: 16, color: Color(0xFF090909)),
                  const SizedBox(width: 8),
                  // 배터리 아이콘
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      // Battery outline
                      Container(
                        width: 25,
                        height: 13,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: const Color(0xFF090909),
                          ),
                          borderRadius: BorderRadius.circular(4.30),
                        ),
                      ),
                      // Battery fill
                      Positioned(
                        right: 3,
                        child: Container(
                          width: 21,
                          height: 9,
                          decoration: BoxDecoration(
                            color: const Color(0xFF090909),
                            borderRadius: BorderRadius.circular(2.50),
                          ),
                        ),
                      ),
                      // Battery tip
                      Positioned(
                        right: -4,
                        child: Container(
                          width: 1.5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFF090909),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 30),
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
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTTSActive ? Colors.orange : Colors.transparent,
              border: isTTSActive
                  ? Border.all(color: Colors.orange, width: 3)
                  : null,
            ),
            child: const CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage('assets/images/chatbot_profile.png'),
              backgroundColor: Colors.transparent,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDEDEDE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '안녕하세요!\n오늘 대화를 도와드릴게요.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Pretendard',
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      width: double.infinity,
      height: 350,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x33999999)),
        image: const DecorationImage(
          image: AssetImage('assets/photos/3.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildUserSpeechBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 54,
            height: 54,
            child: Icon(
              Icons.mic,
              size: 36,
              color: isSTTActive ? Colors.orange : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFDEDEDE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '아, 아 마이크 테스트',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Pretendard',
                  height: 1.25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void toggleTTS() {
    setState(() {
      isTTSActive = !isTTSActive;
    });
  }

  void toggleSTT() {
    setState(() {
      isSTTActive = !isSTTActive;
    });
  }
}
