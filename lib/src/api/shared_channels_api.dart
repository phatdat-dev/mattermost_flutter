import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/shared_channel.dart';

/// API for shared channels-related endpoints
class SharedChannelsApi {
  final Dio _dio;

  SharedChannelsApi(this._dio);

  /// Get all shared channels
  Future<List<SharedChannel>> getSharedChannels({
    int page = 0,
    int perPage = 60,
    bool? teamOnly,
    bool? withTeamId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (teamOnly != null) queryParams['team_only'] = teamOnly.toString();
      if (withTeamId != null) queryParams['with_team_id'] = withTeamId.toString();

      final response = await _dio.get(
        '/api/v4/sharedchannels/channels',
        queryParameters: queryParams,
      );
      return (response.data as List)
          .map((channel) => SharedChannel.fromJson(channel))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get remote cluster info
  Future<List<RemoteCluster>> getRemoteClusters() async {
    try {
      final response = await _dio.get('/api/v4/sharedchannels/remote_clusters');
      return (response.data as List)
          .map((cluster) => RemoteCluster.fromJson(cluster))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create a remote cluster invitation
  Future<RemoteClusterInvite> createRemoteClusterInvite(
    CreateRemoteClusterInviteRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/sharedchannels/remote_clusters/invite',
        data: request.toJson(),
      );
      return RemoteClusterInvite.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
