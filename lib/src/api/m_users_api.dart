import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for user-related endpoints
class MUsersApi {
  final Dio _dio;

  MUsersApi(this._dio);

  /// Get a user by ID
  Future<MUser> getUser(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId');
      return MUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get users with pagination
  Future<List<MUser>> getUsers({
    int page = 0,
    int perPage = 60,
    String? inTeam,
    String? notInTeam,
    String? inChannel,
    String? notInChannel,
    String? sort = '',
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (inTeam != null) queryParams['in_team'] = inTeam;
      if (notInTeam != null) queryParams['not_in_team'] = notInTeam;
      if (inChannel != null) queryParams['in_channel'] = inChannel;
      if (notInChannel != null) queryParams['not_in_channel'] = notInChannel;
      if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;

      final response = await _dio.get(
        '/api/v4/users',
        queryParameters: queryParams,
      );

      return (response.data as List).map((userData) => MUser.fromJson(userData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new user
  Future<MUser> createUser(MCreateUserRequest request) async {
    try {
      final response = await _dio.post('/api/v4/users', data: request.toJson());
      return MUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a user
  Future<MUser> updateUser(String userId, MUpdateUserRequest request) async {
    try {
      final response = await _dio.put(
        '/api/v4/users/$userId',
        data: request.toJson(),
      );
      return MUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a user
  Future<void> deleteUser(String userId) async {
    try {
      await _dio.delete('/api/v4/users/$userId');
    } catch (e) {
      rethrow;
    }
  }

  /// Get user by username
  Future<MUser> getUserByUsername(String username) async {
    try {
      final response = await _dio.get('/api/v4/users/username/$username');
      return MUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get user by email
  Future<MUser> getUserByEmail(String email) async {
    try {
      final response = await _dio.get('/api/v4/users/email/$email');
      return MUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get the current user
  Future<MUser> getMe() async {
    try {
      final response = await _dio.get('/api/v4/users/me');
      return MUser.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user password
  Future<void> updateUserPassword(
    String userId, {
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put(
        '/api/v4/users/$userId/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _dio.post(
        '/api/v4/users/password/reset/send',
        data: {'email': email},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get user's sessions
  Future<List<MSession>> getUserSessions(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/sessions');
      return (response.data as List).map((sessionData) => MSession.fromJson(sessionData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Revoke a user session
  Future<void> revokeUserSession(String userId, String sessionId) async {
    try {
      await _dio.post(
        '/api/v4/users/$userId/sessions/revoke',
        data: {'session_id': sessionId},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get user's teams
  Future<List<MTeam>> getUserTeams(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/teams');
      return (response.data as List).map((teamData) => MTeam.fromJson(teamData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Search users
  Future<List<MUser>> searchUsers(MUserSearchRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v4/users/search',
        data: request.toJson(),
      );
      return (response.data as List).map((userData) => MUser.fromJson(userData)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
