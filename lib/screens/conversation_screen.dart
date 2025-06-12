// 0603 고권아 작업
// 사용자 챗봇 화면

import '../utils/audio_service.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/assistant_bubble.dart'; // 챗봇 말풍선 위젯
import '../widgets/photo_box.dart'; // 고정된 사진 영역 위젯
import '../widgets/user_speech_bubble.dart'; // 사용자 음성 말풍선 위젯
import '../data/user_data.dart'; // 질문/응답/사진 정보가 담긴 데이터 파일
import '../user_provider.dart';
import '../utils/routes.dart';
import '../utils/styles.dart';
import '../models/photo.dart';
import '../models/question.dart';

class PhotoConversationScreen extends StatefulWidget {
  final String photoId;
  final String photoUrl;

  const PhotoConversationScreen({
    Key? key,
    required this.photoId,
    required this.photoUrl,
  }) : super(key: key);

  @override
  State<PhotoConversationScreen> createState() =>
      _PhotoConversationScreenState();
}

class _PhotoConversationScreenState extends State<PhotoConversationScreen> {
  late String photoId;
  late String photoUrl;

  String apiResult = 'Loading...';
  // String assistantText = '초기 텍스트';
  String photoPath = '초기 url';
  // String userSpeechText = '초기 대답';
  String? _conversationId;
  bool shouldEnd = false;

  // TTS, STT 기능이 동작 중인지 여부를 저장하는 상태 변수
  bool isTTSActive = false;
  bool isSTTActive = false;

  // 종료 플래그
  bool _isConversationActive = true;

  // 음성 인식 관련 변수들
  late AudioRecorder _audioRecorder;
  bool _isRecording = false;
  String _recognizedText = '...';
  String? _recordingPath;
  Timer? _silenceTimer;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  // 무음 감지 설정
  final double _silenceThreshold = -15.0; // dB 단위
  final int _silenceDuration = 7000; // 밀리초 단위 (7초)

  // === 자동 음성 재생을 위한 AudioService 인스턴스 ===
  late AudioService _audioService;

  // API 호출 상태 추적을 위한 변수 추가
  bool _isApiCallInProgress = false;
  Timer? _apiTimeoutTimer;

