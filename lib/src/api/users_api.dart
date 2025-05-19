import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for user-related endpoints
class UsersApi {
  final Dio _dio;

  UsersApi(this._dio);

  /// Get a user by ID
  Future<User> getUser(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId');
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get users with pagination
  Future<List<User>> getUsers({
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

      return (response.data as List)
          .map((userData) => User.fromJson(userData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new user
  Future<User> createUser(CreateUserRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v4/users',
        data: request.toJson(),
      );
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a user
  Future<User> updateUser(String userId, UpdateUserRequest request) async {
    try {
      final response = await _dio.put(
        '/api/v4/users/$userId',
        data: request.toJson(),
      );
      return User.fromJson(response.data);
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
  Future<User> getUserByUsername(String username) async {
    try {
      final response = await _dio.get('/api/v4/users/username/$username');
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get user by email
  Future<User> getUserByEmail(String email) async {
    try {
      final response = await _dio.get('/api/v4/users/email/$email');
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get the current user
  Future<User> getMe() async {
    try {
      final response = await _dio.get('/api/v4/users/me');
      return User.fromJson(response.data);
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
        data: {
          'email': email,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get user's sessions
  Future<List<Session>> getUserSessions(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/sessions');
      return (response.data as List)
          .map((sessionData) => Session.fromJson(sessionData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Revoke a user session
  Future<void> revokeUserSession(String userId, String sessionId) async {
    try {
      await _dio.post(
        '/api/v4/users/$userId/sessions/revoke',
        data: {
          'session_id': sessionId,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get user's teams
  Future<List<Team>> getUserTeams(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/teams');
      return (response.data as List)
          .map((teamData) => Team.fromJson(teamData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Search users
  Future<List<User>> searchUsers(UserSearchRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v4/users/search',
        data: request.toJson(),
      );
      return (response.data as List)
          .map((userData) => User.fromJson(userData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
