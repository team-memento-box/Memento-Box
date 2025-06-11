import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ← Provider import 추가
import '../utils/routes.dart';
import '../utils/styles.dart';
import '../user_provider.dart'; // ← UserProvider import 추가

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final isGuardian = Provider.of<UserProvider>(context).isGuardian;
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
            if (isGuardian == true) {
              Navigator.pushReplacementNamed(context, Routes.gallery);
            } else {
              //Navigator.pushReplacementNamed(context, Routes.request);
              Navigator.pushReplacementNamed(context, Routes.gallery);
            }
            break;
          case 2:
            if (isGuardian == true) {
              Navigator.pushReplacementNamed(context, Routes.addPhoto);
            } else {
              Navigator.pushReplacementNamed(context, Routes.conversation);
              
            }
            break;
          case 3:
            Navigator.pushReplacementNamed(context, Routes.report);
            break;
          case 4:
            Navigator.pushReplacementNamed(context, Routes.profile);
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/Home.png'),
          activeIcon: Image.asset(
            'assets/icons/Home_fill.png',
            color: const Color(0xFF00C8B8),
            colorBlendMode: BlendMode.srcIn,
          ),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/Image.png'),
          activeIcon: Image.asset(
            'assets/icons/Image_fill.png',
            color: const Color(0xFF00C8B8),
            colorBlendMode: BlendMode.srcIn,
          ),
          label: '사진첩',
        ),
        BottomNavigationBarItem(
          icon: isGuardian == true
              ? Image.asset('assets/icons/Add.png')
              : Image.asset('assets/icons/Comment-plus.png'),
          activeIcon: isGuardian == true
              ? Image.asset(
                  'assets/icons/Add_fill.png',
                  color: const Color(0xFF00C8B8),
                  colorBlendMode: BlendMode.srcIn,
                )
              : Image.asset(
                  'assets/icons/Comment-plus_fill.png',
                  color: const Color(0xFF00C8B8),
                  colorBlendMode: BlendMode.srcIn,
                ),
          label: isGuardian == true ? '사진 추가' : '대화하기',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/Invoice.png'),
          activeIcon: Image.asset(
            'assets/icons/Invoice_fill.png',
            color: const Color(0xFF00C8B8),
            colorBlendMode: BlendMode.srcIn,
          ),
          label: '보고서',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/icons/User.png'),
          label: '나의 정보',
        ),
      ],
    );
  }
}