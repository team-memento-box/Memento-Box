import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? kakaoId;
  String? name;
  String? profileImg;
  String? gender;
  String? birthday;
  String? email;
  String? phone;
  String? familyId;    // families.id (UUID)
  String? familyCode;  // families.family_code (8자리 코드)
  String? familyName;  // families.family_name (가족 그룹명)
  String? familyRole;
  String? createdAt;
  bool? isGuardian;

  // 보호자/피보호자 선택
  void setIsGuardian(bool value) {
    isGuardian = value;
    notifyListeners();
  }

  // 카카오 로그인 후 사용자 정보 저장
  void setUserInfo({
    required String kakaoId,
    required String name,
    required String profileImg,
    required String gender,
    String? birthday,
    String? email,
    String? phone,
  }) {
    this.kakaoId = kakaoId;
    this.name = name;
    this.profileImg = profileImg;
    this.gender = gender;
    this.birthday = birthday;
    this.email = email;
    this.phone = phone;
    notifyListeners();
  }

  // 가족코드 발급(그룹 생성) 시 familyId, familyCode, familyName 저장
  void setFamilyCreate({
    required String familyId,
    required String familyCode,
    required String familyName,
  }) {
    this.familyId = familyId;
    this.familyCode = familyCode;
    this.familyName = familyName;
    notifyListeners();
  }

  // 가족코드 입력(가입) 시 familyId, familyCode 저장
 void setFamilyJoin({
    required String familyId,
    required String familyCode,
    required String familyName,
  }) {
    this.familyId = familyId;
    this.familyCode = familyCode;
    this.familyName = familyName;
    notifyListeners();
  }

  // 가족 내 역할, 생성일 등 추가 정보 저장
  void setFamilyInfo({
    String? familyRole,
    String? createdAt,
  }) {
    if (familyRole != null) this.familyRole = familyRole;
    if (createdAt != null) this.createdAt = createdAt;
    notifyListeners();
  }

  // 전체 정보 초기화
  void clearUser() {
    kakaoId = null;
    name = null;
    profileImg = null;
    gender = null;
    birthday = null;
    email = null;
    phone = null;
    familyId = null;
    familyCode = null;
    familyName = null;
    familyRole = null;
    createdAt = null;
    isGuardian = null;
    notifyListeners();
  }
}