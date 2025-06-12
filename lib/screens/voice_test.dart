import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'dart:io';
import 'dart:async';
import 'dart:convert';

class VoiceRecognitionScreen extends StatefulWidget {
  const VoiceRecognitionScreen({super.key});

  @override
  State<VoiceRecognitionScreen> createState() => _VoiceRecognitionScreenState();
}

class _VoiceRecognitionScreenState extends State<VoiceRecognitionScreen> {
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String _recognizedText = '';
  String? _recordingPath;
  Timer? _silenceTimer;
  StreamSubscription<Amplitude>? _amplitudeSubscription;

  // 무음 감지 설정
  final double _silenceThreshold = -15.0; // dB 단위
  final int _silenceDuration = 2000; // 밀리초 단위 (2초)

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
      final hasPermission = await _requestPermissions();

      if (hasPermission) {
        final directory = await getTemporaryDirectory();
        _recordingPath =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';

        await _audioRecorder.start(
          RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: _recordingPath!,
        );

        setState(() {
          _isRecording = true;
          _recognizedText = '';
        });

        _startAmplitudeMonitoring();
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

  void _startAmplitudeMonitoring() {
    _amplitudeSubscription?.cancel();

    _amplitudeSubscription = _audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 300))
        .listen((amplitude) {
          print('현재 dB: ${amplitude.current}'); // dB값 로그
          if (amplitude.current < _silenceThreshold) {
            if (_silenceTimer == null || !_silenceTimer!.isActive) {
              print('무음 타이머 시작');
              _silenceTimer = Timer(
                Duration(milliseconds: _silenceDuration),
                () {
                  if (_isRecording) {
                    print('무음 지속 ${_silenceDuration}ms, 녹음 중지 시도');
                    _stopRecording();
                  }
                },
              );
            }
          } else {
            if (_silenceTimer != null) print('소리 감지, 타이머 취소');
            _silenceTimer?.cancel();
            _silenceTimer = null;
          }
        });
  }

  Future<void> _stopRecording() async {
    try {
      print('녹음 중지 시도');
      _silenceTimer?.cancel();
      await _amplitudeSubscription?.cancel();

      await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });

      if (_recordingPath != null) {
        print('녹음 파일 경로: $_recordingPath');
        await _sendAudioToBackend();
      }
    } catch (e) {
      print('녹음 중지 오류: $e');
    }
  }

  Future<void> _sendAudioToBackend() async {
    try {
      final baseUrl = dotenv.env['BASE_URL']!;
      final file = File(_recordingPath!);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/speech/speech-to-text'),
      );

      request.files.add(await http.MultipartFile.fromPath('audio', file.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        setState(() {
          _recognizedText = data['text'] ?? '';
        });
      } else {
        print('서버 오류: $responseBody');
      }

      // await file.delete();
    } catch (e) {
      print('오디오 전송 오류: $e');
    }
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _amplitudeSubscription?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('음성 인식')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _recognizedText.isEmpty ? '버튼을 눌러 말씀해주세요' : _recognizedText,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _startRecording,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red : Colors.blue,
                ),
                child: Icon(
                  _isRecording ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
