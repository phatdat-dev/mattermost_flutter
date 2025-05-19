import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for integrations-related endpoints
class MIntegrationsApi {
  final Dio _dio;

  MIntegrationsApi(this._dio);

  /// Get all integrations
  Future<MIntegrations> getIntegrations() async {
    try {
      final response = await _dio.get('/api/v4/integrations');
      return MIntegrations.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
