// 작성자: OH
// 작성일: 2025.05

import 'package:flutter/material.dart';
import '../widgets/image_card_widget.dart';
import '../widgets/tap_widget.dart';
import '../widgets/group_bar_widget.dart';
import '../data/user_data.dart';
import '../utils/routes.dart';

class HomeUpdateScreen extends StatelessWidget {
  const HomeUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
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

    // TODO: 아래 dummy 데이터는 나중에 API 요청으로 대체 예정
    // final response = await http.get(Uri.parse("http://your-api.com/api/recent_photos"));
    // final List<dynamic> news = json.decode(response.body);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: const GroupBar(title: user_title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const ProfileHeader(),
            const SizedBox(height: 20),
            const SectionTitle(title: '최근 소식'),
            const SizedBox(height: 10),

            // 더미 데이터 반복 출력
            Column(
              children: recentPhotoNews.map((news) {
                final assetImagePath = news['assetImagePath']!;
                final imageName = assetImagePath.split('/').last; // 예: "3.png"

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

            const SizedBox(height: 20),

            // NewsCard(
            //   name: '김땡땡',
            //   role: '딸',
            //   content: '새로운 사진 추가',
            //   assetImagePath: 'assets/photos/2.png',
            //   date: '2025년 5월 25일',
            // ),
            // const SizedBox(height: 15),
            // NewsCard(
            //   name: '서봉봉',
            //   role: '엄마',
            //   content: '새로운 대화 생성',
            //   assetImagePath: 'assets/photos/3.png',
            //   date: '2025년 5월 16일',
            // ),
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
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xFFFFC9B3),
          child: const Icon(Icons.person, size: 50, color: Colors.white),
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
