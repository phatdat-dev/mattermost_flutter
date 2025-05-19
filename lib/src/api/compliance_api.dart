import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for compliance-related endpoints
class ComplianceApi {
  final Dio _dio;

  ComplianceApi(this._dio);

  /// Create compliance report
  Future<ComplianceReport> createComplianceReport(
    CreateComplianceReportRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/compliance/reports',
        data: request.toJson(),
      );
      return ComplianceReport.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get compliance reports
  Future<List<ComplianceReport>> getComplianceReports({
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
      return (response.data as List)
          .map((reportData) => ComplianceReport.fromJson(reportData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get compliance report
  Future<ComplianceReport> getComplianceReport(String reportId) async {
    try {
      final response = await _dio.get('/api/v4/compliance/reports/$reportId');
      return ComplianceReport.fromJson(response.data);
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
