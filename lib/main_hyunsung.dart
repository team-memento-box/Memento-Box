import 'package:flutter/material.dart';
import 'package:memento_box_app/screens/home_screen.dart';
// import 'screens/signin_screen.dart';
// import 'screens/home_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/add_photo_screen.dart';
import 'screens/conversation_screen.dart'; // ✅ 새로 만든 대화 스크린 import
import 'screens/intro_screen.dart'; // ✅ 새로 만든 인트로 스크린 import
import 'screens/report_main.dart'; // ✅ 새로 만든 보고서 스크린 import
import 'screens/report_detail.dart'; // ✅ 새로 만든 보고서 상세 스크린 import
import 'screens/2-2.dart'; // ✅ 새로 만든 사진 보호자 스크린 import
import 'screens/2-3.dart'; // ✅ 새로 만든 사진 보호자 듣기 스크린 import
import 'screens/2-3-1.dart'; // ✅ 새로 만든 대화 내용 스크린 import
import 'screens/2-3-3.dart'; // ✅ 새로 만든 가족 채팅 분석 스크린 import
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'screens/kakao_signin_screen.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: ".env");
  // runApp(const MyCustomApp());
  runApp(const MyCustomApp());
}

class MyCustomApp extends StatelessWidget {
  const MyCustomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memento Box',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'Pretendard'),
      initialRoute: '/pictureGuardian', // ✅ 앱 실행 시 보고서 목록이 처음 뜨도록
      routes: {
        // '/kakao': (context) => const KakaoSigninScreen(), // ✅ 카카오 로그인 화면 라우트 추가
        '/home': (context) => const HomeUpdateScreen(),
        '/gallery': (context) => const GalleryScreen(),
        '/addphoto': (context) => const AddPhotoScreen(),
        '/conversation': (context) => const PhotoConversationScreen(),
        '/intro': (context) => const IntroScreen(),
        '/report': (context) => const FamilyChatAnalysisScreen(),
        '/reportDetail': (context) =>
            const ReportDetailScreen(), // ✅ 보고서 상세 화면 라우트 추가
        '/pictureGuardian': (context) => const PhotoDetailScreen(),
        '/pictureGuardianListen': (context) =>
            const ConversationPlaybackScreen(),
        '/conversationTranscript': (context) =>
            const ConversationTranscriptScreen(), // ✅ 대화 내용 화면 라우트 추가
        '/pictureGuardianLLM': (context) =>
            const PictureGuardianLlmScreen(), // ✅ 가족 채팅 분석 화면 라우트 추가
      },
    );
  }
}
