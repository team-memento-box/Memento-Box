import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/routes.dart';
import '../utils/styles.dart';
import '../user_provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final isGuardian = context.watch<UserProvider>().isGuardian;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF00C8B8),
      unselectedItemColor: const Color(0xFF777777),
      selectedLabelStyle: tapLabelStyle,
      unselectedLabelStyle: tapLabelStyle,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, Routes.home);
            break;
          case 1:
            Navigator.pushReplacementNamed(context, Routes.gallery);
            break;
          case 2:
            Navigator.pushReplacementNamed(context, Routes.quickAdd);
            break;
          case 3:
            Navigator.pushReplacementNamed(context, Routes.report);
            break;
          case 4:
            Navigator.pushReplacementNamed(context, Routes.myPage);
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/Home.png'),
          activeIcon: Image.asset(
            'assets/icons/Home_fill.png',
            color: const Color(0xFF00C8B8), // 덮어씌울 색상
            colorBlendMode: BlendMode.srcIn, // 색상만 입히기
          ),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/Image.png'),
          activeIcon: Image.asset(
            'assets/icons/Image_fill.png',
            color: const Color(0xFF00C8B8), // 덮어씌울 색상
            colorBlendMode: BlendMode.srcIn, // 색상만 입히기
          ),
          label: '사진첩',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            isGuardian == true
                ? 'assets/icons/Add.png'
                : 'assets/icons/Comment-plus.png',
          ),
          activeIcon: Image.asset(
            isGuardian == true
                ? 'assets/icons/Add_fill.png'
                : 'assets/icons/Comment-plus_fill.png',
            color: const Color(0xFF00C8B8), // 덮어씌울 색상
            colorBlendMode: BlendMode.srcIn, // 색상만 입히기
          ),
          label: isGuardian == true ? '사진 추가' : '대화하기',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/Invoice.png'),
          activeIcon: Image.asset(
            'assets/icons/Invoice_fill.png',
            color: const Color(0xFF00C8B8), // 덮어씌울 색상
            colorBlendMode: BlendMode.srcIn, // 색상만 입히기
          ),
          label: '보고서',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/User.png'),
          activeIcon: Image.asset(
            'assets/icons/User_fill.png',
            color: const Color(0xFF00C8B8), // 덮어씌울 색상
            colorBlendMode: BlendMode.srcIn, // 색상만 입히기
          ),
          label: '나의 정보',
        ),

        // BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        // BottomNavigationBarItem(icon: Icon(Icons.photo), label: '사진첩'),
        // BottomNavigationBarItem(icon: Icon(Icons.add), label: '사진 추가'),
        // BottomNavigationBarItem(icon: Icon(Icons.receipt), label: '보고서'),
        // BottomNavigationBarItem(icon: Icon(Icons.person), label: '나의 정보'),
      ],
    );
  }
}
