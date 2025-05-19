import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for team-related endpoints
class TeamsApi {
  final Dio _dio;

  TeamsApi(this._dio);

  /// Create a new team
  Future<Team> createTeam(CreateTeamRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v4/teams',
        data: request.toJson(),
      );
      return Team.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a team by ID
  Future<Team> getTeam(String teamId) async {
    try {
      final response = await _dio.get('/api/v4/teams/$teamId');
      return Team.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get teams with pagination
  Future<List<Team>> getTeams({
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/teams',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List)
          .map((teamData) => Team.fromJson(teamData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get team by name
  Future<Team> getTeamByName(String name) async {
    try {
      final response = await _dio.get('/api/v4/teams/name/$name');
      return Team.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a team
  Future<Team> updateTeam(String teamId, UpdateTeamRequest request) async {
    try {
      final response = await _dio.put(
        '/api/v4/teams/$teamId',
        data: request.toJson(),
      );
      return Team.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a team
  Future<void> deleteTeam(String teamId, {bool permanent = false}) async {
    try {
      await _dio.delete(
        '/api/v4/teams/$teamId',
        queryParameters: {
          'permanent': permanent.toString(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get team members
  Future<List<TeamMember>> getTeamMembers(
    String teamId, {
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/teams/$teamId/members',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List)
          .map((memberData) => TeamMember.fromJson(memberData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Add a user to a team
  Future<TeamMember> addTeamMember(
    String teamId,
    AddTeamMemberRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/teams/$teamId/members',
        data: request.toJson(),
      );
      return TeamMember.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Remove a user from a team
  Future<void> removeTeamMember(String teamId, String userId) async {
    try {
      await _dio.delete('/api/v4/teams/$teamId/members/$userId');
    } catch (e) {
      rethrow;
    }
  }

  /// Get team stats
  Future<TeamStats> getTeamStats(String teamId) async {
    try {
      final response = await _dio.get('/api/v4/teams/$teamId/stats');
      return TeamStats.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get teams for a user
  Future<List<Team>> getTeamsForUser(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/teams');
      return (response.data as List)
          .map((teamData) => Team.fromJson(teamData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Search teams
  Future<List<Team>> searchTeams(TeamSearchRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v4/teams/search',
        data: request.toJson(),
      );
      return (response.data as List)
          .map((teamData) => Team.fromJson(teamData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
