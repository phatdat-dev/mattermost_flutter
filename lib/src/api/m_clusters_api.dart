import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for cluster-related endpoints
class MClustersApi {
  final Dio _dio;

  MClustersApi(this._dio);

  /// Get cluster status
  Future<List<MCluster>> getClusterStatus() async {
    try {
      final response = await _dio.get('/api/v4/cluster/status');
      return (response.data as List).map((clusterData) => MCluster.fromJson(clusterData)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
