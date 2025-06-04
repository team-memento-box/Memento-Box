// 작성자: OH
// 작성일: 2025.05.30

import 'package:flutter/material.dart';
import '../widgets/tap_widget.dart';
import '../widgets/group_bar_widget.dart';
import '../utils/styles.dart';
import '../data/user_data.dart';

class AddPhotoScreen extends StatelessWidget {
  const AddPhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 포커스 해제 → 키보드 닫힘
      },

      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: const GroupBar(title: user_title),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 연도/계절 선택
                Row(
                  children: const [
                    Text('연도', style: maxContentStyle),
                    SizedBox(width: 20),
                    Text('계절', style: maxContentStyle),
                  ],
                ),
                const SizedBox(height: 20),

                // 사진 업로드 박스
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF00C8B8),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0x1900C8B8),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/Add_fill.png',
                        width: 50,
                        height: 50,
                        color: const Color(0xFF00C8B8), // 덮어씌울 색상
                        colorBlendMode: BlendMode.srcIn,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '사진을 추가해주세요',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00C8B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // 사진 설명 입력 영역
                const Text(
                  '사진 설명',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                TextField(
                  maxLines: 3,
                  maxLength: 100, // 최대 100자까지 입력 가능
                  style: smallContentStyle.copyWith(color: Color(0xFF333333)),
                  decoration: InputDecoration(
                    hintText: '사진에 대해 설명하는 글을 간단하게 작성해주세요.',
                    hintStyle: smallContentStyle.copyWith(
                      color: Color(0xFF777777),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0x66999999)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0x66999999)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 사진 추가 버튼
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C8B8),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      '사진 추가하기',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Pretendard',
                        letterSpacing: 1,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      ),
    );
  }
}
