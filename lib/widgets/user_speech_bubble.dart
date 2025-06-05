import 'package:flutter/material.dart';

class UserSpeechBubble extends StatelessWidget {
  final String text;
  final bool isActive;

  const UserSpeechBubble({
    required this.text,
    required this.isActive,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(Icons.mic, size: 36, color: isActive ? Colors.orange : Colors.grey),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFDEDEDE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Pretendard',
                  height: 1.25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
