// 작성자: gwona
// 작성일: 2025.06.05
// 목적: 보호자 가족코드/그룹명/관계 등록 화면 리팩토링

import 'package:flutter/material.dart';
import '../data/user_data.dart';

class FamilyCodeRegisterScreen extends StatefulWidget {
  const FamilyCodeRegisterScreen({super.key});

  @override
  State<FamilyCodeRegisterScreen> createState() =>
      _FamilyCodeRegisterScreenState();
}

class _FamilyCodeRegisterScreenState extends State<FamilyCodeRegisterScreen> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController codeOutputController = TextEditingController();
  final TextEditingController codeInputController = TextEditingController();
  FamilyRole? selectedFamilyRelation;

  bool get isFormFilled =>
      groupNameController.text.isNotEmpty &&
      codeOutputController.text.isNotEmpty &&
      codeInputController.text.isNotEmpty &&
      selectedFamilyRelation != null;

  void _generateCode() {
    final code =
        'DA${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    setState(() {
      codeOutputController.text = code;
    });
  }

  void _handleSubmit() {
    if (isFormFilled) {
      Navigator.pushNamed(context, '/home'); // 보호자 전용이므로 바로 홈으로
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            _buildTitle(),
            _buildSubtitle(),
            _buildGroupNameField(),
            _buildGenerateButton(),
            _buildCodeDisplayField(),
            _buildInfoText(),
            _buildCodeInputField(),
            _buildRelationDropdown(),
            _buildSubmitButton(),
            _buildHomeIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Positioned(
      top: 94,
      left: 30,
      child: Text(
        '안녕하세요 보호자님,',
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w500,
          fontFamily: 'Pretendard',
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Positioned(
      top: 140,
      left: 30,
      child: Text(
        '메멘토 박스가 처음이신가요?\n가족 그룹명과 가족 코드를 발급해주세요',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w500,
          fontFamily: 'Pretendard',
          height: 1.42,
          letterSpacing: -1,
        ),
      ),
    );
  }

  Widget _buildGroupNameField() {
    return Positioned(
      top: 217,
      left: 24,
      right: 24,
      child: _buildTextField(groupNameController, '(가족 그룹명 입력 칸)'),
    );
  }

  Widget _buildGenerateButton() {
    return Positioned(
      top: 292,
      left: 24,
      right: 24,
      child: GestureDetector(
        onTap: _generateCode,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFDFF3F2),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: const Text(
            '가족 코드 발급',
            style: TextStyle(
              color: Color(0xFF00C8B8),
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeDisplayField() {
    return Positioned(
      top: 367,
      left: 24,
      right: 24,
      child: _buildTextField(codeOutputController, '(가족 코드 뜨는 칸)'),
    );
  }

  Widget _buildInfoText() {
    return const Positioned(
      top: 454,
      left: 30,
      child: Text(
        '다른 가족 분께 가족 코드를 받으셨다면,',
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w500,
          fontFamily: 'Pretendard',
          height: 1.42,
          letterSpacing: -1,
        ),
      ),
    );
  }

  Widget _buildCodeInputField() {
    return Positioned(
      top: 490,
      left: 24,
      right: 24,
      child: _buildTextField(codeInputController, '(가족 코드 입력 칸)'),
    );
  }

  Widget _buildRelationDropdown() {
    return Positioned(
      top: 564,
      left: 24,
      right: 24,
      child: DropdownButtonFormField<FamilyRole>(
        value: selectedFamilyRelation,
        items: FamilyRole.values.map((role) {
          return DropdownMenuItem(value: role, child: Text(role.label));
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedFamilyRelation = value;
          });
        },
        decoration: InputDecoration(
          hintText: '피보호자와의 관계를 선택해주세요',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFAEAEAE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFAEAEAE)),
          ),
        ),
        icon: const Icon(Icons.arrow_drop_down),
        dropdownColor: Colors.white,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Positioned(
      top: 640,
      left: 24,
      right: 24,
      child: GestureDetector(
        onTap: isFormFilled ? _handleSubmit : null,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isFormFilled
                ? const Color(0xFF00C8B8)
                : const Color(0xFFDFF3F2),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: const Text(
            '가족 코드 입력',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Pretendard',
      ),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFAEAEAE)),
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
