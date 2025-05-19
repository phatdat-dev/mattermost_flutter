import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for system-related endpoints
class SystemApi {
  final Dio _dio;

  SystemApi(this._dio);

  /// Get system ping
  Future<bool> ping() async {
    try {
      final response = await _dio.get('/api/v4/system/ping');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get system status
  Future<SystemStatus> getSystemStatus() async {
    try {
      final response = await _dio.get('/api/v4/system/status');
      return SystemStatus.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get server version
  Future<String> getServerVersion() async {
    try {
      final response = await _dio.get('/api/v4/system/ping');
      return response.headers.map['x-version-id']?.first ?? '';
    } catch (e) {
      rethrow;
    }
  }

  /// Get client configuration
  Future<Map<String, dynamic>> getClientConfig() async {
    try {
      final response = await _dio.get('/api/v4/config/client');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get server configuration
  Future<Map<String, dynamic>> getServerConfig() async {
    try {
      final response = await _dio.get('/api/v4/config');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Update server configuration
  Future<Map<String, dynamic>> updateServerConfig(
    Map<String, dynamic> config,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v4/config',
        data: config,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get audits
  Future<List<Audit>> getAudits({
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/audits',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List)
          .map((auditData) => Audit.fromJson(auditData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get logs
  Future<List<String>> getLogs({
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/logs',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).cast<String>();
    } catch (e) {
      rethrow;
    }
  }

  /// Get analytics
  Future<Map<String, dynamic>> getAnalytics({
    String? teamId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (teamId != null) queryParams['team_id'] = teamId;

      final response = await _dio.get(
        '/api/v4/analytics/old',
        queryParameters: queryParams,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
