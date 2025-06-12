import 'package:flutter/material.dart';
import '../utils/styles.dart';
import 'ai_record_play_sheet.dart';
import 'audio_player_widget.dart';
import '../utils/audio_service.dart';

void showOriginalModal(
  BuildContext context, {
  required String audioPath,
  required AudioService audioService,
}) {
  print('📢 원본 시트 불러오기');
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color.fromARGB(230, 255, 255, 255),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (_) =>
        OriginalModal(audioPath: audioPath, audioService: audioService),
  );
}

class OriginalModal extends StatefulWidget {
  final String audioPath;
  final AudioService audioService;

  const OriginalModal({
    super.key,
    required this.audioPath,
    required this.audioService,
  });

  @override
  State<OriginalModal> createState() => _OriginalModalState();
}

class _OriginalModalState extends State<OriginalModal>
    with SingleTickerProviderStateMixin {
  bool showAllTranscript = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                '2025년 5월 16일 대화 원본',
                style: mainContentStyle,
                textAlign: TextAlign.center,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () {
                    if (showAllTranscript)
                      setState(() => showAllTranscript = false);
                    if (!showAllTranscript) {
                      Navigator.pop(context); // 현재 모달 닫기
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (context.mounted) {
                          showSummaryModal(
                            context,
                            audioPath: widget.audioPath,
                            audioService: widget.audioService,
                          ); // 새 모달 열기
                        }
                      });
                    }
                  },
                ),
              ),
              // const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              AudioPlayerWidget(
                audioPath: widget.audioPath,
                audioService: widget.audioService,
              ),
              // Slider(
              //   value: 92,
              //   max: 209,
              //   activeColor: const Color(0xFF00C8B8),
              //   onChanged: (_) {},
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: const [
              //     Text('01:32', style: TextStyle(fontSize: 12)),
              //     Text('03:29', style: TextStyle(fontSize: 12)),
              //   ],
              // ),
            ],
          ),
          // const SizedBox(height: 16),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: const [
          //     Icon(Icons.skip_previous, size: 32, color: Colors.black),
          //     SizedBox(width: 30),
          //     Icon(Icons.play_arrow, size: 48, color: Color(0xFF00C8B8)),
          //     SizedBox(width: 30),
          //     Icon(Icons.skip_next, size: 32, color: Colors.black),
          //   ],
          // ),
          const SizedBox(height: 10),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!showAllTranscript)
                  SizedBox(
                    width: double.infinity, // 너비만 확장하고 싶을 때
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => showAllTranscript = true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C8B8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        '내용 보기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                if (showAllTranscript)
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF00C8B8),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      children: [
                        _chatBubble("어르신, 이 사진 언제 찍었는지 기억 나세요?", isBot: true),
                        _chatBubble("응 당연하지~ 스무 살 때 서울 구경가서 찍었을 거야"),
                        _chatBubble(
                          "스무 살 때 서울 구경이라니, 정말 설레는 순간이었겠어요. 그날 가장 기억에 남는 일이 있다면 뭐였을까요?",
                          isBot: true,
                        ),
                        _chatBubble("음, 아무래도 순이랑 남대문 시장 돌아다닌 게 제일 기억에 남아."),
                        _chatBubble("사람도 많고, 물건도 많고…"),
                        _chatBubble("하늘색 원피스 하나 사서 신나서 입고 다녔어."),
                        _chatBubble(
                          "하늘색 원피스를 입고 친구랑 웃으면서 걸었을 모습이 그려져요. 순이는 어떤 친구였어요?",
                          isBot: true,
                        ),
                        _chatBubble(
                          "정말 말도 많고, 잘 웃는 애였고 나랑 성격은 다르지만 이상하게 잘 맞았어.",
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _chatBubble(String text, {bool isBot = false}) {
  return Align(
    alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
    child: Row(
      mainAxisAlignment: isBot
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isBot)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF00C8B8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
          ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: const BoxConstraints(maxWidth: 280),
            decoration: BoxDecoration(
              color: isBot ? Colors.grey.shade200 : const Color(0xFF00C8B8),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isBot ? 0 : 16),
                bottomRight: Radius.circular(isBot ? 16 : 0),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isBot ? Colors.black87 : Colors.white,
                fontSize: 16,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
