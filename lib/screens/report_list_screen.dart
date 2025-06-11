import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../data/user_data.dart';
import '../utils/styles.dart';
import '../widgets/tap_widget.dart';
import '../widgets/group_bar_widget.dart';
import 'report_detail_screen.dart'; // ReportDetailScreen import 추가
import 'package:provider/provider.dart';
import '../user_provider.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({Key? key}) : super(key: key);

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  List<Map<String, String>> analysisFiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalysisFiles();
  }

  Future<void> _loadAnalysisFiles() async {
    try {
      // AssetManifest.json에서 모든 assets 파일 목록 가져오기
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // analysis 폴더의 txt 파일들만 필터링
      final analysisAssets = manifestMap.keys
          .where(
            (String key) =>
                key.startsWith('assets/analysis/') && key.endsWith('.txt'),
          )
          .toList();

      List<Map<String, String>> availableFiles = [];

      for (String assetPath in analysisAssets) {
        try {
          // 파일이 실제로 존재하는지 확인
          await rootBundle.loadString(assetPath);

          // 파일명에서 정보 추출
          final fileName = assetPath.split('/').last.replaceAll('.txt', '');
          final displayTitle = _generateDisplayTitle(fileName);

          availableFiles.add({
            'fileName': fileName,
            'displayTitle': displayTitle,
            'filePath': assetPath,
          });
        } catch (e) {
          print('파일을 읽을 수 없습니다: $assetPath');
        }
      }

      // 날짜순으로 정렬 (최신순)
      availableFiles.sort((a, b) => b['fileName']!.compareTo(a['fileName']!));

      setState(() {
        analysisFiles = availableFiles;
        isLoading = false;
      });
    } catch (e) {
      print('파일 목록을 불러오는 중 오류: $e');
      setState(() {
        analysisFiles = [];
        isLoading = false;
      });
    }
  }

  // 파일명에서 사용자 친화적인 제목 생성
  String _generateDisplayTitle(String fileName) {
    try {
      // 파일명 패턴: "2025-05-26_서봉봉님_대화분석보고서"
      final parts = fileName.split('_');

      if (parts.length >= 2) {
        final datePart = parts[0]; // "2025-05-26"
        final namePart = parts[1]; // "서봉봉님"

        // 날짜 포맷팅 (시간은 임의로 생성하거나 기본값 사용)
        final dateTime = _parseDate(datePart);
        final timeString = _generateTimeString(fileName);

        return '$datePart $timeString $namePart 대화 분석 보고서';
      } else {
        // 패턴이 맞지 않으면 파일명 그대로 사용
        return fileName.replaceAll('_', ' ');
      }
    } catch (e) {
      // 오류 발생 시 파일명 그대로 반환
      return fileName.replaceAll('_', ' ');
    }
  }

  // 날짜 파싱
  DateTime? _parseDate(String dateString) {
    try {
      final dateParts = dateString.split('-');
      if (dateParts.length == 3) {
        return DateTime(
          int.parse(dateParts[0]), // year
          int.parse(dateParts[1]), // month
          int.parse(dateParts[2]), // day
        );
      }
    } catch (e) {
      print('날짜 파싱 오류: $e');
    }
    return null;
  }

  // 파일명 기반으로 시간 문자열 생성 (해시를 이용한 일관된 시간)
  String _generateTimeString(String fileName) {
    // 파일명의 해시를 이용해 일관된 시간 생성
    final hash = fileName.hashCode.abs();
    final hour = (hash % 12) + 9; // 9시-20시 범위
    final minute = (hash ~/ 100) % 60; // 0-59분 범위

    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final familyName = Provider.of<UserProvider>(context).familyName ?? '우리 가족';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GroupBar(title: familyName),
      body: Column(
        children: [
          // Content Area
          Expanded(
            child: Container(
              color: const Color(0xFFF7F7F7),
              child: Column(
                children: [
                  const ContentHeaderWidget(),
                  Expanded(
                    child: ReportListWidget(
                      analysisFiles: analysisFiles,
                      isLoading: isLoading,
                      onRefresh: _loadAnalysisFiles,
                    ),
                  ),
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

// TODO: 나중에 API에서 받아온 설정 데이터로 대체
// 예시: appConfig = await fetchAppConfig();
class AppConstants {
  // TODO: 실제 앱 제목은 API에서 받아올 예정
  static const String appTitle = '시발^~^';

  // TODO: 실제 보고서 관련 텍스트는 API에서 받아올 예정
  static const String reportTitle = '2025-05-26 13:56 서봉봉님 대화 분석 보고서';
  static const String warningMessage =
      '비정상적인 상태가 의심되는 경우 병원에 방문해 정확한 진단을 진행해주세요.';
  static const String infoMessage =
      'AI가 대화를 분석해 평가한 상태 분석 보고서를 제공합니다.\n본 보고서는 참고 자료이며, 절대적인 해석이 아님을 유의해 주세요.';

  // TODO: 에러 메시지들도 API에서 받아와서 다국어 지원 예정
  static const String noReportsMessage = '분석 보고서가 없습니다.';
  static const String addFilesMessage = 'assets/analysis/ 폴더에 .txt 파일을 추가하세요.';
  static const String refreshButtonText = '새로고침';
}

// TODO: 실제 앱 설정 정보를 가져오는 함수 예시 (나중에 사용 예정)
// Future<Map<String, dynamic>> fetchAppConfig() async {
//   final response = await http.get(Uri.parse('${API_BASE_URL}/app-config'));
//   return json.decode(response.body);
// }

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
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Color(0x19777777), blurRadius: 5, spreadRadius: 0),
        ],
      ),
      child: Text(
        AppConstants.infoMessage,
        textAlign: TextAlign.center,
        style: smallContentStyle.copyWith(fontSize: 13),
      ),
    );
  }
}

// 보고서 리스트 위젯 (수정됨)
class ReportListWidget extends StatelessWidget {
  final List<Map<String, String>> analysisFiles;
  final bool isLoading;
  final VoidCallback onRefresh;

  const ReportListWidget({
    Key? key,
    required this.analysisFiles,
    required this.isLoading,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (analysisFiles.isEmpty) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TODO: 빈 상태 메시지는 API에서 받아올 예정
              Text(
                AppConstants.noReportsMessage,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppConstants.addFilesMessage,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRefresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text(
                  AppConstants.refreshButtonText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: analysisFiles.length,
          itemBuilder: (context, index) {
            final fileInfo = analysisFiles[index];

            return ReportItemWidget(
              isSelected: index == 0,
              displayTitle: fileInfo['displayTitle']!,
              fileName: fileInfo['fileName']!,
              filePath: fileInfo['filePath']!,
              // 추가: 전체 리포트 목록과 현재 인덱스 전달
              allReports: analysisFiles,
              currentIndex: index,
            );
          },
        ),
      ),
    );
  }
}

// 개별 보고서 아이템 위젯 (수정됨 - 클릭 기능 추가)
class ReportItemWidget extends StatelessWidget {
  final bool isSelected;
  final String displayTitle;
  final String fileName;
  final String filePath;
  final List<Map<String, String>>? allReports; // 추가
  final int? currentIndex; // 추가

  const ReportItemWidget({
    Key? key,
    this.isSelected = false,
    required this.displayTitle,
    required this.fileName,
    required this.filePath,
    this.allReports, // 추가
    this.currentIndex, // 추가
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 상세 보고서 화면으로 이동하면서 전체 리포트 목록과 현재 인덱스도 전달
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailScreen(
              fileName: displayTitle,
              filePath: filePath,
              allReports: allReports, // 추가
              currentIndex: currentIndex, // 추가
            ),
          ),
        );
      },
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: isSelected ? AppColors.primary : const Color(0x7F777777),
              width: isSelected ? 2 : 1.5,
            ),
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x19555555), blurRadius: 5, spreadRadius: 2),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
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
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),

      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.primary, width: 2)),
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
        ),
      ),
    );
  }
}
