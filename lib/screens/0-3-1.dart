// 작성자: gwona
// 작성일: 2025.06.05
// 목적: 보호자 가족코드/그룹명/관계 등록 화면 리팩토링

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../user_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../widgets/family_dropdown.dart';

class GroupSelectScreen extends StatelessWidget {
  const GroupSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 시계/상태바 영역 (간단히 텍스트로 대체)
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '9:41',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 안내 문구
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '안녕하세요 보호자님,',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 21,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 1.19,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '메멘토 박스가 처음이신가요?',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 19,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 1.42,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // 가족 그룹 생성하기 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDFF3F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/group_create');
                  },
                  child: const Text(
                    '가족 그룹 생성하기',
                    style: TextStyle(
                      color: Color(0xFF00C8B8),
                      fontSize: 20,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 가족 코드 입력 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C8B8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/group_join');
                  },
                  child: const Text(
                    '가족 코드 입력',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // 하단 안내
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  '이미 가족 그룹이 있으시다면?',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 1.42,
                    letterSpacing: -1,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            const Spacer(),
            // 하단 홈 인디케이터
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Center(
                child: Container(
                  width: 139,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}