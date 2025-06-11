// 0603 고권아 작업
// 사용자 챗봇 화면
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

// TTS, STT 기능이 동작 중인지 여부를 저장하는 상태 변수
bool isTTSActive = false;
bool isSTTActive = false;

class _PhotoConversationScreenState extends State<PhotoConversationScreen> {
  late String photoId;
  late String photoUrl;

  String apiResult = 'Loading...';

  String assistantText = '초기 텍스트';
  String photoPath = '초기 url';

  @override
  void initState() {
    super.initState();
    photoId = widget.photoId;
    photoUrl = widget.photoUrl;
    print('photoId: $photoId');
    print('photoUrl: $photoUrl');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startConversation();
    });
  }

  Future<void> _startConversation() async {
    try {
      final jsonData = await startConversation(photoId);
      final conversation = ConversationResponse.fromJson(jsonData);

      assistantText = conversation.question;
      photoPath = conversation.photoInfo.url;
      // print('Question: ${conversation.question}');
      // print('Photo URL: ${conversation.photoInfo.url}');

      setState(() {
        apiResult = conversation.question; // 또는 원하는 값을 화면에 보여주기 위해 저장
      });
    } catch (e) {
      print('❌ API error: $e');
      setState(() {
        apiResult = 'API failed: $e';
      });
    }
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
              // const SizedBox(height: 30),

              // // 기존에 표시하던 photoId 텍스트
              // Text(
              //   'Photo ID: $photoId',
              //   style: const TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),

              // const SizedBox(height: 10),

              // // 기존에 있던 photoUrl 이미지 (있는 경우만)
              // if (photoUrl.isNotEmpty)
              //   Center(
              //     child: Image.network(
              //       photoUrl,
              //       width: 200,
              //       height: 200,
              //       fit: BoxFit.cover,
              //     ),
              //   ),

              // const SizedBox(height: 20),

              // // 기존에 표시하던 API 결과 텍스트
              // Text(
              //   'API result:\n$apiResult',
              //   style: const TextStyle(fontSize: 16),
              // ),
              const SizedBox(height: 20),

              // 챗봇 질문 말풍선 (기존 디자인 반영)
              AssistantBubble(text: assistantText, isActive: isTTSActive),

              // const SizedBox(height: 10),

              // 사진 영역 (375x375) - 기존 PhotoBox 사용
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: PhotoBox(photoPath: photoPath, isNetwork: true),
                ),
              ),

              const SizedBox(height: 80),

              // // 사용자 음성 응답 말풍선
              // UserSpeechBubble(text: userSpeechText, isActive: isSTTActive),
            ],
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text('대화 시작')),
  //     body: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Text('Photo ID: ${widget.photoId}'),
  //         Image.network(widget.photoUrl),
  //       ],
  //     ),
  //   );
  // }

  /*
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _initConversation(context);
    // });
  }

  Future<void> _initConversation(BuildContext context) async {
    try {
      // API 호출해서 질문 받아오기
      final jsonString = await startConversation(photoId);
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final questionData = QuestionData.fromJson(jsonMap);

      final questionTxt = questionData.question; // 질문 텍스트
      final audioUrl = questionData.audioUrl;
      final conversationId = questionData.conversationId;
      final isContinuation = questionData.isContinuation;

      final photoData = PhotoInfo.fromJson(questionData.photoInfo);
      final objPhotoUrl = photoData.url;
      final objPhotoName = photoData.name;
      final objPhotoId = photoData.id;

      print('=== 대화 객체 디버깅 ===');
      print('questionTxt: ${questionTxt}');
      print('audioUrl: ${audioUrl}');
      print('conversationId: ${conversationId}');
      print('isContinuation: ${isContinuation}');

      setState(() {
        assistantText = questionTxt;
        // 기존 더미 userSpeechText, photoPath 등도 같이 초기화 가능
        audioPath = audioUrl; // 필요에 따라 세팅
        photoPath = objPhotoUrl;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        assistantText = '대화 시작 중 오류가 발생했습니다.';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(114),
        child: Column(
          children: [
            _buildCustomAppBar(context), // 상단 타이틀 바
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 30),

            // 챗봇 질문 말풍선
            AssistantBubble(text: assistantText, isActive: isTTSActive),
            // const SizedBox(height: 30),

            // 사진 영역 (375x375)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: PhotoBox(photoPath: photoPath),
            ),
            // const SizedBox(height: 80),

            // 사용자 음성 응답 말풍선
            UserSpeechBubble(text: userSpeechText, isActive: isSTTActive),
          ],
        ),
      ),
    );
  }
*/
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

  void showExitModal() {
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
                width: double.infinity, // 너비만 확장하고 싶을 때
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
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
                width: double.infinity, // 너비만 확장하고 싶을 때
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, Routes.gallery);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: const Color(0xFF00C8B8),
                      width: 2,
                    ),
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
