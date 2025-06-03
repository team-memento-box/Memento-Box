import 'package:flutter/material.dart';
import 'package:memento_box_app/screens/home_screen.dart';
import 'screens/signin_screen.dart';
// import 'screens/home_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/add_photo_screen.dart';
import 'screens/conversation_screen.dart'; // ✅ 새로 만든 대화 스크린 import
import 'screens/intro_screen.dart'; // ✅ 새로 만든 인트로 스크린 import

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      initialRoute: '/home', // ✅ 앱 실행 시 IntroScreen이 처음 뜨도록
      routes: {
        '/home': (context) => const HomeUpdateScreen(),
        '/signin': (context) => const SigninScreen(),
        '/gallery': (context) => const GalleryScreen(),
        '/addphoto': (context) => const AddPhotoScreen(),
        '/conversation': (context) =>
            const PhotoConversationScreen(), // ✅ 0530 고권아 추가
        '/intro': (context) => const IntroScreen(), // ✅ 0530 고권아 추가
      },
    );
  }
}
