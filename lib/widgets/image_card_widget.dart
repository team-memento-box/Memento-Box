// 작성자: OH
// 작성일: 2025.05

import 'package:flutter/material.dart';

class NewsCard extends StatelessWidget {
  final String name;
  final String role;
  final String content;
  final String assetImagePath;
  final String date;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.name,
    required this.role,
    required this.content,
    required this.assetImagePath,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: const TextStyle(
            fontSize: 17,
            color: Color(0xFF555555),
            fontWeight: FontWeight.w600,
            fontFamily: 'Pretendard',
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(color: Color(0x19000000), blurRadius: 15),
            ],
            color: Colors.white,
          ),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFFFC9B3),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  '$name',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                  ),
                ),
                subtitle: Text(
                  content,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF777777),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                child: GestureDetector(
                  onTap: onTap, // 👉 여기에서 이벤트 실행
                  child: Image.asset(
                    assetImagePath,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
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
