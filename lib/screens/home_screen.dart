// 작성자: OH
// 작성일: 2025.05

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/image_card_widget.dart';
import '../widgets/tap_widget.dart';
import '../widgets/group_bar_widget.dart';
import '../data/user_data.dart';
import '../utils/routes.dart';
import '../user_provider.dart';

class HomeUpdateScreen extends StatelessWidget {
  const HomeUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final userProvider = context.watch<UserProvider>();

    final List<Map<String, String>> recentPhotoNews = [
      {
        'name': '김땡땡',
        'role': '딸',
        'content': '새로운 사진 추가',
        'assetImagePath': 'assets/photos/3.png',
        'date': '2025년 5월 25일',
      },
      {
        'name': '서봉봉',
        'role': '엄마',
        'content': '새로운 대화 생성',
        'assetImagePath': 'assets/photos/3.png',
        'date': '2025년 5월 16일',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: GroupBar(title: userProvider.familyName ?? '화목한 우리 가족'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ProfileHeader(),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SectionTitle(title: '최근 소식'),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              // 더미 데이터 반복 출력
              child: Column(
                children: recentPhotoNews.map((news) {
                  final assetImagePath = news['assetImagePath']!;
                  final imageName = assetImagePath
                      .split('/')
                      .last; // 예: "3.png"

                  return Column(
                    children: [
                      NewsCard(
                        name: news['name']!,
                        role: news['role']!,
                        content: news['content']!,
                        assetImagePath: assetImagePath,
                        date: news['date']!,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.photoDetail,
                            arguments: imageName, // 예: "3.png"
                          );
                        },
                      ),
                      const SizedBox(height: 20), // 원하는 간격 만큼 높이 지정
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider에서 데이터 읽어오기
    final userProvider = Provider.of<UserProvider>(context);
    print('ProfileHeader - Provider 데이터:');
    print('kakaoId: ${userProvider.kakaoId}');
    print('username: ${userProvider.name}');
    print('profileImg: ${userProvider.profileImg}');
    print('gender: ${userProvider.gender}');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // 배경색
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(
              10,
              231,
              231,
              231,
            ).withOpacity(0.3), // 그림자 색
            spreadRadius: 7, // 그림자 번짐 정도
            blurRadius: 10, // 흐림 정도
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFFFC9B3),
            backgroundImage:
                userProvider.profileImg != null &&
                    userProvider.profileImg!.isNotEmpty
                ? NetworkImage(userProvider.profileImg!)
                : null,
            child:
                (userProvider.profileImg == null ||
                    userProvider.profileImg!.isEmpty)
                ? const Icon(Icons.person, size: 50, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 7),
          Text(
            userProvider.name ?? '이름 없음',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 5.0,
            ),
          ),
          const SizedBox(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF777777),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              userProvider.familyRole ?? '역할 없음',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
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
