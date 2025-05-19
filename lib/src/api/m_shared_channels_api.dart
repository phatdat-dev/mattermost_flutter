import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/m_shared_channel.dart';

/// API for shared channels-related endpoints
class MSharedChannelsApi {
  final Dio _dio;

  MSharedChannelsApi(this._dio);

  /// Get all shared channels
  Future<List<MSharedChannel>> getSharedChannels({int page = 0, int perPage = 60, bool? teamOnly, bool? withTeamId}) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page.toString(), 'per_page': perPage.toString()};

      if (teamOnly != null) queryParams['team_only'] = teamOnly.toString();
      if (withTeamId != null) queryParams['with_team_id'] = withTeamId.toString();

      final response = await _dio.get('/api/v4/sharedchannels/channels', queryParameters: queryParams);
      return (response.data as List).map((channel) => MSharedChannel.fromJson(channel)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get remote cluster info
  Future<List<MRemoteCluster>> getRemoteClusters() async {
    try {
      final response = await _dio.get('/api/v4/sharedchannels/remote_clusters');
      return (response.data as List).map((cluster) => MRemoteCluster.fromJson(cluster)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create a remote cluster invitation
  Future<MRemoteClusterInvite> createRemoteClusterInvite(MCreateRemoteClusterInviteRequest request) async {
    try {
      final response = await _dio.post('/api/v4/sharedchannels/remote_clusters/invite', data: request.toJson());
      return MRemoteClusterInvite.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
