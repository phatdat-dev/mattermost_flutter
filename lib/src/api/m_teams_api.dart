import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for team-related endpoints
class MTeamsApi {
  final Dio _dio;

  MTeamsApi(this._dio);

  /// Create a new team
  Future<MTeam> createTeam(MCreateTeamRequest request) async {
    try {
      final response = await _dio.post('/api/v4/teams', data: request.toJson());
      return MTeam.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a team by ID
  Future<MTeam> getTeam(String teamId) async {
    try {
      final response = await _dio.get('/api/v4/teams/$teamId');
      return MTeam.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get teams with pagination
  Future<List<MTeam>> getTeams({int page = 0, int perPage = 60}) async {
    try {
      final response = await _dio.get('/api/v4/teams', queryParameters: {'page': page.toString(), 'per_page': perPage.toString()});
      return (response.data as List).map((teamData) => MTeam.fromJson(teamData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get team by name
  Future<MTeam> getTeamByName(String name) async {
    try {
      final response = await _dio.get('/api/v4/teams/name/$name');
      return MTeam.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a team
  Future<MTeam> updateTeam(String teamId, MUpdateTeamRequest request) async {
    try {
      final response = await _dio.put('/api/v4/teams/$teamId', data: request.toJson());
      return MTeam.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a team
  Future<void> deleteTeam(String teamId, {bool permanent = false}) async {
    try {
      await _dio.delete('/api/v4/teams/$teamId', queryParameters: {'permanent': permanent.toString()});
    } catch (e) {
      rethrow;
    }
  }

  /// Get team members
  Future<List<MTeamMember>> getTeamMembers(String teamId, {int page = 0, int perPage = 60}) async {
    try {
      final response = await _dio.get('/api/v4/teams/$teamId/members', queryParameters: {'page': page.toString(), 'per_page': perPage.toString()});
      return (response.data as List).map((memberData) => MTeamMember.fromJson(memberData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Add a user to a team
  Future<MTeamMember> addTeamMember(String teamId, MAddTeamMemberRequest request) async {
    try {
      final response = await _dio.post('/api/v4/teams/$teamId/members', data: request.toJson());
      return MTeamMember.fromJson(response.data);
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
  Future<MTeamStats> getTeamStats(String teamId) async {
    try {
      final response = await _dio.get('/api/v4/teams/$teamId/stats');
      return MTeamStats.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get teams for a user
  Future<List<MTeam>> getTeamsForUser(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/teams');
      return (response.data as List).map((teamData) => MTeam.fromJson(teamData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Search teams
  Future<List<MTeam>> searchTeams(MTeamSearchRequest request) async {
    try {
      final response = await _dio.post('/api/v4/teams/search', data: request.toJson());
      return (response.data as List).map((teamData) => MTeam.fromJson(teamData)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
