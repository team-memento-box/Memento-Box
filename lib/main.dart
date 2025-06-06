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
import 'screens/intro_screen.dart'; // ✅ 새로 만든 인트로 스크린 import
import 'package:flutter_dotenv/flutter_dotenv.dart'; // --홍원 추가--
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'; // ✅ 카카오 SDK import
//우회용//
import 'dart:io';
import 'package:flutter/material.dart';
//우회용//
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
      initialRoute: '/signin', 
      // ✅ [onGenerateRoute] 사용으로 변경
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/intro')) {
          return MaterialPageRoute(builder: (context) => const IntroScreen());
        }
        if (settings.name == '/home') {
          return MaterialPageRoute(builder: (context) => const HomeUpdateScreen());
        }
        if (settings.name == '/signin') {
          return MaterialPageRoute(builder: (context) => const SigninScreen());
        }
        if (settings.name == '/gallery') {
          return MaterialPageRoute(builder: (context) => const GalleryScreen());
        }
        if (settings.name == '/addphoto') {
          return MaterialPageRoute(builder: (context) => const AddPhotoScreen());
        }
        if (settings.name == '/conversation') {
          return MaterialPageRoute(builder: (context) => const PhotoConversationScreen());
        }
        if (settings.name == '/kakao_signin') {
          return MaterialPageRoute(builder: (context) => const KakaoSigninScreen());
        }
        // ✅ 잘못된 경로 대비 fallback
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('❌ 존재하지 않는 경로입니다')),
          ),
        );
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