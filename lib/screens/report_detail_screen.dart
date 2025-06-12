import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../widgets/tap_widget.dart';
import '../utils/styles.dart';
import '../models/report.dart';
import '../data/report_api.dart';
import 'package:provider/provider.dart';
import '../user_provider.dart';

// TODO: 실제 API 연동 시 사용할 설정값들
// const String API_BASE_URL = 'https://your-api-server.com/api';
// const String AUDIO_STREAM_URL = 'https://your-audio-server.com/stream';

class ReportDetailScreen extends StatefulWidget {
  final String? fileName;
  final String? filePath;
  final List<Report>? allReports;
  final int? currentIndex;
  final String reportId;

  const ReportDetailScreen({
    Key? key,
    this.fileName,
    this.filePath,
    this.allReports,
    this.currentIndex,
    required this.reportId,
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
  Report? report;
  String? errorMessage;

  late AudioPlayer audioPlayer;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<bool>? _playingSub;
  late final StreamSubscription<PlayerState> _playerStateSub;

  @override
  void initState() {
    super.initState();

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
    // 플레이어 상태 변화 감지
    _playerStateSub = audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;

      final completed = state.processingState == ProcessingState.completed;
      final playing = state.playing;

      setState(() {
        // 완료되었을 경우 재생 상태를 false로 강제
        isPlaying = completed ? false : playing;
      });
    });

    _loadData();
  }

  @override
  void dispose() {
    _playerStateSub.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playingSub?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  void _initAudio() {
    // audioPlayer = AudioPlayer();
    // _positionSub = audioPlayer.positionStream.listen((pos) {
    //   if (mounted) setState(() => currentPosition = pos);
    // });
    // _durationSub = audioPlayer.durationStream.listen((dur) {
    //   if (mounted && dur != null) setState(() => totalDuration = dur);
    // });
    // _playingSub = audioPlayer.playingStream.listen((playing) {
    //   if (mounted) setState(() => isPlaying = playing);
    // });
  }

  // TODO: 실제 보고서 데이터를 가져오는 함수 예시
  // Future<Map<String, dynamic>> fetchReportData(String reportId) async {
  //   final response = await http.get(Uri.parse('${API_BASE_URL}/reports/$reportId'));
  //   return json.decode(response.body);
  // }

  Future<void> _loadData() async {
    try {
      final accessToken = Provider.of<UserProvider>(context, listen: false).accessToken;
      if (accessToken == null) {
        throw Exception('로그인이 필요합니다');
      }
      final detail = await ReportApi.fetchReportDetail(accessToken, widget.reportId);
      setState(() {
        report = detail;
        fileContent = detail.anomalyReport ?? '내용 없음';
        isLoading = false;
      });
      await _loadAudio();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
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
    final state = audioPlayer.playerState;

    if (state.processingState == ProcessingState.completed) {
      await audioPlayer.seek(Duration.zero); // 반드시 위치 초기화
      await audioPlayer.play(); // 이후 재생
    } else if (audioPlayer.playing) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }

    setState(() => isPlaying = audioPlayer.playing);
  }

  //   if (!isAudioLoaded) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('오디오 파일이 준비되지 않았습니다')));
  //     return;
  //   }

  //   try {
  //     if (isPlaying) {
  //       await audioPlayer.pause();
  //     } else {
  //       await audioPlayer.play();
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('재생 실패: 파일 형식을 확인해주세요'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //     setState(() {
  //       isPlaying = false;
  //       isAudioLoaded = false;
  //     });
  //   }
  // }

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
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    // return '${minutes}:${seconds.toString().padLeft(2, '0')}';

    if (hours > 0) {
      return '${hours}시간 ${minutes}분 ${seconds}초';
    } else {
      return '${minutes}분 ${seconds}초';
    }
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
      fileName: previousReport.anomalyReport ?? '이상 대화 리포트',
      filePath: '',
      allReports: widget.allReports,
      currentIndex: currentIdx - 1,
      reportId: '',
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
      fileName: nextReport.anomalyReport ?? '이상 대화 리포트',
      filePath: '',
      allReports: widget.allReports,
      currentIndex: currentIdx + 1,
      reportId: '',
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
          Container(
            padding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
            child: _BackButton(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _Header() {
    final reportTitle = widget.fileName ?? '대화 분석 보고서';
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // 제목에서 날짜와 시간 부분 분리
    String dateTime = '';
    String title = '대화 분석 보고서';
    
    if (reportTitle != '대화 분석 보고서') {
      final parts = reportTitle.split(' ');
      if (parts.length >= 2) {
        dateTime = '${parts[0]} ${parts[1]}';
      }
    }

    final bool hasPrevious =
        widget.allReports != null &&
        widget.currentIndex != null &&
        widget.currentIndex! > 0;

    final bool hasNext =
        widget.allReports != null &&
        widget.currentIndex != null &&
        widget.currentIndex! < widget.allReports!.length - 1;

    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      height: 80 + statusBarHeight,
      color: AppColors.headerBg,
      child: Stack(
        children: [
          // 가운데 텍스트
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (dateTime.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    dateTime,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF777777),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          // 이전 버튼
          Positioned(
            left: 16,
            top: (80 - 40) / 2,
            child: GestureDetector(
              onTap: hasPrevious ? _goToPreviousReport : null,
              child: Container(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: hasPrevious ? AppColors.primary : Colors.grey,
                ),
              ),
            ),
          ),
          // 다음 버튼
          Positioned(
            right: 16,
            top: (80 - 40) / 2,
            child: GestureDetector(
              onTap: hasNext ? _goToNextReport : null,
              child: Container(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: hasNext ? AppColors.primary : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: report?.imageUrl != null
                    ? NetworkImage(report!.imageUrl!)
                    : AssetImage('assets/photos/3.png') as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [_PlayButton(), _AudioProgress()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _AudioProgress() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            isAudioLoaded
                ? '전체 대화 시간: ${_formatTime(totalDuration)}'
                // ? '${_formatTime(currentPosition)} / ${_formatTime(totalDuration)}'
                : '오디오 파일을 찾을 수 없습니다',
            style: TextStyle(
              color: isAudioLoaded
                  ? AppColors.timeText
                  : AppColors.timeText.withOpacity(0.5),
              fontSize: 15,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 8),
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
      ],
    );
  }

  Widget _PlayButton() {
    return Container(
      width: 50,
      height: 50,
      child: IconButton(
        icon: Image.asset(
          isPlaying ? 'assets/icons/Pause.png' : 'assets/icons/Play.png',
        ),
        color: Color(0xFF333333),
        onPressed: isAudioLoaded ? _togglePlay : null,
      ),
    );
  }
  //   return GestureDetector(
  //     onTap: isAudioLoaded ? _togglePlay : null,
  //     child: Container(
  //       width: 50,
  //       height: 50,
  //       child: Image.asset(
  //         isPlaying ? 'assets/icons/Pause.png' : 'assets/icons/Play.png',
  //         color: Color(0xFF333333),
  //       ),
  //     ),
  //   );
  // }

  Widget _ReportSection() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 10),
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
          : errorMessage != null
              ? Container(
                  height: 200,
                  child: Center(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    (report?.anomalyReport ?? '내용 없음').toString(),
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
      height: 55,
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
