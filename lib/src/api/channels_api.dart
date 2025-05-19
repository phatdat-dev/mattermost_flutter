import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for channel-related endpoints
class ChannelsApi {
  final Dio _dio;

  ChannelsApi(this._dio);

  /// Create a new channel
  Future<Channel> createChannel(CreateChannelRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v4/channels',
        data: request.toJson(),
      );
      return Channel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a channel by ID
  Future<Channel> getChannel(String channelId) async {
    try {
      final response = await _dio.get('/api/v4/channels/$channelId');
      return Channel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a channel
  Future<Channel> updateChannel(
    String channelId,
    UpdateChannelRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v4/channels/$channelId',
        data: request.toJson(),
      );
      return Channel.fromJson(response.data);
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
  Future<List<Channel>> getChannelsForTeam(
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
      return (response.data as List)
          .map((channelData) => Channel.fromJson(channelData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get channel by name
  Future<Channel> getChannelByName(String teamId, String channelName) async {
    try {
      final response = await _dio.get(
        '/api/v4/teams/$teamId/channels/name/$channelName',
      );
      return Channel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get channel members
  Future<List<ChannelMember>> getChannelMembers(
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
      return (response.data as List)
          .map((memberData) => ChannelMember.fromJson(memberData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Add a user to a channel
  Future<ChannelMember> addChannelMember(
    String channelId,
    AddChannelMemberRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/channels/$channelId/members',
        data: request.toJson(),
      );
      return ChannelMember.fromJson(response.data);
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

  /// Get channels for a user
  Future<List<Channel>> getChannelsForUser(
    String userId,
    String teamId,
  ) async {
    try {
      final response = await _dio.get(
        '/api/v4/users/$userId/teams/$teamId/channels',
      );
      return (response.data as List)
          .map((channelData) => Channel.fromJson(channelData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get channel stats
  Future<ChannelStats> getChannelStats(String channelId) async {
    try {
      final response = await _dio.get('/api/v4/channels/$channelId/stats');
      return ChannelStats.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get public channels for a team
  Future<List<Channel>> getPublicChannelsForTeam(
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
      return (response.data as List)
          .map((channelData) => Channel.fromJson(channelData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Search channels
  Future<List<Channel>> searchChannels(
    String teamId,
    ChannelSearchRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/teams/$teamId/channels/search',
        data: request.toJson(),
      );
      return (response.data as List)
          .map((channelData) => Channel.fromJson(channelData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create a direct message channel
  Future<Channel> createDirectChannel(String userId, String otherUserId) async {
    try {
      final response = await _dio.post(
        '/api/v4/channels/direct',
        data: [userId, otherUserId],
      );
      return Channel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a group message channel
  Future<Channel> createGroupChannel(List<String> userIds) async {
    try {
      final response = await _dio.post(
        '/api/v4/channels/group',
        data: userIds,
      );
      return Channel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
