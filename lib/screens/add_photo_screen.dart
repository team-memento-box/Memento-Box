import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/tap_widget.dart';

class AddPhotoScreen extends StatefulWidget {
  const AddPhotoScreen({super.key});

  @override
  State<AddPhotoScreen> createState() => _AddPhotoScreenState();
}

class _AddPhotoScreenState extends State<AddPhotoScreen> {
  // 연도/계절 상태
  final List<String> years = ['2023', '2024', '2025', '2026', '2027'];
  final List<String> seasons = ['봄', '여름', '가을', '겨울'];

  int selectedYearIndex = 2; // 기본값 2025
  int selectedSeasonIndex = 1; // 기본값 여름

  void _showYearSeasonPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String selectedText =
        '${years[selectedYearIndex]} ${seasons[selectedSeasonIndex]}';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C8B8),
        elevation: 0,
        toolbarHeight: 80,
        title: const Text(
          '화목한 우리 가족^~^',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontFamily: 'Pretendard',
          ),
        ),
        centerTitle: true,
      ),
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
                    const Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 사진 업로드 박스
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00C8B8), width: 3),
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0x1900C8B8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '사진을 추가해주세요',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00C8B8),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 사진 설명 입력 영역
              const Text(
                '사진 설명',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x66999999)),
                  color: Colors.white,
                ),
                child: const Text(
                  '사진에 대해 설명하는 글을 간단하게 작성해주세요.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
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
    );
  }
}
