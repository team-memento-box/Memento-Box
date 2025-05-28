import 'package:flutter/material.dart';
import 'package:memento_box_app/screens/home_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/add_photo_screen.dart';

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
      initialRoute: '/home', // 초기 화면 경로
      routes: {
        '/home': (context) => const HomeUpdateScreen(),
        // '/signin': (context) => const SigninScreen(),
        '/gallery': (context) => const GalleryScreen(),
        '/addphoto': (context) => const AddPhotoScreen(),
        // 필요 시 다른 화면들도 여기에 추가
      },
    );
  }
}
