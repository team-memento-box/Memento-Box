import 'package:flutter/material.dart';
import '../utils/styles.dart';
import 'origin_record_play_sheet.dart';
import 'audio_player_widget.dart';
import '../utils/audio_service.dart';

// 'assets/voice/2025-05-26_서봉봉님_대화분석보고서.mp3';

void showSummaryModal(
  BuildContext context, {
  required String audioPath,
  required AudioService audioService,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color.fromARGB(230, 255, 255, 255),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (_) =>
        SummaryModal(audioPath: audioPath, audioService: audioService),
  );
}

class SummaryModal extends StatefulWidget {
  final String audioPath;
  final AudioService audioService;

  const SummaryModal({
    super.key,
    required this.audioPath,
    required this.audioService,
  });

  @override
  State<SummaryModal> createState() => _SummaryModalState();
}

class _SummaryModalState extends State<SummaryModal>
    with SingleTickerProviderStateMixin {
  bool showTranscript = false;

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
                '2025년 5월 16일 대화 요약본',
                style: mainContentStyle,
                textAlign: TextAlign.center,
              ),
              if (showTranscript)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () {
                      setState(() => showTranscript = false);
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
              //     Slider(
              //       value: 92,
              //       max: 209,
              //       activeColor: const Color(0xFF00C8B8),
              //       onChanged: (_) {},
              //     ),
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: const [
              //         Text('01:32', style: TextStyle(fontSize: 12)),
              //         Text('03:29', style: TextStyle(fontSize: 12)),
              //       ],
              //     ),
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
              children: [
                if (!showTranscript)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => showTranscript = true);
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
                      const SizedBox(width: 13),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context); // 현재 모달 닫기
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                if (context.mounted) {
                                  showOriginalModal(
                                    context,
                                    audioPath: widget.audioPath,
                                    audioService: widget.audioService,
                                  ); // 새 모달 열기
                                }
                              },
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF00C8B8),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text(
                            '원본 듣기',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF00C8B8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (showTranscript)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF00C8B8),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '대화 요약:',
                          style: TextStyle(
                            color: Color(0xFF00C8B8),
                            fontSize: 14,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '옛날 국민 학교 다닐 시절에 친구들하고 삼삼오오 모여서 공기놀이를 자주 하곤 했지. 근데 할머니가 영 실력이 없어서 항상 콧수염을 붙이는 벌칙을 했어. 그때 참 재미있었는데...',
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        // SizedBox(height: 5),
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
