// lib/screens/picture_guardian_transcript.dart
import 'package:flutter/material.dart';
// import 'picture_guardian_llm.dart'; // 원본 오디오 화면 import
// import '2-3-3.dart';

class ConversationTranscriptScreen extends StatefulWidget {
  const ConversationTranscriptScreen({Key? key}) : super(key: key);

  @override
  State<ConversationTranscriptScreen> createState() =>
      _ConversationTranscriptScreenState();
}

class _ConversationTranscriptScreenState
    extends State<ConversationTranscriptScreen>
    with TickerProviderStateMixin {
  double currentPosition = 1.5; // 현재 재생 위치 (분)
  double totalDuration = 3.5; // 전체 길이 (분)
  bool isPlaying = false;

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 슬라이드 업 애니메이션 (하얀색 오버레이만)
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(0.0, 1.0), // 화면 아래에서 시작
          end: Offset.zero,
        ).animate(
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
      body: Stack(
        children: [
          // 상단 헤더 배경 (애니메이션 없음)
          _buildHeaderBackground(),

          // 프로필 섹션 (애니메이션 없음)
          _buildProfileSection(),

          // 메인 이미지 (애니메이션 없음)
          _buildMainImage(),

          // 하단 컨텐츠 오버레이 (애니메이션 적용)
          _buildContentOverlay(),

          // 하단 네비게이션 (애니메이션 없음)
          _buildBottomNavigation(),

          // 상태바 (애니메이션 없음)
          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Positioned(
      left: 0,
      top: 0,
      child: Container(
        width: 375,
        height: 104,
        decoration: const BoxDecoration(color: Color(0xFF00C8B8)),
        child: SafeArea(
          child: Center(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Expanded(
                  child: const Text(
                    '화목한 우리 가족^~^',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Positioned(
      left: 0,
      top: 104,
      child: Container(
        width: 375,
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
      ),
    );
  }

  Widget _buildMainImage() {
    return Positioned(
      left: 0,
      top: 174,
      child: Container(
        width: 375,
        height: 375,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/photos/3.png'), // 실제 이미지 경로
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildContentOverlay() {
    return Positioned(
      left: 0,
      top: 400, // 사진이 더 많이 보이도록 아래로 조정
      bottom: 80, // 하단 네비게이션까지 연결
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: 375,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              border: Border.all(color: const Color(0x7F999999), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33555555),
                  blurRadius: 10,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 15),

                // 타이틀
                const Text(
                  '2025년 5월 16일 대화 요약본',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                // 오디오 컨트롤 (컴팩트)
                _buildCompactAudioControls(),

                const SizedBox(height: 15),

                // 대화 내용 (스크롤 가능)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF00C8B8),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '대화 내용:',
                            style: TextStyle(
                              color: Color(0xFF00C8B8),
                              fontSize: 14,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '옛날 국민 학교 다닐 시절에 친구들하고 삼삼오오 모여서 공기놀이를 자주 하곤 했지. 근데 할머니가 영 실력이 없어서 항상 콧수염을 붙이는 벌칙을 했어. 그때 참 재미있었는데...\n\n공기놀이를 할 때면 동네 아이들이 모두 모여서 함께 했어. 5개의 작은 돌멩이로 하는 놀이였는데, 손놀림이 빨라야 하고 집중력도 필요했지.\n\n그런데 할머니는 손이 빠르지 못해서 자꾸 실수를 했어. 그래서 벌칙으로 콧수염을 붙이곤 했는데, 그 모습이 너무 우스꽝스러워서 친구들이 배꼽을 잡고 웃었지.\n\n지금 생각해봐도 그때가 참 즐거웠어. 단순한 놀이였지만 친구들과 함께하는 시간이 소중했거든.\n\n그날은 특히 날씨가 좋았어. 봄볕이 따사롭게 내리쬐는 오후였는데, 마당에 둘러앉아서 공기놀이를 했지. 할머니는 늘 마지막에 남았어.\n\n친구들이 "언니, 또 벌칙이네!" 하면서 웃었어. 그럼 할머니도 같이 웃으면서 콧수염을 붙였지. 검은 종이로 만든 가짜 콧수염이었는데, 붙이고 나면 정말 아저씨 같았어.',
                            style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: 14,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactAudioControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 45,
      child: Column(
        children: [
          // 시간 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(currentPosition),
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 9,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatTime(totalDuration),
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 9,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // 슬라이더와 컨트롤 버튼들
          Row(
            children: [
              // 뒤로감기 버튼
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(color: Colors.transparent),
                child: const Icon(
                  Icons.fast_rewind,
                  color: Color(0xFF333333),
                  size: 16,
                ),
              ),

              const SizedBox(width: 10),

              // 슬라이더 (진행바)
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF00C8B8),
                    inactiveTrackColor: const Color(0xFFE5E5E5),
                    thumbColor: const Color(0xFF00C8B8),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 4,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 8,
                    ),
                    trackHeight: 3,
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

              const SizedBox(width: 10),

              // 재생/일시정지 버튼
              GestureDetector(
                onTap: () {
                  setState(() {
                    isPlaying = !isPlaying;
                  });
                },
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C8B8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // 앞으로감기 버튼
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(color: Colors.transparent),
                child: const Icon(
                  Icons.fast_forward,
                  color: Color(0xFF333333),
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Positioned(
      left: 0,
      top: 732, //732
      child: Container(
        width: 375,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0x7F999999), width: 0.7),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33555555),
              blurRadius: 10,
              offset: Offset(0, 1),
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
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, int index) {
    bool isSelected = index == 1; // 사진첩이 선택된 상태로 표시

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
              size: 30,
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
                fontSize: 12,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Positioned(
      left: 0,
      top: 0,
      child: SafeArea(
        child: Container(
          width: 375,
          height: 54,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 52),
                child: const Text(
                  '9:41',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: Row(
                  children: [
                    Container(
                      width: 25,
                      height: 13,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                        ),
                        borderRadius: BorderRadius.circular(4.3),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
