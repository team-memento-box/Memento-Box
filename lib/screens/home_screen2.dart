import 'package:flutter/material.dart';
import 'conversation_screen.dart';

class HomeUpdateScreen2 extends StatelessWidget {
  const HomeUpdateScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: CustomAppBar(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const ProfileHeader(),
            const SizedBox(height: 20),
            const SectionTitle(title: '최근 소식'),
            const SizedBox(height: 10),
            NewsCard(
              name: '김땡땡',
              role: '딸',
              content: '새로운 사진 추가',
              assetImagePath: 'assets/photos/2.png',
              date: '2025년 5월 25일',
            ),
            const SizedBox(height: 15),
            NewsCard(
              name: '서봉봉',
              role: '엄마',
              content: '새로운 대화 생성',
              assetImagePath: 'assets/photos/3.png',
              date: '2025년 5월 16일',
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}

// 커스텀 앱바 위젯
class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        '화목한 우리 가족^~^',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w800,
          fontFamily: 'Pretendard',
          letterSpacing: 0,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFF00C8B8),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFFFFC9B3),
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 7),
        const Text(
          '김 땡 땡',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 1),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF777777),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '딸',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// 뉴스 카드 위젯 (누락되었던 위젯)
class NewsCard extends StatelessWidget {
  final String name;
  final String role;
  final String content;
  final String assetImagePath;
  final String date;

  const NewsCard({
    super.key,
    required this.name,
    required this.role,
    required this.content,
    required this.assetImagePath,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 프로필 이미지 또는 아이콘
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF00C8B8),
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                assetImagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 텍스트 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF777777),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        role,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF555555),
                    fontFamily: 'Pretendard',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                    fontFamily: 'Pretendard',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 커스텀 하단 네비게이션 바 위젯
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final List<BottomNavItem> navItems = [
      BottomNavItem(label: '홈', icon: Icons.home),
      BottomNavItem(label: '사진첩', icon: Icons.photo_library),
      BottomNavItem(label: '대화하기', icon: Icons.add_comment),
      BottomNavItem(label: '보고서', icon: Icons.description),
      BottomNavItem(label: '나의 정보', icon: Icons.person),
    ];

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.3), width: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: navItems.asMap().entries.map((entry) {
          int index = entry.key;
          BottomNavItem item = entry.value;
          bool isSelected = index == currentIndex;

          return _buildNavItem(context, item, isSelected, index);
        }).toList(),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    BottomNavItem item,
    bool isSelected,
    int index,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          // 네비게이션 로직 추가
          switch (index) {
            case 0:
              // 현재 페이지이므로 아무것도 하지 않음
              break;
            case 1:
              Navigator.pushNamed(context, '/gallery');
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PhotoConversationScreen(),
                ),
              );
              break;
            case 3:
              Navigator.pushNamed(context, '/report');
              break;
            case 4:
              // 나의 정보 페이지 (라우트 추가 필요)
              break;
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 30,
              color: isSelected
                  ? const Color(0xFF00C8B8)
                  : const Color(0xFF555555),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF00C8B8)
                    : const Color(0xFF555555),
                fontSize: 12,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 하단 네비게이션 아이템 모델
class BottomNavItem {
  final String label;
  final IconData icon;

  BottomNavItem({required this.label, required this.icon});
}
