import 'package:flutter/material.dart';

class PhotoConversationScreen extends StatelessWidget {
  const PhotoConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          '사진 회상 대화 중',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'Pretendard',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFCCCCCC), height: 1),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildAssistantBubble(),
          const SizedBox(height: 20),
          _buildPhotoSection(),
          const Spacer(),
          _buildUserSpeechBubble(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildAssistantBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/images/chatbot_profile.png'),
            backgroundColor: Colors.transparent, // 필요 시 배경 제거
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDEDEDE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '안녕하세요!\n오늘 대화를 도와드릴게요.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x33999999)),
        borderRadius: BorderRadius.circular(10),
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
          const Icon(Icons.mic, size: 36, color: Colors.grey),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFDEDEDE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '아, 아 마이크 테스트',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
