// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import '../user_provider.dart';
// import '../widgets/family_dropdown.dart';

// class GroupJoinScreen extends StatefulWidget {
//   const GroupJoinScreen({super.key});

//   @override
//   State<GroupJoinScreen> createState() => _GroupJoinScreenState();
// }

// class _GroupJoinScreenState extends State<GroupJoinScreen> {
//   final TextEditingController codeInputController = TextEditingController();
//   String? error;
//   String? familyId;
//   String? familyCode;
//   bool showRelationDropdown = false;

//   Future<void> _joinFamily() async {
//     final code = codeInputController.text.trim();
//     final baseUrl = dotenv.env['BASE_URL']!;
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/join_family'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'family_code': code}),
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           familyId = data['family_id'];
//           familyCode = data['family_code'];
          
//           showRelationDropdown = true;
//         });
//         Provider.of<UserProvider>(context, listen: false).setFamilyJoin(
//           familyId: data['family_id'],
//           familyCode: data['family_code'],
//           familyName: data['family_name'],  // Provider에도 저장
//         );
//         error = null;
//       } else {
//         setState(() {
//           error = '가족 코드가 올바르지 않습니다.';
//           showRelationDropdown = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         error = '네트워크 오류: $e';
//         showRelationDropdown = false;
//       });
//     }
//   }
//   Future<void> _onRelationSelected(String? value) async {
//     if (value != null && value.isNotEmpty) {
//       final userProvider = Provider.of<UserProvider>(context, listen: false);
//       userProvider.setFamilyInfo(familyRole: value);
//       final userData = {
//         'kakao_id': userProvider.kakaoId,
//         'username': userProvider.username,
//         'profile_img': userProvider.profileImg,
//         'gender': userProvider.gender,
//         'birthday': userProvider.birthday,
//         'family_id': userProvider.familyId,
//         'family_code': userProvider.familyCode,
//         'family_role': userProvider.familyRole,
//         'created_at': userProvider.createdAt,
//         'is_guardian': userProvider.isGuardian,
//       };
//       try {
//         final baseUrl = dotenv.env['BASE_URL']!;
//         final response = await http.post(
//           Uri.parse('$baseUrl/register_user'),
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode(userData),
//         );
//         if (response.statusCode == 200) {
//           Navigator.pushNamed(context, '/intro');
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('회원정보 저장 실패: \n${response.body}')),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('네트워크 오류: $e')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: codeInputController,
//               decoration: InputDecoration(
//                 hintText: '가족 코드 입력',
//                 errorText: error,
//               ),
//             ),
//             ElevatedButton(
//               onPressed: _joinFamily,
//               child: Text('가족 코드 확인'),
//             ),
//             if (showRelationDropdown)
//               Padding(
//                 padding: const EdgeInsets.only(top: 24.0),
//                 child: FamilyRelationDropdown(
//                   onChanged: _onRelationSelected,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }