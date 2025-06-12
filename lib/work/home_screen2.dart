// import 'package:flutter/material.dart';
// import '../widgets/image_card_widget.dart';
// import '../widgets/tap_widget.dart';
// import 'package:provider/provider.dart';
// import '../user_provider.dart';

// class HomeUpdateScreen2 extends StatelessWidget {
//   const HomeUpdateScreen2({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final width = size.width;
//     final height = size.height;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7F7),
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(80.0),
//         child: AppBar(
//           title: Consumer<UserProvider>(
//             builder: (context, userProvider, child) => Text(
//               userProvider.familyName ?? '화목한 우리 가족^~^',
//               style: const TextStyle(
//                 fontSize: 25,
//                 fontWeight: FontWeight.w800,
//                 fontFamily: 'Pretendard',
//                 letterSpacing: 0,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           centerTitle: true,
//           backgroundColor: const Color(0xFF00C8B8),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const ProfileHeader(),
//             const SizedBox(height: 20),
//             const SectionTitle(title: '최근 소식'),
//             const SizedBox(height: 10),
//             NewsCard(
//               name: '김땡땡',
//               role: '딸',
//               content: '새로운 사진 추가',
//               assetImagePath: 'assets/photos/2.png',
//               date: '2025년 5월 25일',
//             ),
//             const SizedBox(height: 15),
//             NewsCard(
//               name: '서봉봉',
//               role: '엄마',
//               content: '새로운 대화 생성',
//               assetImagePath: 'assets/photos/3.png',
//               date: '2025년 5월 16일',
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
//     );
//   }
// }

// class ProfileHeader extends StatelessWidget {
//   const ProfileHeader({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Provider에서 데이터 읽어오기
//     final userProvider = Provider.of<UserProvider>(context);
//     print('ProfileHeader - Provider 데이터:');
//     print('kakaoId: ${userProvider.kakaoId}');
//     print('username: ${userProvider.username}');
//     print('profileImg: ${userProvider.profileImg}');
//     print('gender: ${userProvider.gender}');

//     return Column(
//       children: [
//         CircleAvatar(
//           radius: 50,
//           backgroundColor: const Color(0xFFFFC9B3),
//           backgroundImage: userProvider.profileImg != null && userProvider.profileImg!.isNotEmpty
//               ? NetworkImage(userProvider.profileImg!)
//               : null,
//           child: (userProvider.profileImg == null || userProvider.profileImg!.isEmpty)
//               ? const Icon(Icons.person, size: 50, color: Colors.white)
//               : null,
//         ),
//         const SizedBox(height: 7),
//         Text(
//           userProvider.username ?? '이름 없음',
//           style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
//         ),
//         const SizedBox(height: 1),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
//           decoration: BoxDecoration(
//             color: const Color(0xFF777777),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             userProvider.gender == 'male' ? '아들' : '딸',
//             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class SectionTitle extends StatelessWidget {
//   final String title;
//   const SectionTitle({super.key, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Text(
//         title,
//         style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
//       ),
//     );
//   }
// }
