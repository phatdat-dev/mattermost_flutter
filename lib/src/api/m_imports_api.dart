import 'dart:io';

import 'package:dio/dio.dart';

import '../models/m_import.dart';

/// API for imports-related endpoints
class MImportsApi {
  final Dio _dio;

  MImportsApi(this._dio);

  /// List all imports
  Future<List<MImport>> listImports() async {
    try {
      final response = await _dio.get('/api/v4/imports');
      return (response.data as List).map((import) => MImport.fromJson(import)).toList();
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
          contentType: DioMediaType.parse('application/octet-stream'),
        ),
      });

      await _dio.post('/api/v4/imports', data: formData);
    } catch (e) {
      rethrow;
    }
  }
}
