import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; //* 'front' branch 코드 추가
import 'package:flutter_dotenv/flutter_dotenv.dart'; //* 'front' branch 코드 추가
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'; // ✅ 카카오 SDK import //* 'front' branch 코드 추가

import '../user_provider.dart'; //* 'front' branch 코드 추가
import 'utils/routes.dart'; // 화면 연결 관리 파일

import 'screens/start_select_screen.dart'; // 보호자/피보호자 선택 화면
import 'screens/kakao_signin_screen.dart'; // 카카오 로그인 화면
import 'screens/group_select_screen.dart'; // 그룹 입력 화면

import 'screens/home_screen.dart'; // 홈 화면
import 'screens/add_photo_screen.dart'; // 사진 추가 화면
import 'screens/gallery_screen.dart'; // 사진첩 화면
import 'screens/photo_detail_screen.dart'; // 사진 상세정보 화면
import 'screens/conversation_screen.dart'; // 피보호자-AI 대화 화면
import 'screens/report_list_screen.dart'; // 보고서 목록 화면
import 'screens/report_detail_screen.dart'; // 보고서 상세보기 화면

import 'screens/group_code_input_screen.dart';
import 'screens/mypage_screen.dart';
import 'screens/group_create_screen.dart';
import 'screens/group_code_input_screen.dart';
//우회용// //* 'front' branch 코드 추가
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
    // javaScriptAppKey: dotenv.env['KAKAO_JS_APP_KEY'],
  );
  print("KAKAO_NATIVE_APP_KEY: ${dotenv.env['KAKAO_NATIVE_APP_KEY']}");
  // print("KAKAO_JS_APP_KEY: ${dotenv.env['KAKAO_JS_APP_KEY']}");

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
      home: const StartSelectScreen(),
      routes: {
        Routes.home: (context) => const HomeUpdateScreen(),
        Routes.startSelect: (context) => const StartSelectScreen(),
        Routes.gallery: (context) => const GalleryScreen(),
        Routes.addPhoto: (context) => const AddPhotoScreen(),
        Routes.conversation: (context) => const PhotoConversationScreen(),
        Routes.kakaoSignIn: (context) => const KakaoSigninScreen(),
        Routes.groupSelect: (context) => const GroupSelectScreen(),
        Routes.groupCodeInput: (context) => const GroupCodeInputScreen(),

        Routes.groupCreate: (context) => const GroupCreateScreen(),

        Routes.myPage: (context) => const MyPageScreen(),
        // // ✅ 잘못된 경로 대비 fallback
        // return MaterialPageRoute(
        //   builder: (context) =>
        //       const Scaffold(body: Center(child: Text('❌ 존재하지 않는 경로입니다'))),
        // );
      },
    );
  }
}

//우회용..
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const MyCustomApp());
// }

// class MyCustomApp extends StatelessWidget {
//   final bool isSenior = false;

//   const MyCustomApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Memento Box',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'Pretendard'),
//       initialRoute: Routes.home, // ✅ 앱 실행 시 IntroScreen이 처음 뜨도록
//       routes: {
//         Routes.home: (context) => const HomeUpdateScreen(),
//         // Routes.home2: (context) => const HomeUpdateScreen2(),
//         Routes.startSelect: (context) => const StartSelectScreen(),
//         // Routes.signUp: (context) => const KakaoSigninScreen(userType: ???),
//         Routes.familycodeGuardian: (context) =>
//             const FamilyCodeRegisterScreen(),
//         Routes.familycodeElderly: (context) => const FamilyCodeInputScreen(),
//         Routes.gallery: (context) => const GalleryScreen(),
//         Routes.addPhoto: (context) => const AddPhotoScreen(),
//         Routes.conversation: (context) =>
//             const PhotoConversationScreen(), // ✅ 0530 고권아 추가
//         // Routes.intro: (context) => const IntroScreen(), // ✅ 0530 고권아 추가
//         Routes.report: (context) => const FamilyChatAnalysisScreen(),
//         Routes.reportDetail: (context) => const ReportDetailScreen(),
//         Routes.photoDetail: (context) => const PhotoDetailScreen(),
//         // Routes.listenRec: (context) => const ConversationPlaybackScreen(),
//         // '/pictureGuardianListen': (context) => const PictureGuardianLlmScreen(),
//       },
//     );
//   }
// }
