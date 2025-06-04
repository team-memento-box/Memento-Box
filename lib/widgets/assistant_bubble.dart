import 'package:flutter/material.dart';

class AssistantBubble extends StatelessWidget {
  final String text;
  final bool isActive;

  const AssistantBubble({
    required this.text,
    required this.isActive,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.orange : Colors.transparent,
              border: isActive ? Border.all(color: Colors.orange, width: 3) : null,
            ),
            child: const CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage('assets/images/chatbot_profile.png'),
              backgroundColor: Colors.transparent,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDEDEDE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Pretendard',
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
