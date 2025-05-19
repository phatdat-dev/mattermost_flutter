import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for OAuth-related endpoints
class OAuthApi {
  final Dio _dio;

  OAuthApi(this._dio);

  /// Register OAuth app
  Future<OAuthApp> registerOAuthApp(RegisterOAuthAppRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v4/oauth/apps',
        data: request.toJson(),
      );
      return OAuthApp.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get OAuth apps
  Future<List<OAuthApp>> getOAuthApps({
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/oauth/apps',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List)
          .map((appData) => OAuthApp.fromJson(appData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get OAuth app
  Future<OAuthApp> getOAuthApp(String appId) async {
    try {
      final response = await _dio.get('/api/v4/oauth/apps/$appId');
      return OAuthApp.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update OAuth app
  Future<OAuthApp> updateOAuthApp(
    String appId,
    UpdateOAuthAppRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v4/oauth/apps/$appId',
        data: request.toJson(),
      );
      return OAuthApp.fromJson(response.data);
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
  Future<OAuthApp> regenerateOAuthAppSecret(String appId) async {
    try {
      final response = await _dio.post('/api/v4/oauth/apps/$appId/regen_secret');
      return OAuthApp.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get authorized OAuth apps
  Future<List<OAuthApp>> getAuthorizedOAuthApps() async {
    try {
      final response = await _dio.get('/api/v4/oauth/authorized');
      return (response.data as List)
          .map((appData) => OAuthApp.fromJson(appData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
