// lib/screens/picture_guardian_listen.dart
import 'package:flutter/material.dart';
import 'picture_guardian_transcript.dart'; // 🎯 텍스트 대화 내용 화면
import 'picture_guardian_llm.dart'; // 🎯 원본 오디오 화면

class ConversationPlaybackScreen extends StatefulWidget {
  const ConversationPlaybackScreen({Key? key}) : super(key: key);

  @override
  State<ConversationPlaybackScreen> createState() =>
      _ConversationPlaybackScreenState();
}

class _ConversationPlaybackScreenState
    extends State<ConversationPlaybackScreen> {
  bool isPlaying = false;
  double currentPosition = 1.5; // 현재 재생 위치 (분)
  double totalDuration = 3.5; // 전체 길이 (분)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(),

            // 프로필 섹션
            _buildProfileSection(),

            // 메인 컨텐츠
            Expanded(
              child: Stack(
                children: [
                  // 배경 사진
                  _buildBackgroundPhoto(),

                  // 컨텐츠 오버레이
                  _buildContentOverlay(),
                ],
              ),
            ),

            // 하단 네비게이션
            _buildBottomNavigation(),
          ],
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
              '화목한 우리 가족^~^',
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

  Widget _buildProfileSection() {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0x33999999), width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 15,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        child: Row(
          children: [
            // 프로필 아바타
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xFFFFC9B3), Color(0xFFFFD2C2)],
                ),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            const SizedBox(width: 10),
            // 프로필 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Text(
                        '김땡땡',
                        style: TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 18,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF777777),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          '딸',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '2025년 5월 25일',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 13,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
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

  Widget _buildBackgroundPhoto() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/photos/3.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildContentOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: const Color(0x7F999999)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33555555),
              blurRadius: 10,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 타이틀
            const Text(
              '2025년 5월 16일 대화 요약본',
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 18,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 30),

            // 오디오 컨트롤
            _buildAudioControls(),

            const SizedBox(height: 30),

            // 액션 버튼들 - 🎯 핵심 수정 부분!
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioControls() {
    return Column(
      children: [
        // 시간 표시
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatTime(currentPosition),
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 10,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _formatTime(totalDuration),
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 10,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 진행바
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF00C8B8),
            inactiveTrackColor: const Color(0xFFE5E5E5),
            thumbColor: const Color(0xFF00C8B8),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
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

        const SizedBox(height: 15),

        // 컨트롤 버튼들
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(Icons.skip_previous, () {}),
            const SizedBox(width: 15),
            _buildControlButton(Icons.replay_10, () {}),
            const SizedBox(width: 15),
            GestureDetector(
              onTap: () {
                setState(() {
                  isPlaying = !isPlaying;
                });
              },
              child: Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: Color(0xFF00C8B8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 15),
            _buildControlButton(Icons.forward_10, () {}),
            const SizedBox(width: 15),
            _buildControlButton(Icons.skip_next, () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Icon(icon, color: const Color(0xFF555555), size: 20),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // 🎯 내용 보기 버튼 - guardian_transcript 페이지로 이동 (텍스트 대화)
        Expanded(
          child: Container(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                print("✅ 내용 보기 클릭 → ConversationTranscriptScreen (텍스트 대화)");
                // 📝 텍스트 대화 내용이 있는 guardian_transcript 페이지로 이동
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const ConversationTranscriptScreen(), // 텍스트 대화 화면
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0); // 아래에서 위로 슬라이드
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;

                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C8B8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Text(
                '내용 보기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 11),

        // 🎯 원본 듣기 버튼 - guardian_llm 페이지로 이동 (원본 오디오)
        Expanded(
          child: Container(
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                print("✅ 원본 듣기 클릭 → PictureGuardianLlmScreen (원본 오디오)");
                // 🎧 원본 오디오가 있는 guardian_llm 페이지로 이동
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const PictureGuardianLlmScreen(), // 원본 오디오 화면
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0); // 아래에서 위로 슬라이드
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;

                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00C8B8), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                '원본 듣기',
                style: TextStyle(
                  color: Color(0xFF00C8B8),
                  fontSize: 18,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
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
