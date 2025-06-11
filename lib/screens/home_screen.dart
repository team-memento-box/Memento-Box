import 'package:flutter/material.dart';
import '../widgets/image_card_widget.dart';
import '../widgets/tap_widget.dart';
import 'package:provider/provider.dart';
import '../user_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/photo.dart';

// gallery_screen.dart의 fetchPhotos 함수 복사
Future<List<Photo>> fetchPhotos(BuildContext context) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final accessToken = userProvider.accessToken;
  final baseUrl = dotenv.env['BASE_URL']!;
  final url = Uri.parse('$baseUrl/api/photos/');
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((json) => Photo.fromJson(json)).toList();
  } else {
    throw Exception('사진 목록 불러오기 실패: \\${response.statusCode}');
  }
}

class HomeUpdateScreen extends StatefulWidget {
  const HomeUpdateScreen({super.key});

  @override
  State<HomeUpdateScreen> createState() => _HomeUpdateScreenState();
}

class _HomeUpdateScreenState extends State<HomeUpdateScreen> {
  late Future<List<Photo>> _photosFuture;

  @override
  void initState() {
    super.initState();
    _photosFuture = fetchPhotos(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          title: Consumer<UserProvider>(
            builder: (context, userProvider, child) => Text(
              userProvider.familyName ?? '화목한 우리 가족^~^',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                fontFamily: 'Pretendard',
                letterSpacing: 0,
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF00C8B8),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const ProfileHeader(),
            const SizedBox(height: 20),
            const SectionTitle(title: '최근 소식'),
            const SizedBox(height: 10),
            // 사진 데이터로 NewsCard 리스트 표시
            FutureBuilder<List<Photo>>(
              future: _photosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Text('사진 불러오기 실패');
                }
                final photos = snapshot.data ?? [];
                if (photos.isEmpty) {
                  return const Text('최근 소식이 없습니다.');
                }
                return Column(
                  children: photos.take(5).map<Widget>((photo) => NewsCard(
                    name: photo.user?['name'] ?? '이름 없음',
                    role: photo.user?['family_role'] ?? '역할 없음',
                    content: photo.description ?? '',
                    //assetImagePath: photo.sasUrl ?? photo.url,
                    assetImagePath:photo.url,
                    date: photo.formattedUploadedAt,
                    profileImgUrl: photo.user?['profile_img'] ?? '',
                  )).toList(),
                );
              },
            ),
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
    print('isGuardian: ${userProvider.isGuardian}');
    print('familyName: ${userProvider.familyName}');
    print('familyRole: ${userProvider.familyRole}');
    print('familyId: ${userProvider.familyId}');
    

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xFFFFC9B3),
          backgroundImage: userProvider.profileImg != null && userProvider.profileImg!.isNotEmpty
              ? NetworkImage(userProvider.profileImg!)
              : null,
          child: (userProvider.profileImg == null || userProvider.profileImg!.isEmpty)
              ? const Icon(Icons.person, size: 50, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 7),
        Text(
          userProvider.name ?? '이름 없음',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
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
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
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