  @override
  void initState() {
    super.initState();
    photoId = widget.photoId;
    photoUrl = widget.photoUrl;
    _audioService = AudioService(); // AudioService 초기화
    _isConversationActive = true;
    shouldEnd = false;
    _audioRecorder = AudioRecorder(); // AudioRecorder 초기화
    print('photoId: $photoId');
    print('photoUrl: $photoUrl');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      while (true) {
        await _startConversation();
        await _startRecording();
        if (shouldEnd == true || !_isConversationActive) break;
      }
      await _audioService.stop(); // 만약 루프 탈출 후 오디오 남아 있으면 멈춤
    });
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _startConversation() async {
    try {
      final jsonData = await startConversation(photoId);
      final conversation = ConversationResponse.fromJson(jsonData);

      apiResult = conversation.question;
      photoPath = conversation.photoInfo.url;
      _conversationId = conversation.conversationId;

      setState(() {
        apiResult = conversation.question;
      });

      // === 초기 질문/음성파일만 재생 ===
      if (conversation.audioUrl != null && conversation.audioUrl.isNotEmpty) {
        await _audioService.loadAudio(conversation.audioUrl);
        isTTSActive = true;
        await _audioService.play();
        // 초기 음성 재생이 완료될 때까지 대기
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      print('❌ API error: $e');
      setState(() {
        apiResult = 'API failed: $e';
      });
    }
    isTTSActive = false;
  }

  Future<Map<String, dynamic>> startConversation(String imageId) async {
    final baseUrl = dotenv.env['BASE_URL']!;
    print("**********");
    print(imageId);
    print("**********");
    final url = Uri.parse('$baseUrl/api/chat/start?image_id=$imageId');

    final response = await http.post(url);

    if (response.statusCode == 200) {
      // 여기서 응답 바디를 UTF8로 디코딩
      final decoded = utf8.decode(response.bodyBytes);
      final Map<String, dynamic> jsonData = jsonDecode(decoded);
      return jsonData;
    } else {
      throw Exception('대화 시작 실패: ${response.statusCode}, ${response.body}');
    }
  }

  Future<bool> _requestPermissions() async {
    // 현재 권한 상태 확인
    final micStatus = await Permission.microphone.status;

    if (micStatus.isGranted) {
      return true;
    }

    // 권한이 없는 경우 요청
    final result = await Permission.microphone.request();

    if (result.isGranted) {
      return true;
    }

    if (result.isPermanentlyDenied) {
      // 영구적으로 거부된 경우 설정으로 이동
      await openAppSettings();
    }

    return false;
  }

  Future<void> _startRecording() async {
    try {
      // 기존 녹음 중지 및 리소스 정리
      if (_isRecording) {
        await _audioRecorder.stop();
      }
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;
      _silenceTimer?.cancel();
      _silenceTimer = null;
      _audioRecorder.dispose();
      _audioRecorder = AudioRecorder();

      final hasPermission = await _requestPermissions();

      if (hasPermission) {
        final directory = await getTemporaryDirectory();
        _recordingPath =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';

        // 새로운 녹음 시작
        await _audioRecorder.start(
          RecordConfig(
            encoder: AudioEncoder.wav, // WAV 포맷
            sampleRate: 16000, // 16kHz
            numChannels: 1, // Mono
            bitRate: 256000, // 실제 STT에는 영향 적지만 고정값 가능
          ),
          path: _recordingPath!,
        );

        setState(() {
          _isRecording = true;
          isSTTActive = true;
          _recognizedText = '';
        });

        // 새로운 amplitude 모니터링 시작
        _amplitudeSubscription = _audioRecorder
            .onAmplitudeChanged(const Duration(milliseconds: 300))
            .listen((amplitude) {
              if (amplitude.current < _silenceThreshold) {
                if (_silenceTimer == null || !_silenceTimer!.isActive) {
                  _silenceTimer = Timer(
                    Duration(milliseconds: _silenceDuration),
                    () {
                      if (_isRecording) {
                        _stopRecording();
                      }
                    },
                  );
                }
              } else {
                _silenceTimer?.cancel();
                _silenceTimer = null;
              }
            });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('마이크 권한이 필요합니다. 설정에서 권한을 허용해주세요.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('녹음 시작 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('녹음 시작 중 오류가 발생했습니다: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      print('녹음 중지 시도');
      _silenceTimer?.cancel();
      await _amplitudeSubscription?.cancel();

      await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        isSTTActive = false;
      });

      if (_recordingPath != null) {
        print('녹음 파일 경로: $_recordingPath');
        await _sendAudioToBackend();
      }
    } catch (e) {
      print('녹음 중지 오류: $e');
    }
  }

  // 모든 작업 취소를 위한 함수
  Future<void> _cancelAllOperations() async {
    // 1. 녹음 중지 및 리소스 정리
    if (_isRecording) {
      await _audioRecorder.stop();
    }
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    _silenceTimer?.cancel();
    _silenceTimer = null;
    _audioRecorder.dispose();

    // 2. TTS 중지
    await _audioService.pause();

    // 3. API 타임아웃 타이머 취소
    _apiTimeoutTimer?.cancel();
    _apiTimeoutTimer = null;

    // 4. API 호출 상태 초기화
    _isApiCallInProgress = false;
  }

  Future<void> _sendAudioToBackend() async {
    if (_isApiCallInProgress) return; // 이미 API 호출 중이면 중복 호출 방지

    try {
      _isApiCallInProgress = true;
      print('[디버그] _sendAudioToBackend 진입');
      final baseUrl = dotenv.env['BASE_URL']!;
      final file = File(_recordingPath!);
      print('[디버그] 녹음 파일 경로: \\${file.path}');
      print('[디버그] _conversationId: \\${_conversationId}');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/chat/user_answer'),
      );
      request.files.add(await http.MultipartFile.fromPath('audio', file.path));
      if (_conversationId != null) {
        request.fields['conversation_id'] = _conversationId!;
      } else {
        print('[경고] _conversationId가 null입니다!');
      }

      var response = await request.send();
      if (!mounted) return; // 위젯이 dispose된 경우 중단

      print('[디버그] 서버 응답 코드: \\${response.statusCode}');
      var responseBody = await response.stream.bytesToString();
      print('[디버그] 서버 응답 바디: \\${responseBody}');

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        print('[디버그] 받은 사용자 발화 텍스트: ${data['answer']}');

        if (!mounted) return;
        setState(() {
          _recognizedText = data['answer'] ?? '';
          print('[디버그] _recognizedText 업데이트: $_recognizedText');
        });

        // AI 응답 음성 재생 (있는 경우에만)
        if (data['audio_url'] != null && data['audio_url'].isNotEmpty) {
          await _audioService.loadAudio(data['audio_url']);

          // TTS 재생 완료 후 녹음 시작을 위한 콜백 설정
          _audioService.onCompleted = () async {
            if (!mounted) return;

            // 기존 녹음 리소스 정리 및 새로 생성
            if (_isRecording) {
              await _audioRecorder.stop();
            }
            await _amplitudeSubscription?.cancel();
            _amplitudeSubscription = null;
            _silenceTimer?.cancel();
            _silenceTimer = null;
            _audioRecorder.dispose();
            _audioRecorder = AudioRecorder();

            // 대화가 끝나지 않았다면 AI의 새로운 질문을 받아옴
            if (data['should_end'] != true) {
              final nextQuestion = await startConversation(photoId);
              if (!mounted) return;

              final conversation = ConversationResponse.fromJson(nextQuestion);
              setState(() {
                apiResult = conversation.question;
              });

              // AI의 새로운 질문 음성 재생
              if (conversation.audioUrl != null &&
                  conversation.audioUrl.isNotEmpty) {
                await _audioService.loadAudio(conversation.audioUrl);
                await _audioService.play();
                // TTS 재생 완료 후 녹음 시작을 위한 콜백 설정
                _audioService.onCompleted = () {
                  if (mounted) _startRecording();
                };
              } else {
                if (mounted) _startRecording();
              }
            }
          };

          await _audioService.play();
        } else {
          // 음성이 없는 경우 바로 다음 단계 진행
          if (data['should_end'] != true) {
            final nextQuestion = await startConversation(photoId);
            if (!mounted) return;

            final conversation = ConversationResponse.fromJson(nextQuestion);
            setState(() {
              apiResult = conversation.question;
            });

            if (conversation.audioUrl != null &&
                conversation.audioUrl.isNotEmpty) {
              await _audioService.loadAudio(conversation.audioUrl);
              await _audioService.play();
              // TTS 재생 완료 후 녹음 시작을 위한 콜백 설정
              _audioService.onCompleted = () {
                if (mounted) _startRecording();
              };
            } else {
              if (mounted) _startRecording();
            }
          }
        }
      } else {
        print('서버 오류: $responseBody');
      }

      // await file.delete();
    } catch (e, st) {
      print('[에러] 오디오 전송 오류: \\${e}');
      print('[에러] 스택트레이스: \\${st}');
    } finally {
      _isApiCallInProgress = false;
    }
  }

  // Fish-Speech API 호출 함수
  Future<void> _convertVoice(String aVoiceUrl, String summaryText) async {
    try {
      final baseUrl = dotenv.env['BASE_URL']!;
      final url = Uri.parse('$baseUrl/api/chat/convert');

      var request = http.MultipartRequest('POST', url);
      request.fields['conversation_id'] = _conversationId!;
      request.fields['a_voice_url'] = aVoiceUrl;
      request.fields['summary_text'] = summaryText;

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        print('음성 변환 성공: ${data['url']}');

        // 변환된 음성 URL을 저장하고 재생
        if (data['url'] != null) {
          await _audioService.loadAudio(data['url']);
          await _audioService.play();
        }
      } else {
        print('음성 변환 실패: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('음성 변환에 실패했습니다.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('음성 변환 중 오류 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('음성 변환 중 오류가 발생했습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> forceEndConversation() async {
    try {
      final baseUrl = dotenv.env['BASE_URL']!;
      final uri = Uri.parse('$baseUrl/api/chat/force-end');

      var request = http.MultipartRequest('POST', uri);
      request.fields['conversation_id'] = _conversationId ?? '';
      if (apiResult != "Loading...") {
        request.fields['current_question'] = apiResult;
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('✅ 대화 강제 종료 성공');
      } else {
        print('❌ 서버 오류: $responseBody');
      }
    } catch (e) {
      print('🔥 강제 종료 API 호출 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      // 기존 AppBar 대신 커스텀 앱바 적용
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(114),
        child: _buildCustomAppBar(context),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // 챗봇 질문 말풍선 (기존 디자인 반영)
              AssistantBubble(text: apiResult, isActive: isTTSActive),

              // const SizedBox(height: 10),

              // 사진 영역 (375x375) - 기존 PhotoBox 사용
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: PhotoBox(photoPath: photoPath, isNetwork: true),
                ),
              ),

              // const SizedBox(height: 20),

              // 사용자 음성 응답 말풍선
              UserSpeechBubble(text: _recognizedText, isActive: isSTTActive),
            ],
          ),
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

  void showExitModal() async {
    // 모든 작업 취소
    await _cancelAllOperations();

    if (!mounted) return;

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
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _startRecording(); // 대화 계속하기 선택 시 녹음 다시 시작
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
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    try {
                      if (_conversationId != null) {
                        final baseUrl = dotenv.env['BASE_URL']!;
                        final url = Uri.parse('$baseUrl/api/chat/force-end');

                        var request = http.MultipartRequest('POST', url);
                        request.fields['conversation_id'] = _conversationId!;
                        if (apiResult.isNotEmpty) {
                          request.fields['current_question'] = apiResult;
                        }

                        // 5초 타임아웃 설정
                        var response = await request.send().timeout(
                          const Duration(seconds: 5),
                          onTimeout: () {
                            print('force-end API 타임아웃');
                            Navigator.pushReplacementNamed(
                              context,
                              Routes.gallery,
                            );
                            throw TimeoutException('force-end API 타임아웃');
                          },
                        );

                        if (response.statusCode == 200) {
                          print('대화 강제 종료 성공');
                          // 대화 종료 후 음성 변환 요청
                          await _convertVoice(photoUrl, apiResult);
                        } else {
                          print('대화 강제 종료 실패: ${response.statusCode}');
                        }
                      }
                    } catch (e) {
                      print('대화 강제 종료 중 오류 발생: $e');
                    }

                    // 어떤 경우든 갤러리로 이동
                    Navigator.pushReplacementNamed(context, Routes.gallery);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF00C8B8), width: 2),
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
