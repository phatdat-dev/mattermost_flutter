import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for compliance-related endpoints
class MComplianceApi {
  final Dio _dio;

  MComplianceApi(this._dio);

  /// Create compliance report
  Future<MComplianceReport> createComplianceReport(
    MCreateComplianceReportRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/compliance/reports',
        data: request.toJson(),
      );
      return MComplianceReport.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get compliance reports
  Future<List<MComplianceReport>> getComplianceReports({
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/compliance/reports',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).map((reportData) => MComplianceReport.fromJson(reportData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get compliance report
  Future<MComplianceReport> getComplianceReport(String reportId) async {
    try {
      final response = await _dio.get('/api/v4/compliance/reports/$reportId');
      return MComplianceReport.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Download compliance report
  Future<List<int>> downloadComplianceReport(String reportId) async {
    try {
      final response = await _dio.get(
        '/api/v4/compliance/reports/$reportId/download',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
