// 작성자: gwona
// 작성일: 2025.06.05
// 목적: 피보호자 가족 코드 입력 화면 리팩토링

import 'package:flutter/material.dart';

class FamilyCodeInputScreen extends StatefulWidget {
  const FamilyCodeInputScreen({super.key});

  @override
  State<FamilyCodeInputScreen> createState() => _FamilyCodeInputScreenState();
}

class _FamilyCodeInputScreenState extends State<FamilyCodeInputScreen> {
  final TextEditingController codeController = TextEditingController();

  bool get isCodeEntered => codeController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    codeController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            _buildLogo(),
            _buildTextSection(),
            _buildInputField(),
            _buildSubmitButton(),
            _buildHomeIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Positioned(
      top: 153,
      left: 30,
      child: SizedBox(
        width: 88,
        height: 88,
        child: Image.asset("assets/images/temp_logo.png", fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildTextSection() {
    return const Positioned(
      top: 269,
      left: 30,
      right: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안녕하세요 피보호자님,',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w500,
              fontFamily: 'Pretendard',
            ),
          ),
          SizedBox(height: 16),
          Text(
            '보호자님께 전달 받은 가족 코드를 입력해주세요.',
            style: TextStyle(
              fontSize: 19,
              fontFamily: 'Pretendard',
              height: 1.5,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Positioned(
      top: 406,
      left: 30,
      right: 30,
      child: TextField(
        controller: codeController,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Pretendard',
        ),
        decoration: InputDecoration(
          hintText: '가족 코드를 입력해주세요',
          hintStyle: const TextStyle(
            fontSize: 18,
            color: Color(0xFF888888),
            fontFamily: 'Pretendard',
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          filled: true,
          fillColor: Color(0xFFF4F4F4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFAEAEAE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFAEAEAE)),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Positioned(
      top: 482,
      left: 30,
      right: 30,
      child: GestureDetector(
        onTap: isCodeEntered
            ? () {
                print("입력된 코드: \${codeController.text}");
                Navigator.pushNamed(context, '/home2');
              }
            : null,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isCodeEntered
                ? const Color(0xFF00C8B8)
                : const Color(0xFFDFF3F2),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            '가족 코드 입력',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeIndicator() {
    return const Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: 139,
          height: 5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),
          ),
        ),
      ),
    );
  }
}
