// 작성자: hyunsung
// 작성일: 25.06.02
// 수정자: OH
// 수정일: 25.06.03

import 'package:flutter/material.dart';
import '../widgets/tap_widget.dart';
import '../widgets/group_bar_widget.dart';
import '../widgets/ai_record_play_sheet.dart';
import '../data/user_data.dart';

class PhotoDetailScreen extends StatelessWidget {
  const PhotoDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // arguments로 전달된 photoId 받기
    // final int photoId = ModalRoute.of(context)!.settings.arguments as int;
    final String imageName =
        ModalRoute.of(context)!.settings.arguments as String;

    // 해당 photoId에 맞는 데이터 찾기
    // final Map<String, dynamic>? photoData = user_photo_data.firstWhere(
    //   (photo) => photo['id'] == photoId,
    //   // orElse: () => null,
    // );
    final Map<String, dynamic>? photoData = user_photo_data
        .cast<Map<String, dynamic>>()
        .firstWhere(
          (photo) => photo['image'].toString().endsWith(imageName),
          // orElse: () => null as Map<String, dynamic>?, // 👈 타입 명시해줘야 오류 안남
        );

    if (photoData == null) {
      return const Scaffold(body: Center(child: Text('해당 사진 정보를 찾을 수 없습니다.')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: const GroupBar(title: user_title),
      body: Column(
        children: [
          // 프로필 섹션
          Container(
            width: double.infinity,
            height: 80,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // 프로필 이미지
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFC9B3), Color(0xFFFFD2C2)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                const SizedBox(width: 16),
                // 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            photoData['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              photoData['role'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        photoData['date'] ?? '',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 메인 이미지
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(photoData['image'] ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 하단 정보
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      photoData['year'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      photoData['season'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  photoData['description'] ?? '',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // 버튼들
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showSummaryModal(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C8B8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          '대화 듣기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/report');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF00C8B8),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          '보고서 보기',
                          style: TextStyle(
                            color: Color(0xFF00C8B8),
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
