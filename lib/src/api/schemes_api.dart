import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for scheme-related endpoints
class SchemesApi {
  final Dio _dio;

  SchemesApi(this._dio);

  /// Get schemes
  Future<List<Scheme>> getSchemes({
    String? scope,
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (scope != null) queryParams['scope'] = scope;

      final response = await _dio.get(
        '/api/v4/schemes',
        queryParameters: queryParams,
      );
      return (response.data as List)
          .map((schemeData) => Scheme.fromJson(schemeData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create a scheme
  Future<Scheme> createScheme(CreateSchemeRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v4/schemes',
        data: request.toJson(),
      );
      return Scheme.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a scheme
  Future<Scheme> getScheme(String schemeId) async {
    try {
      final response = await _dio.get('/api/v4/schemes/$schemeId');
      return Scheme.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a scheme
  Future<void> deleteScheme(String schemeId) async {
    try {
      await _dio.delete('/api/v4/schemes/$schemeId');
    } catch (e) {
      rethrow;
    }
  }

  /// Patch a scheme
  Future<Scheme> patchScheme(
    String schemeId,
    PatchSchemeRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v4/schemes/$schemeId/patch',
        data: request.toJson(),
      );
      return Scheme.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get teams using a scheme
  Future<List<Team>> getTeamsForScheme(
    String schemeId, {
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/schemes/$schemeId/teams',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List)
          .map((teamData) => Team.fromJson(teamData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get channels using a scheme
  Future<List<Channel>> getChannelsForScheme(
    String schemeId, {
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/schemes/$schemeId/channels',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List)
          .map((channelData) => Channel.fromJson(channelData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
