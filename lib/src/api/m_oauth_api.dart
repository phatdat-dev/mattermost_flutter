import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for OAuth-related endpoints
class MOAuthApi {
  final Dio _dio;

  MOAuthApi(this._dio);

  /// Register OAuth app
  Future<MOAuthApp> registerOAuthApp(MRegisterOAuthAppRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v4/oauth/apps',
        data: request.toJson(),
      );
      return MOAuthApp.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get OAuth apps
  Future<List<MOAuthApp>> getOAuthApps({int page = 0, int perPage = 60}) async {
    try {
      final response = await _dio.get(
        '/api/v4/oauth/apps',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).map((appData) => MOAuthApp.fromJson(appData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get OAuth app
  Future<MOAuthApp> getOAuthApp(String appId) async {
    try {
      final response = await _dio.get('/api/v4/oauth/apps/$appId');
      return MOAuthApp.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update OAuth app
  Future<MOAuthApp> updateOAuthApp(
    String appId,
    MUpdateOAuthAppRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v4/oauth/apps/$appId',
        data: request.toJson(),
      );
      return MOAuthApp.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete OAuth app
  Future<void> deleteOAuthApp(String appId) async {
    try {
      await _dio.delete('/api/v4/oauth/apps/$appId');
    } catch (e) {
      rethrow;
    }
  }

  /// Regenerate OAuth app secret
  Future<MOAuthApp> regenerateOAuthAppSecret(String appId) async {
    try {
      final response = await _dio.post(
        '/api/v4/oauth/apps/$appId/regen_secret',
      );
      return MOAuthApp.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get authorized OAuth apps
  Future<List<MOAuthApp>> getAuthorizedOAuthApps() async {
    try {
      final response = await _dio.get('/api/v4/oauth/authorized');
      return (response.data as List).map((appData) => MOAuthApp.fromJson(appData)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
