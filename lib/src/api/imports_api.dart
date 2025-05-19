import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mattermost_flutter/src/models/import.dart';

/// API for imports-related endpoints
class ImportsApi {
  final Dio _dio;

  ImportsApi(this._dio);

  /// List all imports
  Future<List<Import>> listImports() async {
    try {
      final response = await _dio.get('/api/v4/imports');
      return (response.data as List)
          .map((import) => Import.fromJson(import))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create an import from a file
  Future<void> createImport(File file) async {
    try {
      final formData = FormData.fromMap({
        'import': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          contentType: MediaType.parse('application/octet-stream'),
        ),
      });

      await _dio.post(
        '/api/v4/imports',
        data: formData,
      );
    } catch (e) {
      rethrow;
    }
  }
}
