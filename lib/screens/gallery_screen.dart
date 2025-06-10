// 작성자: OH
// 작성일: 2025.05
// 수정일: 2025.06.03

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/group_bar_widget.dart';
import '../widgets/tap_widget.dart';
import '../utils/styles.dart';
import '../user_provider.dart';
import '../utils/routes.dart';
import '../models/photo.dart';

//photo.dart 파일 생성했음
// class Photo {
//   final String id;
//   final String? name;
//   final String url;
//   final int year;
//   final String season;
//   final String? description;
//   final dynamic summaryText;
//   final dynamic summaryVoice;
//   final String familyId;
//   final String uploadedAt;

//   Photo({
//     required this.id,
//     this.name,
//     required this.url,
//     required this.year,
//     required this.season,
//     this.description,
//     this.summaryText,
//     this.summaryVoice,
//     required this.familyId,
//     required this.uploadedAt,
//   });

//   factory Photo.fromJson(Map<String, dynamic> json) {
//     return Photo(
//       id: json['id'],
//       name: json['name'],
//       url: json['url'],
//       year: json['year'],
//       season: json['season'],
//       description: json['description'],
//       summaryText: json['summary_text'],
//       summaryVoice: json['summary_voice'],
//       familyId: json['family_id'],
//       uploadedAt: json['uploaded_at'],
//     );
//   }
// }

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

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late Future<List<Photo>> _photosFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPhotos());
  }

  void _loadPhotos() {
    setState(() {
      _photosFuture = fetchPhotos(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: GroupBar(
        title: Provider.of<UserProvider>(context, listen: false).familyName ?? '우리 가족',
      ),
      body: FutureBuilder<List<Photo>>(
        future: _photosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('에러: \\${snapshot.error}'));
          }
          final photos = snapshot.data ?? [];
          if (photos.isEmpty) {
            return const Center(child: Text('사진이 없습니다.'));
          }
          // 연도, 계절별로 그룹화
          final grouped = <String, List<Photo>>{};
          for (var photo in photos) {
            final key = '${photo.year}년 ${_seasonKor(photo.season)}';
            grouped.putIfAbsent(key, () => []).add(photo);
          }
          return ListView(
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(entry.key, style: maxContentStyle),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: entry.value.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.49,
                    ),
                    itemBuilder: (context, index) {
                      final photo = entry.value[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            Routes.photoDetail,
                            arguments: photo, // Photo 객체 전달
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            photo.sasUrl ?? photo.url,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  String _seasonKor(String eng) {
    switch (eng) {
      case 'spring':
        return '봄';
      case 'summer':
        return '여름';
      case 'autumn':
        return '가을';
      case 'winter':
        return '겨울';
      default:
        return eng;
    }
  }
}
