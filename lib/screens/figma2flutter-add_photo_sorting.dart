import 'package:flutter/material.dart';

class figma2flutter_addPhotoSorting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 375,
          height: 812,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 375,
                  height: 812,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ),
              Positioned(
                left: 0,
                top: 54,
                child: Container(
                  width: 375,
                  height: 739,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 375,
                          height: 739,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        top: 598,
                        child: Container(
                          width: 335,
                          height: 60,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF00C8B8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 121.03,
                        top: 617,
                        child: SizedBox(
                          width: 134,
                          child: Text(
                            '사진 추가하기',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w800,
                              height: 1,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 120,
                child: Container(
                  width: 375,
                  height: 38,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 20,
                        top: 8,
                        child: Text(
                          '연도',
                          style: TextStyle(
                            color: const Color(0xFF111111),
                            fontSize: 25,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                            height: 0.88,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 78,
                        top: 8,
                        child: Text(
                          '계절',
                          style: TextStyle(
                            color: const Color(0xFF111111),
                            fontSize: 25,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                            height: 0.88,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 164,
                        top: -2,
                        child: Container(
                          transform: Matrix4.identity()
                            ..translate(0.0, 0.0)
                            ..rotateZ(1.57),
                          height: 42,
                          child: Stack(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 169,
                child: Container(
                  width: 335,
                  height: 250,
                  decoration: ShapeDecoration(
                    color: const Color(0x1900C8B8),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 3,
                        color: const Color(0xFF00C8B8),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 66,
                top: 306,
                child: SizedBox(
                  width: 243,
                  height: 29,
                  child: Text(
                    '사진을 추가해주세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF00C8B8),
                      fontSize: 25,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: 1.28,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 439,
                child: Container(
                  width: 375,
                  height: 126,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 20,
                        top: 8,
                        child: Text(
                          '사진 설명',
                          style: TextStyle(
                            color: const Color(0xFF111111),
                            fontSize: 21,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            height: 1.05,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        top: 44,
                        child: Container(
                          width: 335,
                          height: 77,
                          decoration: ShapeDecoration(
                            color: Colors.white.withValues(alpha: 26),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: const Color(0x66999999),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Color(0x19000000),
                                blurRadius: 5,
                                offset: Offset(0, 0),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 33,
                        top: 58,
                        child: Container(
                          width: 310,
                          height: 46,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 2,
                                child: SizedBox(
                                  width: 310,
                                  child: Text(
                                    '사진에 대해 설명하는 글을 간단하게 작성해주세요.',
                                    style: TextStyle(
                                      color: const Color(0xFF333333),
                                      fontSize: 15,
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                      height: 1.47,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 90,
                top: 40.12,
                child: SizedBox(
                  width: 195,
                  height: 45.76,
                  child: Text(
                    '화목한 우리 가족^~^',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w800,
                      height: 0.92,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 104,
                child: Container(
                  width: 375,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 0.70,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: const Color(0x7F999999),
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x33555555),
                        blurRadius: 10,
                        offset: Offset(0, -1),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 375,
                  height: 733,
                  decoration: BoxDecoration(color: const Color(0x33111111)),
                ),
              ),
              Positioned(
                left: 0,
                top: 446,
                child: Container(
                  width: 375,
                  height: 366,
                  decoration: ShapeDecoration(
                    color: Colors.white.withValues(alpha: 242),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: const Color(0x7F999999)),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x19555555),
                        blurRadius: 20,
                        offset: Offset(0, 0),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 470,
                child: Container(
                  width: 375,
                  height: 42,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 122,
                        top: 13.94,
                        child: Text(
                          '여름',
                          style: TextStyle(
                            color: const Color(0xFF111111),
                            fontSize: 25,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                            height: 0.88,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 27,
                        top: 13.94,
                        child: SizedBox(
                          width: 85,
                          height: 19.30,
                          child: Text(
                            '2025년',
                            style: TextStyle(
                              color: const Color(0xFF111111),
                              fontSize: 25,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                              height: 0.88,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 208,
                        top: 3,
                        child: Container(
                          transform: Matrix4.identity()
                            ..translate(0.0, 0.0)
                            ..rotateZ(1.57),
                          height: 42,
                          child: Stack(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 23,
                top: 540,
                child: Container(
                  width: 150,
                  height: 154,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 58,
                        child: Container(
                          width: 150,
                          height: 42,
                          decoration: ShapeDecoration(
                            color: const Color(0x7F555555),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 33,
                        top: 135,
                        child: SizedBox(
                          width: 85,
                          height: 23,
                          child: Text(
                            '2027',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF333333),
                              fontSize: 20,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              height: 1.10,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 33,
                        top: 106,
                        child: SizedBox(
                          width: 85,
                          height: 23,
                          child: Text(
                            '2026',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF333333),
                              fontSize: 20,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              height: 1.10,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 33,
                        top: 68,
                        child: SizedBox(
                          width: 85,
                          height: 23,
                          child: Text(
                            '2025',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 33,
                        top: 29,
                        child: SizedBox(
                          width: 85,
                          height: 23,
                          child: Text(
                            '2024',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF333333),
                              fontSize: 20,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              height: 1.10,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 33,
                        top: 0,
                        child: SizedBox(
                          width: 85,
                          height: 23,
                          child: Text(
                            '2023',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF333333),
                              fontSize: 20,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              height: 1.10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 203,
                top: 540,
                child: Container(
                  width: 150,
                  height: 154,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 58,
                        child: Container(
                          width: 150,
                          height: 42,
                          decoration: ShapeDecoration(
                            color: const Color(0x7F555555),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 33,
                        top: 135,
                        child: SizedBox(
                          width: 85,
                          height: 23,
                          child: Text(
                            '겨울',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF333333),
                              fontSize: 20,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              height: 1.10,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 33,
                        top: 106,
                        child: SizedBox(
                          width: 85,
                          height: 23,
                          child: Text(
                            '가을',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF333333),
                              fontSize: 20,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              height: 1.10,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 33,
                        top: 29,
                        child: SizedBox(
                          width: 85,
                          height: 23,
                          child: Text(
                            '봄',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF333333),
                              fontSize: 20,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              height: 1.10,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 33,
                        top: 0,
                        child: SizedBox(
                          width: 85,
                          height: 23,
                          child: Text(
                            ' ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF333333),
                              fontSize: 20,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              height: 1.10,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 33,
                        top: 68,
                        child: SizedBox(
                          width: 85,
                          height: 23,
                          child: Text(
                            '여름',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 188,
                top: 711,
                child: Container(
                  transform: Matrix4.identity()
                    ..translate(0.0, 0.0)
                    ..rotateZ(-1.57),
                  width: 185,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: const Color(0x7F111111),
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x33333333),
                        blurRadius: 10,
                        offset: Offset(0, 0),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 300,
                top: 732,
                child: Container(
                  width: 75,
                  height: 80,
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ),
              Positioned(
                left: 323,
                top: 738,
                child: Container(width: 30, height: 30, child: Stack()),
              ),
              Positioned(
                left: 315,
                top: 764,
                child: Text(
                  '나의 정보',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF555555),
                    fontSize: 12,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 2.33,
                  ),
                ),
              ),
              Positioned(
                left: 225,
                top: 732,
                child: Container(
                  width: 75,
                  height: 80,
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ),
              Positioned(
                left: 248,
                top: 738,
                child: Container(width: 30, height: 30, child: Stack()),
              ),
              Positioned(
                left: 247,
                top: 764,
                child: Text(
                  '보고서',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF555555),
                    fontSize: 12,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 2.33,
                  ),
                ),
              ),
              Positioned(
                left: 150,
                top: 732,
                child: Container(
                  width: 75,
                  height: 80,
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ),
              Positioned(
                left: 165,
                top: 764,
                child: Text(
                  '사진 추가',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF555555),
                    fontSize: 12,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 2.33,
                  ),
                ),
              ),
              Positioned(
                left: 173,
                top: 738,
                child: Container(width: 30, height: 30, child: Stack()),
              ),
              Positioned(
                left: 75,
                top: 732,
                child: Container(
                  width: 75,
                  height: 80,
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ),
              Positioned(
                left: 98,
                top: 738,
                child: Container(width: 30, height: 30, child: Stack()),
              ),
              Positioned(
                left: 97,
                top: 764,
                child: Text(
                  '사진첩',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF555555),
                    fontSize: 12,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 2.33,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 732,
                child: Container(
                  width: 75,
                  height: 80,
                  decoration: BoxDecoration(color: Colors.white),
                ),
              ),
              Positioned(
                left: 32,
                top: 764,
                child: Text(
                  '홈',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF555555),
                    fontSize: 12,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 2.33,
                  ),
                ),
              ),
              Positioned(
                left: 23,
                top: 738,
                child: Container(width: 30, height: 30, child: Stack()),
              ),
              Positioned(
                left: 0,
                top: 732,
                child: Container(
                  width: 375,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 0.70,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: const Color(0x7F999999),
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x33555555),
                        blurRadius: 10,
                        offset: Offset(0, 1),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: -9,
                top: 791,
                child: Container(
                  width: 393,
                  height: 21,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 266,
                        top: 13,
                        child: Container(
                          transform: Matrix4.identity()
                            ..translate(0.0, 0.0)
                            ..rotateZ(3.14),
                          width: 139,
                          height: 5,
                          decoration: ShapeDecoration(
                            color: Colors.black /* Labels-Primary */,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: -9,
                top: 0,
                child: Container(
                  width: 393,
                  height: 54,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 393,
                          height: 54,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: Container(
                                  width: 140.50,
                                  height: 54,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 51.92,
                                        top: 18.34,
                                        child: Text(
                                          '9:41',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors
                                                .black /* Labels-Primary */,
                                            fontSize: 17,
                                            fontFamily: 'SF Pro',
                                            fontWeight: FontWeight.w600,
                                            height: 1.29,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 252.50,
                                top: 0,
                                child: Container(
                                  width: 140.50,
                                  height: 54,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 81,
                                        top: 23,
                                        child: Opacity(
                                          opacity: 0.35,
                                          child: Container(
                                            width: 25,
                                            height: 13,
                                            decoration: ShapeDecoration(
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: Colors
                                                      .black /* Labels-Primary */,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4.30),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 83,
                                        top: 25,
                                        child: Container(
                                          width: 21,
                                          height: 9,
                                          decoration: ShapeDecoration(
                                            color: Colors
                                                .black /* Labels-Primary */,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(2.50),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
