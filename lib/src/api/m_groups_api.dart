import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for group-related endpoints
class MGroupsApi {
  final Dio _dio;

  MGroupsApi(this._dio);

  /// Get groups
  Future<List<MGroup>> getGroups({
    int page = 0,
    int perPage = 60,
    bool? filterAllowReference,
    String? q,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (filterAllowReference != null) {
        queryParams['filter_allow_reference'] = filterAllowReference.toString();
      }
      if (q != null && q.isNotEmpty) queryParams['q'] = q;

      final response = await _dio.get(
        '/api/v4/groups',
        queryParameters: queryParams,
      );
      return (response.data as List).map((groupData) => MGroup.fromJson(groupData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a group
  Future<MGroup> getGroup(String groupId) async {
    try {
      final response = await _dio.get('/api/v4/groups/$groupId');
      return MGroup.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get group stats
  Future<MGroupStats> getGroupStats(String groupId) async {
    try {
      final response = await _dio.get('/api/v4/groups/$groupId/stats');
      return MGroupStats.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get group members
  Future<List<MGroupMember>> getGroupMembers(
    String groupId, {
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/groups/$groupId/members',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).map((memberData) => MGroupMember.fromJson(memberData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get group channels
  Future<List<MGroupChannel>> getGroupChannels(
    String groupId, {
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/groups/$groupId/channels',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).map((channelData) => MGroupChannel.fromJson(channelData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get group teams
  Future<List<MGroupTeam>> getGroupTeams(
    String groupId, {
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/groups/$groupId/teams',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).map((teamData) => MGroupTeam.fromJson(teamData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Link a group to a team
  Future<MGroupTeam> linkGroupToTeam(String groupId, String teamId) async {
    try {
      final response = await _dio.post(
        '/api/v4/groups/$groupId/teams/$teamId/link',
      );
      return MGroupTeam.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Unlink a group from a team
  Future<void> unlinkGroupFromTeam(String groupId, String teamId) async {
    try {
      await _dio.delete('/api/v4/groups/$groupId/teams/$teamId/link');
    } catch (e) {
      rethrow;
    }
  }

  /// Link a group to a channel
  Future<MGroupChannel> linkGroupToChannel(
    String groupId,
    String channelId,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/groups/$groupId/channels/$channelId/link',
      );
      return MGroupChannel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Unlink a group from a channel
  Future<void> unlinkGroupFromChannel(String groupId, String channelId) async {
    try {
      await _dio.delete('/api/v4/groups/$groupId/channels/$channelId/link');
    } catch (e) {
      rethrow;
    }
  }
}
