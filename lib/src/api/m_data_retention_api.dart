import 'package:dio/dio.dart';

import '../models/m_data_retention.dart';

/// API for data retention-related endpoints
class MDataRetentionApi {
  final Dio _dio;

  MDataRetentionApi(this._dio);

  /// Get data retention policy
  Future<MDataRetentionPolicy> getPolicy() async {
    try {
      final response = await _dio.get('/api/v4/data_retention/policy');
      return MDataRetentionPolicy.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get data retention policies for teams
  Future<List<MTeamDataRetentionPolicy>> getTeamPolicies({
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/data_retention/policies_teams',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).map((policy) => MTeamDataRetentionPolicy.fromJson(policy)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get data retention policies for channels
  Future<List<MChannelDataRetentionPolicy>> getChannelPolicies({
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/data_retention/policies_channels',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).map((policy) => MChannelDataRetentionPolicy.fromJson(policy)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create data retention policy for team
  Future<MTeamDataRetentionPolicy> createTeamPolicy(
    MCreateTeamPolicyRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/data_retention/policies_teams',
        data: request.toJson(),
      );
      return MTeamDataRetentionPolicy.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Create data retention policy for channel
  Future<MChannelDataRetentionPolicy> createChannelPolicy(
    MCreateChannelPolicyRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/data_retention/policies_channels',
        data: request.toJson(),
      );
      return MChannelDataRetentionPolicy.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get data retention policy for team
  Future<MTeamDataRetentionPolicy> getTeamPolicy(String policyId) async {
    try {
      final response = await _dio.get(
        '/api/v4/data_retention/policies_teams/$policyId',
      );
      return MTeamDataRetentionPolicy.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get data retention policy for channel
  Future<MChannelDataRetentionPolicy> getChannelPolicy(String policyId) async {
    try {
      final response = await _dio.get(
        '/api/v4/data_retention/policies_channels/$policyId',
      );
      return MChannelDataRetentionPolicy.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete data retention policy for team
  Future<void> deleteTeamPolicy(String policyId) async {
    try {
      await _dio.delete('/api/v4/data_retention/policies_teams/$policyId');
    } catch (e) {
      rethrow;
    }
  }

  /// Delete data retention policy for channel
  Future<void> deleteChannelPolicy(String policyId) async {
    try {
      await _dio.delete('/api/v4/data_retention/policies_channels/$policyId');
    } catch (e) {
      rethrow;
    }
  }

  /// Update data retention policy for team
  Future<MTeamDataRetentionPolicy> updateTeamPolicy(
    String policyId,
    MUpdateTeamPolicyRequest request,
  ) async {
    try {
      final response = await _dio.patch(
        '/api/v4/data_retention/policies_teams/$policyId',
        data: request.toJson(),
      );
      return MTeamDataRetentionPolicy.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update data retention policy for channel
  Future<MChannelDataRetentionPolicy> updateChannelPolicy(
    String policyId,
    MUpdateChannelPolicyRequest request,
  ) async {
    try {
      final response = await _dio.patch(
        '/api/v4/data_retention/policies_channels/$policyId',
        data: request.toJson(),
      );
      return MChannelDataRetentionPolicy.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get teams for a data retention policy
  Future<List<String>> getTeamsForPolicy(
    String policyId, {
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/data_retention/policies_teams/$policyId/teams',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).cast<String>();
    } catch (e) {
      rethrow;
    }
  }

  /// Get channels for a data retention policy
  Future<List<String>> getChannelsForPolicy(
    String policyId, {
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v4/data_retention/policies_channels/$policyId/channels',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).cast<String>();
    } catch (e) {
      rethrow;
    }
  }

  /// Add teams to a data retention policy
  Future<void> addTeamsToPolicy(String policyId, List<String> teamIds) async {
    try {
      await _dio.post(
        '/api/v4/data_retention/policies_teams/$policyId/teams',
        data: teamIds,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Add channels to a data retention policy
  Future<void> addChannelsToPolicy(
    String policyId,
    List<String> channelIds,
  ) async {
    try {
      await _dio.post(
        '/api/v4/data_retention/policies_channels/$policyId/channels',
        data: channelIds,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Remove a team from a data retention policy
  Future<void> removeTeamFromPolicy(String policyId, String teamId) async {
    try {
      await _dio.delete(
        '/api/v4/data_retention/policies_teams/$policyId/teams/$teamId',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Remove a channel from a data retention policy
  Future<void> removeChannelFromPolicy(
    String policyId,
    String channelId,
  ) async {
    try {
      await _dio.delete(
        '/api/v4/data_retention/policies_channels/$policyId/channels/$channelId',
      );
    } catch (e) {
      rethrow;
    }
  }
}
