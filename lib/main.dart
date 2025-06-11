import 'package:provider/provider.dart'; // ✅ 추가✅
import '../user_provider.dart'; // ✅ 추가✅
import 'package:flutter/material.dart';
import 'screens/kakao_signin_screen.dart';
import 'package:memento_box_app/screens/home_screen.dart';
import 'screens/signin_screen.dart'; //홍원추가
import 'screens/home_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/add_photo_screen.dart';
import 'screens/conversation_screen.dart'; // ✅ 새ka로 만든 대화 스크린 import
import 'screens/report_list_screen.dart';
import 'screens/report_detail_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // --홍원 추가--
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'; // ✅ 카카오 SDK import
import 'screens/mypage.dart';
import 'screens/0-3-1.dart';
import 'screens/0-3-1-1.dart';
import 'screens/0-3-2.dart';
import 'screens/intro_screen.dart';
import 'screens/add_photo_request.dart';
import 'screens/photo_detail_screen.dart';
import 'screens/voice_test.dart';
//우회용//
import 'dart:io';
import 'package:flutter/material.dart';
import 'models/photo.dart';

//우회용//

//라우트 추가
import 'utils/routes.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides(); //우회용//
  // ✅ .env 파일 로드 (.env 파일은 Memento-Box 폴더에 위치)
  await dotenv.load(fileName: ".env");

  // ✅ 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'],
  );
  
  //runApp(const MyCustomApp());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()), // ✅ 추가✅
      ],
      child: const MyCustomApp(),
    ),
  );
}
class MyCustomApp extends StatelessWidget {
  const MyCustomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memento Box',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'Pretendard'),
      initialRoute: Routes.signin,
      //initialRoute: Routes.voiceTest,
      //initialRoute: Routes.photoDetail,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case Routes.intro:
            return MaterialPageRoute(builder: (_) => const IntroScreen());
          case Routes.request:
            return MaterialPageRoute(builder: (_) => const AddPhotoRequestScreen());
          case Routes.home:
            return MaterialPageRoute(builder: (_) => const HomeUpdateScreen());
          case Routes.signin:
            return MaterialPageRoute(builder: (_) => const SigninScreen());
          case Routes.gallery:
            return MaterialPageRoute(builder: (_) => const GalleryScreen());
          case Routes.addPhoto:
            return MaterialPageRoute(builder: (_) => const AddPhotoScreen());
          case Routes.conversation:
            return MaterialPageRoute(builder: (_) => const PhotoConversationScreen());
          case Routes.kakaoSignin:
            return MaterialPageRoute(builder: (_) => const KakaoSigninScreen());
          case Routes.groupSelect:
            return MaterialPageRoute(builder: (_) => const GroupSelectScreen());
          case Routes.familyCodeInput:
            return MaterialPageRoute(builder: (_) => const FamilyCodeInputScreen());
          case Routes.groupCreate:
            return MaterialPageRoute(builder: (_) => const GroupCreateScreen());
          case Routes.profile:
            return MaterialPageRoute(builder: (_) => const ProfileScreen());
          case Routes.report:
            return MaterialPageRoute(builder: (_) => const ReportListScreen());
          case Routes.reportDetail:
            return MaterialPageRoute(builder: (_) => const ReportDetailScreen());
          case Routes.voiceTest:
            return MaterialPageRoute(builder: (_) => const VoiceRecognitionScreen());
          // case Routes.photoDetail:
          //   return MaterialPageRoute(builder: (_) => const PhotoDetailScreen());
          case Routes.photoDetail:
            final Photo photo = settings.arguments as Photo; // ← Photo 객체 받기
            return MaterialPageRoute(
              builder: (_) => PhotoDetailScreen(photo: photo), // ← Photo 객체 전달
            );
          

          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('❌ 존재하지 않는 경로입니다')),
              ),
            );
        }
      },
    );
  }
}
//우회용..
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}