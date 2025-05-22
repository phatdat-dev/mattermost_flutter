import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for channel-related endpoints
class MChannelsApi {
  final Dio _dio;

  MChannelsApi(this._dio);

  /// Create a new channel
  Future<MChannel> createChannel(MCreateChannelRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v4/channels',
        data: request.toJson(),
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
    String channelId,
    MUpdateChannelRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v4/channels/$channelId',
        data: request.toJson(),
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

  /// Add a user to a channel
  Future<MChannelMember> addChannelMember(
    String channelId,
    MAddChannelMemberRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/channels/$channelId/members',
        data: request.toJson(),
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
    String teamId,
    MChannelSearchRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/teams/$teamId/channels/search',
        data: request.toJson(),
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
