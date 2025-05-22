import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for role-related endpoints
class MRolesApi {
  final Dio _dio;

  MRolesApi(this._dio);

  /// Get all roles
  Future<List<MRole>> getAllRoles() async {
    try {
      final response = await _dio.get('/api/v4/roles');
      return (response.data as List).map((roleData) => MRole.fromJson(roleData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get role by ID
  Future<MRole> getRole(String roleId) async {
    try {
      final response = await _dio.get('/api/v4/roles/$roleId');
      return MRole.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get role by name
  Future<MRole> getRoleByName(String roleName) async {
    try {
      final response = await _dio.get('/api/v4/roles/name/$roleName');
      return MRole.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get roles by names
  Future<List<MRole>> getRolesByNames(List<String> roleNames) async {
    try {
      final response = await _dio.post('/api/v4/roles/names', data: roleNames);
      return (response.data as List).map((roleData) => MRole.fromJson(roleData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Patch a role
  Future<MRole> patchRole(String roleId, MPatchRoleRequest request) async {
    try {
      final response = await _dio.put(
        '/api/v4/roles/$roleId/patch',
        data: request.toJson(),
      );
      return MRole.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
