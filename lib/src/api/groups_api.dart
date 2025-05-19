import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for group-related endpoints
class GroupsApi {
  final Dio _dio;

  GroupsApi(this._dio);

  /// Get groups
  Future<List<Group>> getGroups({
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
      return (response.data as List)
          .map((groupData) => Group.fromJson(groupData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a group
  Future<Group> getGroup(String groupId) async {
    try {
      final response = await _dio.get('/api/v4/groups/$groupId');
      return Group.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get group stats
  Future<GroupStats> getGroupStats(String groupId) async {
    try {
      final response = await _dio.get('/api/v4/groups/$groupId/stats');
      return GroupStats.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get group members
  Future<List<GroupMember>> getGroupMembers(
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
      return (response.data as List)
          .map((memberData) => GroupMember.fromJson(memberData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get group channels
  Future<List<GroupChannel>> getGroupChannels(
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
      return (response.data as List)
          .map((channelData) => GroupChannel.fromJson(channelData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get group teams
  Future<List<GroupTeam>> getGroupTeams(
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
      return (response.data as List)
          .map((teamData) => GroupTeam.fromJson(teamData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Link a group to a team
  Future<GroupTeam> linkGroupToTeam(String groupId, String teamId) async {
    try {
      final response = await _dio.post(
        '/api/v4/groups/$groupId/teams/$teamId/link',
      );
      return GroupTeam.fromJson(response.data);
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
  Future<GroupChannel> linkGroupToChannel(
    String groupId,
    String channelId,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/groups/$groupId/channels/$channelId/link',
      );
      return GroupChannel.fromJson(response.data);
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
