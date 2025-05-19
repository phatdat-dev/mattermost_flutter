import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for integrations-related endpoints
class IntegrationsApi {
  final Dio _dio;

  IntegrationsApi(this._dio);

  /// Get all integrations
  Future<IntegrationsList> getIntegrations() async {
    try {
      final response = await _dio.get('/api/v4/integrations');
      return IntegrationsList.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
