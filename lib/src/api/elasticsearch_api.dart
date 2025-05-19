import 'package:dio/dio.dart';

/// API for Elasticsearch-related endpoints
class ElasticsearchApi {
  final Dio _dio;

  ElasticsearchApi(this._dio);

  /// Test Elasticsearch configuration
  Future<bool> testElasticsearchConfig() async {
    try {
      await _dio.post('/api/v4/elasticsearch/test');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Purge Elasticsearch indexes
  Future<void> purgeElasticsearchIndexes() async {
    try {
      await _dio.post('/api/v4/elasticsearch/purge_indexes');
    } catch (e) {
      rethrow;
    }
  }

  /// Index Elasticsearch data
  Future<void> indexElasticsearchData() async {
    try {
      await _dio.post('/api/v4/elasticsearch/index');
    } catch (e) {
      rethrow;
    }
  }
}
