import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for channel-related endpoints
class MChannelsApi {
  final Dio _dio;

  MChannelsApi(this._dio);

  /// Create a new channel
  Future<MChannel> createChannel({
    required String teamId,
    required String name,
    required String displayName,
    String purpose = '',
    String header = '',
    required String type,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v4/channels',
        data: {
          'team_id': teamId,
          'name': name,
          'display_name': displayName,
          'purpose': purpose,
          'header': header,
          'type': type,
        },
      );
      return MChannel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a channel by ID
  Future<MChannel> getChannel(String channelId) async {
    try {
      final response = await _dio.get('/api/v4/channels/$channelId');
      return MChannel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a channel
  Future<MChannel> updateChannel(
    String channelId, {
    String? name,
    String? displayName,
    String? purpose,
    String? header,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (displayName != null) data['display_name'] = displayName;
      if (purpose != null) data['purpose'] = purpose;
      if (header != null) data['header'] = header;

      final response = await _dio.put(
        '/api/v4/channels/$channelId',
        data: data,
      );
      return MChannel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a channel
  Future<void> deleteChannel(String channelId) async {
    try {
      await _dio.delete('/api/v4/channels/$channelId');
    } catch (e) {
      rethrow;
    }
  }

  /// Get channels for a team
  Future<List<MChannel>> getChannelsForTeam(
    String teamId, {
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/teams/$teamId/channels',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).map((channelData) => MChannel.fromJson(channelData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get channel by name
  Future<MChannel> getChannelByName(String teamId, String channelName) async {
    try {
      final response = await _dio.get(
        '/api/v4/teams/$teamId/channels/name/$channelName',
      );
      return MChannel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get channel members
  Future<List<MChannelMember>> getChannelMembers(
    String channelId, {
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/channels/$channelId/members',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).map((memberData) => MChannelMember.fromJson(memberData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a specific channel member
  Future<MChannelMember> getChannelMember(String channelId, String userId) async {
    try {
      final response = await _dio.get('/api/v4/channels/$channelId/members/$userId');
      return MChannelMember.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Add a user to a channel
  Future<MChannelMember> addChannelMember(
    String channelId, {
    required String userId,
    String? postRootId,
  }) async {
    try {
      final data = <String, dynamic>{
        'user_id': userId,
      };
      if (postRootId != null) data['post_root_id'] = postRootId;

      final response = await _dio.post(
        '/api/v4/channels/$channelId/members',
        data: data,
      );
      return MChannelMember.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Remove a user from a channel
  Future<void> removeChannelMember(String channelId, String userId) async {
    try {
      await _dio.delete('/api/v4/channels/$channelId/members/$userId');
    } catch (e) {
      rethrow;
    }
  }

  /// Update channel member notification properties
  Future<MChannelMember> updateChannelMemberNotifyProps(
    String channelId,
    String userId,
    MChannelNotifyProps notifyProps,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v4/channels/$channelId/members/$userId/notify_props',
        data: notifyProps.toJson(),
      );
      return MChannelMember.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get channels for a user
  Future<List<MChannel>> getChannelsForUser(
    String userId,
    String teamId,
  ) async {
    try {
      final response = await _dio.get(
        '/api/v4/users/$userId/teams/$teamId/channels',
      );
      return (response.data as List).map((channelData) => MChannel.fromJson(channelData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get channel stats
  Future<MChannelStats> getChannelStats(String channelId) async {
    try {
      final response = await _dio.get('/api/v4/channels/$channelId/stats');
      return MChannelStats.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get public channels for a team
  Future<List<MChannel>> getPublicChannelsForTeam(
    String teamId, {
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/teams/$teamId/channels/public',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).map((channelData) => MChannel.fromJson(channelData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Search channels
  Future<List<MChannel>> searchChannels(
    String teamId, {
    String? term,
    bool? notAssociatedToGroup,
    String? groupConstrained,
    bool? excludeDefaultChannels,
    bool? includeDeleted,
    bool? excludePolicyConstrained,
    bool? publicChannels,
    bool? privateChannels,
    int? page,
    int? perPage,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (term != null) data['term'] = term;
      if (notAssociatedToGroup != null) data['not_associated_to_group'] = notAssociatedToGroup;
      if (groupConstrained != null) data['group_constrained'] = groupConstrained;
      if (excludeDefaultChannels != null) data['exclude_default_channels'] = excludeDefaultChannels;
      if (includeDeleted != null) data['include_deleted'] = includeDeleted;
      if (excludePolicyConstrained != null) data['exclude_policy_constrained'] = excludePolicyConstrained;
      if (publicChannels != null) data['public'] = publicChannels;
      if (privateChannels != null) data['private'] = privateChannels;
      if (page != null) data['page'] = page;
      if (perPage != null) data['per_page'] = perPage;

      final response = await _dio.post(
        '/api/v4/teams/$teamId/channels/search',
        data: data,
      );
      return (response.data as List).map((channelData) => MChannel.fromJson(channelData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create a direct message channel
  Future<MChannel> createDirectChannel(
    String userId,
    String otherUserId,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/channels/direct',
        data: [userId, otherUserId],
      );
      return MChannel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a group message channel
  Future<MChannel> createGroupChannel(List<String> userIds) async {
    try {
      final response = await _dio.post('/api/v4/channels/group', data: userIds);
      return MChannel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
