import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for user status-related endpoints
class StatusApi {
  final Dio _dio;

  StatusApi(this._dio);

  /// Get user status
  Future<UserStatus> getUserStatus(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/status');
      return UserStatus.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get user statuses
  Future<List<UserStatus>> getUserStatuses() async {
    try {
      final response = await _dio.get('/api/v4/users/status');
      return (response.data as List)
          .map((statusData) => UserStatus.fromJson(statusData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get user statuses by ID
  Future<List<UserStatus>> getUserStatusesByIds(List<String> userIds) async {
    try {
      final response = await _dio.post(
        '/api/v4/users/status/ids',
        data: userIds,
      );
      return (response.data as List)
          .map((statusData) => UserStatus.fromJson(statusData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Update user status
  Future<UserStatus> updateUserStatus(
    String userId,
    UpdateUserStatusRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v4/users/$userId/status',
        data: request.toJson(),
      );
      return UserStatus.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
