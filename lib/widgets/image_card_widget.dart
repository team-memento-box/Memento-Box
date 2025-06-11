import 'package:flutter/material.dart';

class NewsCard extends StatelessWidget {
  final String name;
  final String role;
  final String content;
  final String assetImagePath;
  final String date;
  final String profileImgUrl; // 추가
  const NewsCard({
    super.key,
    required this.name,
    required this.role,
    required this.content,
    required this.assetImagePath,
    required this.date,
    required this.profileImgUrl,
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
                leading: (profileImgUrl.isNotEmpty && profileImgUrl.startsWith('http'))
                    ? CircleAvatar(
                        backgroundColor: const Color(0xFFFFC9B3),
                        backgroundImage: NetworkImage(profileImgUrl),
                      )
                    : CircleAvatar(
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
                child: assetImagePath.startsWith('http')
                ? Image.network(
                    assetImagePath,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      height: 150,
                      child: const Icon(Icons.broken_image, size: 50),
                    ),
                  )
                : Image.asset(
                    assetImagePath,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
