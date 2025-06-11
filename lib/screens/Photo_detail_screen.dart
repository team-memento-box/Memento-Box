// 작성자: hyunsung
// 작성일: 25.06.02
// 수정자: OH
// 수정일: 25.06.03

import 'package:flutter/material.dart';
import 'package:memento_box_app/utils/audio_service.dart';
import '../widgets/tap_widget.dart';
import '../widgets/group_bar_widget.dart';
import '../widgets/ai_record_play_sheet.dart';
import '../utils/routes.dart';
import '../utils/audio_service.dart';
import '../utils/styles.dart';
import '../widgets/audio_player_widget.dart';
import '../models/photo.dart'; // ← Photo 모델 import 추가
import 'package:provider/provider.dart'; // ✅ Provider import
import '../user_provider.dart'; // ✅ 사용자 Provider import

class PhotoDetailScreen extends StatefulWidget {
  final Photo photo; // ← Photo 객체 추가

  const PhotoDetailScreen({Key? key, required this.photo}) : super(key: key);

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late AudioService _audioService;
  final audioPath = 'assets/voice/2025-05-26_서봉봉님_대화분석보고서.mp3';

  @override
  void initState() {
    super.initState();
    _audioService = AudioService(); // ✅ 화면 동안만 유지
     // 디버깅용 Photo 객체 출력
    print('=== Photo 객체 디버깅 ===');
    print('id: ${widget.photo.id}');
    print('name: ${widget.photo.name}');
    print('url: ${widget.photo.url}');
    print('year: ${widget.photo.year}');
    print('season: ${widget.photo.season}');
    print('description: ${widget.photo.description}');
    print('familyId: ${widget.photo.familyId}');
    print('uploadedAt: ${widget.photo.uploadedAt}');
    print('sasUrl: ${widget.photo.sasUrl}');
    print('user: ${widget.photo.user}'); // user 전체 Map 출력
    if (widget.photo.user != null) {
      widget.photo.user!.forEach((key, value) {
        print('user[$key]: $value');
      });
    }
    print('=====================');
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final familyName = Provider.of<UserProvider>(context, listen: false).familyName ?? '우리 가족';
    final isGuardian = Provider.of<UserProvider>(context).isGuardian ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: GroupBar(title: familyName), // ← familyName 사용
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: widget.photo.user?['profile_img'] != null
                      ? Image.network(
                          widget.photo.user!['profile_img'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: const Icon(Icons.person, color: Colors.white),
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
                            widget.photo.user?['name'] ?? '', // ← Photo 객체 사용
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
                              widget.photo.user?['family_role'] ?? '', // ← Photo 객체의 user에서 family_role 사용
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.photo.uploadedAt, // ← Photo 객체 사용
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF555555),
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
                  //image: NetworkImage(widget.photo.sasUrl ?? widget.photo.url), // ← Photo 객체 사용
                  image: NetworkImage(widget.photo.url), // ← Photo 객체 사용
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
                      '${widget.photo.year}년', // ← Photo 객체 사용
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _seasonKor(widget.photo.season), // ← Photo 객체 사용
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.photo.description ?? '', // ← Photo 객체 사용
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF555555),
                  ),
                ),
                const SizedBox(height: 20),

                // 버튼들
                Row(
                  children: [
                    Expanded(
                      child: isGuardian
                          ? ElevatedButton(
                              onPressed: () {
                                showSummaryModal(
                                  context,
                                  audioPath: audioPath,
                                  audioService: _audioService,
                                );
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
                            )
                          : ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, Routes.conversation);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00C8B8),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                '대화하기',
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
                          Navigator.pop(context);
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
                          '목록 보기',
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