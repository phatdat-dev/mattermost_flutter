import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for user status-related endpoints
class MStatusApi {
  final Dio _dio;

  MStatusApi(this._dio);

  /// Get user status
  Future<MUserStatus> getUserStatus(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/status');
      return MUserStatus.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get user statuses
  Future<List<MUserStatus>> getUserStatuses() async {
    try {
      final response = await _dio.get('/api/v4/users/status');
      return (response.data as List).map((statusData) => MUserStatus.fromJson(statusData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get user statuses by ID
  Future<List<MUserStatus>> getUserStatusesByIds(List<String> userIds) async {
    try {
      final response = await _dio.post(
        '/api/v4/users/status/ids',
        data: userIds,
      );
      return (response.data as List).map((statusData) => MUserStatus.fromJson(statusData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Update user status
  Future<MUserStatus> updateUserStatus(
    String userId, {
    required String status,
    bool? manual,
  }) async {
    try {
      final data = {
        'status': status,
        if (manual != null) 'manual': manual,
      };

      final response = await _dio.put(
        '/api/v4/users/$userId/status',
        data: data,
      );
      return MUserStatus.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
