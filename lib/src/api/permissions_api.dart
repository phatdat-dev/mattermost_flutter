import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/permission.dart';

/// API for permissions-related endpoints
class PermissionsApi {
  final Dio _dio;

  PermissionsApi(this._dio);

  /// Get all ancillary permissions
  Future<List<Permission>> getAncillaryPermissions() async {
    try {
      final response = await _dio.get('/api/v4/permissions/ancillary');
      return (response.data as List)
          .map((permission) => Permission.fromJson(permission))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get system-wide permissions
  Future<List<Permission>> getSystemPermissions() async {
    try {
      final response = await _dio.get('/api/v4/permissions');
      return (response.data as List)
          .map((permission) => Permission.fromJson(permission))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
