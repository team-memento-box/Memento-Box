import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:memento_box_app/screens/figma2flutter-add_photo_sorting.dart';
import '../widgets/tap_widget.dart';
import '../widgets/group_bar_widget.dart';
import '../utils/styles.dart';
import '../data/user_data.dart';

class AddPhotoScreen extends StatefulWidget {
  const AddPhotoScreen({super.key});

  @override
  State<AddPhotoScreen> createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  bool isSelected = false;

  // 연도/계절 상태
  final List<String> years = ['2023', '2024', '2025', '2026', '2027'];
  final List<String> seasons = ['봄', '여름', '가을', '겨울'];

  int selectedYearIndex = 2; // 기본값 2025
  int selectedSeasonIndex = 1; // 기본값 여름

  void _showYearSeasonPicker() {
    String selectedText =
        '${years[selectedYearIndex]} ${seasons[selectedSeasonIndex]}';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(230, 255, 255, 255),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '연도 계절 선택',
                    style: maxContentStyle.copyWith(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  // Icon(Icons.arrow_forward_ios_rounded),
                ],
              ),

              SizedBox(
                height: 240,
                child: Row(
                  children: [
                    // 연도 선택
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedYearIndex,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedYearIndex = index;
                          });
                        },
                        children: years
                            .map(
                              (y) => Center(
                                child: Text(
                                  y,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    // 계절 선택
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedSeasonIndex,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedSeasonIndex = index;
                          });
                        },
                        children: seasons
                            .map(
                              (s) => Center(
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String selectedText =
        '${years[selectedYearIndex]} ${seasons[selectedSeasonIndex]}';

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
                GestureDetector(
                  onTap: _showYearSeasonPicker,
                  child: Row(
                    children: [
                      Text(
                        selectedText,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 5),
                      const Icon(Icons.arrow_forward_ios_rounded),
                    ],
                  ),
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
