import 'package:flutter/material.dart';
import '../widgets/tap_widget.dart';
import '../widgets/group_bar_widget.dart';
import '../data/user_data.dart';

class ReportListScreen extends StatelessWidget {
  const ReportListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: const GroupBar(title: user_title),
      body: Column(
        children: [
          // Content Area
          Expanded(
            child: Container(
              color: const Color(0xFFF7F7F7),
              child: Column(
                children: [
                  const ContentHeaderWidget(),
                  Expanded(child: const ReportListWidget()),
                  const WarningMessageWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}

// 상수 정의
class AppConstants {
  static const String reportTitle = '2025-05-26 13:56 서봉봉님 대화 분석 보고서';
  static const String warningMessage =
      '비정상적인 상태가 의심되는 경우 병원에 방문해 정확한 진단을 진행해주세요.';
  static const String infoMessage =
      'AI가 대화를 분석해 평가한 상태 분석 보고서를 제공합니다.\n본 보고서는 참고 자료이며, 절대적인 해석이 아님을 유의해 주세요.';
}

// 색상 테마
class AppColors {
  static const Color primary = Color(0xFF00C8B8);
  static const Color background = Color(0xFFF7F7F7);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF555555);
  static const Color warning = Color(0xFFE25430);
  static const Color border = Color(0x7F999999);
  static const Color shadow = Color(0x33555555);
}

// 컨텐츠 헤더 위젯
class ContentHeaderWidget extends StatelessWidget {
  const ContentHeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: const [
          BoxShadow(color: Color(0x19777777), blurRadius: 5, spreadRadius: 0),
        ],
      ),
      child: const Text(
        AppConstants.infoMessage,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w600,
          height: 1.23,
        ),
      ),
    );
  }
}

// 보고서 리스트 위젯
class ReportListWidget extends StatelessWidget {
  const ReportListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 1, // 원본에서 8개의 동일한 아이템이 있었음
        itemBuilder: (context, index) {
          return ReportItemWidget(
            isSelected: index == 0, // 첫 번째 아이템을 선택된 상태로
          );
        },
      ),
    );
  }
}

// 개별 보고서 아이템 위젯 (클릭 기능 추가)
class ReportItemWidget extends StatelessWidget {
  final bool isSelected;

  const ReportItemWidget({Key? key, this.isSelected = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 상세 보고서 화면으로 이동
        Navigator.pushNamed(context, '/reportDetail');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: isSelected ? AppColors.primary : const Color(0x7F111111),
              width: isSelected ? 2 : 1,
            ),
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x19555555), blurRadius: 5, spreadRadius: 0),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                AppConstants.reportTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 화살표 아이콘 추가
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// 경고 메시지 위젯
class WarningMessageWidget extends StatelessWidget {
  const WarningMessageWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: const [
          BoxShadow(color: Color(0x19777777), blurRadius: 5, spreadRadius: 0),
        ],
      ),
      child: const Text(
        AppConstants.warningMessage,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.warning,
          fontSize: 12,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
      ),
    );
  }
}
