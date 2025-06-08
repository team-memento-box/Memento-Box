import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../widgets/tap_widget.dart';
import '../utils/styles.dart';

// TODO: 실제 API 연동 시 사용할 설정값들
// const String API_BASE_URL = 'https://your-api-server.com/api';
// const String AUDIO_STREAM_URL = 'https://your-audio-server.com/stream';

class ReportDetailScreen extends StatefulWidget {
  final String? fileName;
  final String? filePath;
  final List<Map<String, String>>? allReports; // 전체 리포트 목록 추가
  final int? currentIndex; // 현재 리포트 인덱스 추가

  const ReportDetailScreen({
    Key? key,
    this.fileName,
    this.filePath,
    this.allReports,
    this.currentIndex,
  }) : super(key: key);

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  String fileContent = '';
  bool isLoading = true;
  bool isPlaying = false;
  String? audioFilePath;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;
  bool isAudioLoaded = false;

  late AudioPlayer audioPlayer;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<bool>? _playingSub;

  @override
  void initState() {
    super.initState();
    _initAudio();
    _loadData();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playingSub?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  void _initAudio() {
    audioPlayer = AudioPlayer();
    _positionSub = audioPlayer.positionStream.listen((pos) {
      if (mounted) setState(() => currentPosition = pos);
    });
    _durationSub = audioPlayer.durationStream.listen((dur) {
      if (mounted && dur != null) setState(() => totalDuration = dur);
    });
    _playingSub = audioPlayer.playingStream.listen((playing) {
      if (mounted) setState(() => isPlaying = playing);
    });
  }

  // TODO: 실제 보고서 데이터를 가져오는 함수 예시
  // Future<Map<String, dynamic>> fetchReportData(String reportId) async {
  //   final response = await http.get(Uri.parse('${API_BASE_URL}/reports/$reportId'));
  //   return json.decode(response.body);
  // }

  Future<void> _loadData() async {
    try {
      final content = await _getContent();
      await _loadAudio();
      setState(() {
        fileContent = content;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        fileContent = '파일 읽기 오류: $e';
        isLoading = false;
      });
    }
  }

  // TODO: 실제 오디오 파일 API에서 가져오는 함수 예시
  // Future<String> fetchAudioUrl(String reportId) async {
  //   final response = await http.get(Uri.parse('${API_BASE_URL}/audio/$reportId'));
  //   return json.decode(response.body)['audioUrl'];
  // }

  Future<void> _loadAudio() async {
    if (widget.filePath?.isEmpty ?? true) return;

    final basePath = _getAudioPath(widget.filePath!);
    final audioPath = await _findAudio(basePath);

    if (audioPath != null) {
      setState(() => audioFilePath = audioPath);
      await _setAudio(audioPath);
    } else {
      setState(() => isAudioLoaded = false);
    }
  }

  Future<void> _setAudio(String path) async {
    try {
      await audioPlayer.setAsset(path);
      setState(() => isAudioLoaded = true);
    } catch (e) {
      try {
        await audioPlayer.setAudioSource(AudioSource.asset(path));
        setState(() => isAudioLoaded = true);
      } catch (e2) {
        setState(() => isAudioLoaded = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('오디오 파일 형식이 지원되지 않습니다'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  String _getAudioPath(String textPath) {
    final fileName = textPath.split('/').last.replaceAll('.txt', '');
    return 'assets/voice/$fileName';
  }

  Future<String?> _findAudio(String basePath) async {
    final extensions = ['.mp3', '.m4a', '.wav', '.ogg'];
    for (final ext in extensions) {
      final path = '$basePath$ext';
      if (await _fileExists(path)) return path;
    }
    return null;
  }

  Future<bool> _fileExists(String path) async {
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      return json.decode(manifest).containsKey(path);
    } catch (e) {
      return false;
    }
  }

  Future<void> _togglePlay() async {
    if (!isAudioLoaded) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오디오 파일이 준비되지 않았습니다')));
      return;
    }

    try {
      if (isPlaying) {
        await audioPlayer.pause();
      } else {
        await audioPlayer.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('재생 실패: 파일 형식을 확인해주세요'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        isPlaying = false;
        isAudioLoaded = false;
      });
    }
  }

  Future<void> _seekTo(double progress) async {
    if (!isAudioLoaded || totalDuration.inMilliseconds == 0) return;

    final position = Duration(
      milliseconds: (totalDuration.inMilliseconds * progress).toInt(),
    );
    try {
      await audioPlayer.seek(position);
    } catch (e) {
      print('Seek 오류: $e');
    }
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (totalDuration.inMilliseconds == 0) return 0.0;
    return (currentPosition.inMilliseconds / totalDuration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  Future<String> _getContent() async {
    if (widget.filePath?.isEmpty ?? true) return '파일 경로가 제공되지 않았습니다.';
    return await rootBundle.loadString(widget.filePath!);
  }

  // 슬라이드 애니메이션을 위한 커스텀 Page Route
  Route _createSlideRoute(Widget page, {bool isNext = true}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration(milliseconds: 300),
      reverseTransitionDuration: Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 다음 페이지로 갈 때는 왼쪽으로, 이전 페이지로 갈 때는 오른쪽으로
        final begin = isNext ? Offset(1.0, 0.0) : Offset(-1.0, 0.0);
        final end = Offset.zero;
        final curve = Curves.easeInOutCubic;

        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  // 이전 리포트로 이동하는 함수 (슬라이드 애니메이션 추가)
  void _goToPreviousReport() {
    if (widget.allReports == null || widget.currentIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('리포트 목록 정보가 없습니다'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final currentIdx = widget.currentIndex!;
    if (currentIdx <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('첫 번째 리포트입니다'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    final previousReport = widget.allReports![currentIdx - 1];
    final newPage = ReportDetailScreen(
      fileName: previousReport['displayTitle'],
      filePath: previousReport['filePath'],
      allReports: widget.allReports,
      currentIndex: currentIdx - 1,
    );

    // 오른쪽에서 왼쪽으로 슬라이드 (이전 페이지)
    Navigator.pushReplacement(
      context,
      _createSlideRoute(newPage, isNext: false),
    );
  }

  // 다음 리포트로 이동하는 함수 (슬라이드 애니메이션 추가)
  void _goToNextReport() {
    if (widget.allReports == null || widget.currentIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('리포트 목록 정보가 없습니다'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final currentIdx = widget.currentIndex!;
    if (currentIdx >= widget.allReports!.length - 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('마지막 리포트입니다'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    final nextReport = widget.allReports![currentIdx + 1];
    final newPage = ReportDetailScreen(
      fileName: nextReport['displayTitle'],
      filePath: nextReport['filePath'],
      allReports: widget.allReports,
      currentIndex: currentIdx + 1,
    );

    // 왼쪽에서 오른쪽으로 슬라이드 (다음 페이지)
    Navigator.pushReplacement(
      context,
      _createSlideRoute(newPage, isNext: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 고정 영역: 헤더
          _Header(),
          _PrevNextButton(),
          // 고정 영역: 프로필/음성 컨트롤 섹션
          _ProfileSection(),
          // 스크롤 영역: 텍스트 박스만 스크롤
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _ReportSection(),
            ),
          ),
          // 고정 영역: 뒤로가기 버튼
          Container(padding: EdgeInsets.all(16), child: _BackButton()),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _Header() {
    final reportTitle = widget.fileName ?? '9999-99-99 00:00 대화 분석 보고서';
    final parts = reportTitle.split(' ');
    final title = parts.sublist(2).join(' ');
    final subTitle = '${parts[0]} ${parts[1]}';

    return AppBar(
      backgroundColor: AppColors.headerBg,
      elevation: 3,
      // shadowColor: Color(0xFF555555),
      toolbarHeight: 80,
      centerTitle: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subTitle,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }

  Widget _PrevNextButton() {
    // 이전/다음 버튼 활성화 상태 확인
    final bool hasPrevious =
        widget.allReports != null &&
        widget.currentIndex != null &&
        widget.currentIndex! > 0;

    final bool hasNext =
        widget.allReports != null &&
        widget.currentIndex != null &&
        widget.currentIndex! < widget.allReports!.length - 1;

    return Positioned(
      top: MediaQuery.of(context).padding.top,
      child:
          // 이전 리포트 버튼
          GestureDetector(
            onTap: hasPrevious ? () => _goToPreviousReport() : null,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: hasPrevious
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_left,
                color: hasPrevious ? AppColors.primary : Colors.grey,
                size: 24,
              ),
            ),
          ),
    );
  }
  // return Container(
  //   padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
  //   decoration: BoxDecoration(
  //     color: AppColors.headerBg,
  //     boxShadow: [
  //       BoxShadow(
  //         color: Color(0x33555555),
  //         blurRadius: 10,
  //         offset: Offset(0, -1),
  //       ),
  //     ],
  //   ),
  //   child: Row(
  //     children: [
  //       // 이전 리포트 버튼
  //       GestureDetector(
  //         onTap: hasPrevious ? () => _goToPreviousReport() : null,
  //         child: Container(
  //           width: 40,
  //           height: 40,
  //           decoration: BoxDecoration(
  //             color: hasPrevious
  //                 ? AppColors.primary.withOpacity(0.1)
  //                 : Colors.grey.withOpacity(0.1),
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Icon(
  //             Icons.chevron_left,
  //             color: hasPrevious ? AppColors.primary : Colors.grey,
  //             size: 24,
  //           ),
  //         ),
  //       ),
  //       // 제목 영역
  //       Expanded(
  //         child: Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 12),
  //           child: FittedBox(
  //             fit: BoxFit.scaleDown,
  //             child: Text(
  //               widget.fileName ?? '보고서',
  //               textAlign: TextAlign.center,
  //               maxLines: 1,
  //               style: TextStyle(
  //                 fontSize: 22,
  //                 fontWeight: FontWeight.w800,
  //                 fontFamily: 'Pretendard',
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //       // 다음 리포트 버튼
  //       GestureDetector(
  //         onTap: hasNext ? () => _goToNextReport() : null,
  //         child: Container(
  //           width: 40,
  //           height: 40,
  //           decoration: BoxDecoration(
  //             color: hasNext
  //                 ? AppColors.primary.withOpacity(0.1)
  //                 : Colors.grey.withOpacity(0.1),
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Icon(
  //             Icons.chevron_right,
  //             color: hasNext ? AppColors.primary : Colors.grey,
  //             size: 24,
  //           ),
  //         ),
  //       ),
  //     ],
  //   ),
  // );

  Widget _ProfileSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.progressBg, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage('../assets/photos/3.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(child: _AudioProgress()),
          SizedBox(width: 16),
          _PlayButton(),
        ],
      ),
    );
  }

  Widget _AudioProgress() {
    return Column(
      children: [
        GestureDetector(
          onTapDown: isAudioLoaded
              ? (details) async {
                  final box = context.findRenderObject() as RenderBox;
                  final pos = box.globalToLocal(details.globalPosition);
                  final newProgress = (pos.dx / box.size.width).clamp(0.0, 1.0);
                  await _seekTo(newProgress);
                }
              : null,
          child: Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.progressBg,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              widthFactor: progress,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: isAudioLoaded
                      ? AppColors.primary
                      : AppColors.progressBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          isAudioLoaded
              ? '${_formatTime(currentPosition)} / ${_formatTime(totalDuration)}'
              : '오디오 파일을 찾을 수 없습니다',
          style: TextStyle(
            color: isAudioLoaded
                ? AppColors.timeText
                : AppColors.timeText.withOpacity(0.5),
            fontSize: 12,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _PlayButton() {
    return GestureDetector(
      onTap: isAudioLoaded ? _togglePlay : null,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isAudioLoaded
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.3),
          shape: BoxShape.circle,
          boxShadow: isAudioLoaded
              ? [
                  BoxShadow(
                    color: Color(0x33555555),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Icon(
          isAudioLoaded
              ? (isPlaying ? Icons.pause : Icons.play_arrow)
              : Icons.music_off,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _ReportSection() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [BoxShadow(color: Color(0x19777777), blurRadius: 5)],
      ),
      child: isLoading
          ? Container(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Text(
                fileContent,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
    );
  }

  Widget _BackButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Text(
          '목록 보기',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class AppColors {
  static const Color primary = Color(0xFF00C8B8);
  static const Color background = Color(0xFFF7F7F7);
  static const Color headerBg = Color.fromARGB(255, 254, 255, 255);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF555555);
  static const Color timeText = Color(0xFF666666);
  static const Color progressBg = Color(0xFFE0E0E0);
}
