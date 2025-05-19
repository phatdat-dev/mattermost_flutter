import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for cluster-related endpoints
class ClustersApi {
  final Dio _dio;

  ClustersApi(this._dio);

  /// Get cluster status
  Future<List<ClusterInfo>> getClusterStatus() async {
    try {
      final response = await _dio.get('/api/v4/cluster/status');
      return (response.data as List)
          .map((clusterData) => ClusterInfo.fromJson(clusterData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
