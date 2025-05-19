import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for role-related endpoints
class RolesApi {
  final Dio _dio;

  RolesApi(this._dio);

  /// Get all roles
  Future<List<Role>> getAllRoles() async {
    try {
      final response = await _dio.get('/api/v4/roles');
      return (response.data as List)
          .map((roleData) => Role.fromJson(roleData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get role by ID
  Future<Role> getRole(String roleId) async {
    try {
      final response = await _dio.get('/api/v4/roles/$roleId');
      return Role.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get role by name
  Future<Role> getRoleByName(String roleName) async {
    try {
      final response = await _dio.get('/api/v4/roles/name/$roleName');
      return Role.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get roles by names
  Future<List<Role>> getRolesByNames(List<String> roleNames) async {
    try {
      final response = await _dio.post(
        '/api/v4/roles/names',
        data: roleNames,
      );
      return (response.data as List)
          .map((roleData) => Role.fromJson(roleData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Patch a role
  Future<Role> patchRole(String roleId, PatchRoleRequest request) async {
    try {
      final response = await _dio.put(
        '/api/v4/roles/$roleId/patch',
        data: request.toJson(),
      );
      return Role.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
