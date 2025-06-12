import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/report.dart';

class ReportApi {
  static const String baseUrl = 'https://20.41.115.128';

  static Future<List<Report>> fetchReports(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/reports/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    final decodedBody = utf8.decode(response.bodyBytes);
    print('==== [DEBUG] statusCode: [32m${response.statusCode}[0m');
    print('==== [DEBUG] body: $decodedBody');
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(decodedBody);
      final List<dynamic> data = body['data'];
      print('==== [DEBUG] data.length: ${data.length}');
      for (var i = 0; i < data.length; i++) {
        print('==== [DEBUG] report[\x1B[32m$i\x1B[0m]: reportId=${data[i]['reportId']}, anomalyReport=${data[i]['anomalyReport']}, created_at=${data[i]['created_at']}');
      }
      return data.map((json) => Report.fromJson(json)).toList();
    } else {
      print('==== [DEBUG] API Error: ${response.statusCode}');
      throw Exception('리포트 목록을 불러오지 못했습니다');
    }
  }

  static Future<Report> fetchReportDetail(String accessToken, String reportId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/reports/$reportId'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    final decodedBody = utf8.decode(response.bodyBytes);
    print('==== [DEBUG] statusCode: [32m${response.statusCode}[0m');
    print('==== [DEBUG] body: $decodedBody');
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(decodedBody);
      return Report.fromJson(body);
    } else {
      print('==== [DEBUG] API Error: ${response.statusCode}');
      throw Exception('리포트 상세 내용을 불러오지 못했습니다');
    }
  }
} 