import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? kakaoId;
  String? username;
  String? email;
  String? profileImg;
  String? gender;

  void setUser({
    required String kakaoId,
    required String username,
    required String email,
    required String profileImg,
    required String gender,
  }) {
    this.kakaoId = kakaoId;
    this.username = username;
    this.email = email;
    this.profileImg = profileImg;
    this.gender = gender;
    notifyListeners();
  }

  void clearUser() {
    kakaoId = null;
    username = null;
    email = null;
    profileImg = null;
    gender = null;
    notifyListeners();
  }
}
