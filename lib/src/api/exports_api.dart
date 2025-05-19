import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/export.dart';

/// API for exports-related endpoints
class ExportsApi {
  final Dio _dio;

  ExportsApi(this._dio);

  /// List all exports
  Future<List<Export>> listExports() async {
    try {
      final response = await _dio.get('/api/v4/exports');
      return (response.data as List)
          .map((export) => Export.fromJson(export))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Delete an export
  Future<void> deleteExport(String exportId) async {
    try {
      await _dio.delete('/api/v4/exports/$exportId');
    } catch (e) {
      rethrow;
    }
  }

  /// Download an export
  Future<List<int>> downloadExport(String exportId) async {
    try {
      final response = await _dio.get(
        '/api/v4/exports/$exportId/download',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new export
  Future<void> createExport() async {
    try {
      await _dio.post('/api/v4/exports');
    } catch (e) {
      rethrow;
    }
  }
}
