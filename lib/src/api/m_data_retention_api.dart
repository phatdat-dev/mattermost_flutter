import 'package:dio/dio.dart';

import '../models/m_data_retention.dart';

/// API for data retention-related endpoints
class MDataRetentionApi {
  final Dio _dio;

  MDataRetentionApi(this._dio);

  /// Get data retention policy
  Future<MDataRetentionPolicy> getPolicy() async {
    try {
      final response = await _dio.get('/api/v4/data_retention/policy');
      return MDataRetentionPolicy.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
