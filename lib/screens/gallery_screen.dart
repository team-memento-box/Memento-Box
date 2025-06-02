import 'package:flutter/material.dart';
import '../widgets/tap_widget.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  void _showScriptBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      '2025년 5월 16일 대화 원본',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 재생바 및 버튼
                  Row(
                    children: [
                      const Text("01:32"),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: 92,
                          min: 0,
                          max: 207,
                          onChanged: (value) {},
                          activeColor: Color(0xFF00B4AA),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text("03:29"),
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fast_rewind),
                      SizedBox(width: 16),
                      Icon(Icons.play_arrow, size: 36),
                      SizedBox(width: 16),
                      Icon(Icons.fast_forward),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _chatBubble("이 사진 언제 찍었는지 기억 나세요?", isBot: true),
                        _chatBubble("응 당연하지~ 국민 학교 다닐 적이었을 거야"),
                        _chatBubble(
                          "와 아주 옛날 일까지 기억하고 계시네요 대단해요! 그때 무슨 일이 있었는지 말씀해주실 수 있나요?",
                          isBot: true,
                        ),
                        _chatBubble("친구들, 저 짝 삼승리 넘어 동네 친구들이"),
                        _chatBubble("삼삼오오 다같이 모여 가지고는 공기놀이를 했어"),
                        _chatBubble("그때는 내가 영 실력이 파이야 벌칙에 제일 많이 걸렸어"),
                        _chatBubble(
                          "친구들과 공기놀이라니! 너무 재미있었을 것 같아요. 공기놀이에 져서 어떤 벌칙을 주로 받으셨어요?",
                          isBot: true,
                        ),
                        _chatBubble(
                          "콧수염 붙이기였어~ 아유 지금 생각해도 너무 웃겨. 그때 아주 영히하고 민속히하고 배꼽을 잡고 웃었는데",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _chatBubble(String text, {bool isBot = false}) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisAlignment: isBot
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset(
                  'assets/images/chatbot_profile.png',
                  width: 32,
                  height: 32,
                ),
              ),
            ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: const BoxConstraints(maxWidth: 280),
              decoration: BoxDecoration(
                color: isBot ? Colors.grey.shade200 : const Color(0xFF00B4AA),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isBot ? 0 : 16),
                  bottomRight: Radius.circular(isBot ? 16 : 0),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isBot ? Colors.black87 : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          '화목한 우리 가족^~^',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            fontFamily: 'Pretendard',
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Row(
              children: [
                Text(
                  '2025년',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard',
                    color: Color(0xFF111111),
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  '봄',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard',
                    color: Color(0xFF111111),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: 10,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.49,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _showScriptBottomSheet(context),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/photos/1.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
