import 'package:dio/dio.dart';

import '../models/m_permission.dart';

/// API for permissions-related endpoints
class MPermissionsApi {
  final Dio _dio;

  MPermissionsApi(this._dio);

  /// Get all ancillary permissions
  Future<List<MPermission>> getAncillaryPermissions() async {
    try {
      final response = await _dio.get('/api/v4/permissions/ancillary');
      return (response.data as List).map((permission) => MPermission.fromJson(permission)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get system-wide permissions
  Future<List<MPermission>> getSystemPermissions() async {
    try {
      final response = await _dio.get('/api/v4/permissions');
      return (response.data as List).map((permission) => MPermission.fromJson(permission)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
