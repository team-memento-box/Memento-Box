// lib/screens/picture_guardian_llm.dart
import 'package:flutter/material.dart';

class PictureGuardianLlmScreen extends StatefulWidget {
  const PictureGuardianLlmScreen({Key? key}) : super(key: key);

  @override
  State<PictureGuardianLlmScreen> createState() =>
      _PictureGuardianLlmScreenState();
}

class _PictureGuardianLlmScreenState extends State<PictureGuardianLlmScreen>
    with TickerProviderStateMixin {
  bool isPlaying = false;
  double currentPosition = 1.5; // 현재 재생 위치 (분)
  double totalDuration = 3.5; // 전체 길이 (분)

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 슬라이드 업 애니메이션
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    // 화면 진입 시 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // 헤더
                _buildHeader(),

                // 메인 컨텐츠 - 원본 대화
                Expanded(child: _buildOriginalConversation()),

                // 하단 네비게이션
                _buildBottomNavigation(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 60,
      color: const Color(0xFF00C8B8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
          Expanded(
            child: const Text(
              '원본 대화 듣기',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildOriginalConversation() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 날짜 표시
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Text(
              '2025년 5월 16일 대화 원본',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pretendard',
              ),
            ),
          ),

          // 오디오 컨트롤
          _buildAudioControls(),

          const SizedBox(height: 20),

          // 대화 내용
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // 시간 표시와 슬라이더
          Row(
            children: [
              Text(
                _formatTime(currentPosition),
                style: const TextStyle(fontSize: 14, fontFamily: 'Pretendard'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF00C8B8),
                    inactiveTrackColor: const Color(0xFFE5E5E5),
                    thumbColor: const Color(0xFF00C8B8),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 12,
                    ),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: currentPosition,
                    min: 0,
                    max: totalDuration,
                    onChanged: (value) {
                      setState(() {
                        currentPosition = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(totalDuration),
                style: const TextStyle(fontSize: 14, fontFamily: 'Pretendard'),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 재생 컨트롤 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.fast_rewind, size: 30),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isPlaying = !isPlaying;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C8B8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.fast_forward, size: 30),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chatBubble(String text, {bool isBot = false}) {
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
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C8B8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: const BoxConstraints(maxWidth: 280),
              decoration: BoxDecoration(
                color: isBot ? Colors.grey.shade200 : const Color(0xFF00C8B8),
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
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0x7F999999), width: 0.7),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33555555),
            blurRadius: 10,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNavItem('홈', Icons.home, 0),
          _buildNavItem('사진첩', Icons.photo_library, 1),
          _buildNavItem('사진 추가', Icons.add_a_photo, 2),
          _buildNavItem('보고서', Icons.description, 3),
          _buildNavItem('나의 정보', Icons.person, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, int index) {
    bool isSelected = index == 2; // 임시로 "사진 추가" 선택됨으로 설정

    return Expanded(
      child: GestureDetector(
        onTap: () {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/gallery');
              break;
            case 2:
              Navigator.pushNamed(context, '/addphoto');
              break;
            case 3:
              Navigator.pushNamed(context, '/report');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? const Color(0xFF00C8B8)
                  : const Color(0xFF555555),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF00C8B8)
                    : const Color(0xFF555555),
                fontSize: 10,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(double minutes) {
    int mins = minutes.floor();
    int secs = ((minutes - mins) * 60).round();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
