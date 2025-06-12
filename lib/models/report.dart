import 'package:uuid/uuid.dart';

class Report {
  final String reportId;
  final String convId;
  final String? anomalyReport;
  final dynamic anomalyTurn;
  final DateTime? created_at;
  final String? imageUrl;
  // 필요에 따라 필드 추가

  Report({
    required this.reportId,
    required this.convId,
    this.anomalyReport,
    this.anomalyTurn,
    this.created_at,
    this.imageUrl,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    final rawReport = json['anomalyReport'];
    String? safeReport;
    if (rawReport == null) {
      safeReport = null;
    } else if (rawReport is String) {
      safeReport = rawReport;
    } else {
      safeReport = rawReport.toString();
    }
    return Report(
      reportId: json['reportId'],
      convId: json['convId'],
      anomalyReport: safeReport,
      anomalyTurn: json['anomalyTurn'],
      created_at: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      imageUrl: json['imageUrl'],
    );
  }
} 