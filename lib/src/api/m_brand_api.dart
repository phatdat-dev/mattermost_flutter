import 'dart:io';

import 'package:dio/dio.dart';

/// API for brand-related endpoints
class MBrandApi {
  final Dio _dio;

  MBrandApi(this._dio);

  /// Get brand image
  Future<List<int>> getBrandImage() async {
    try {
      final response = await _dio.get(
        '/api/v4/brand/image',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload brand image
  Future<void> uploadBrandImage(File image) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
          contentType: DioMediaType.parse('image/png'),
        ),
      });

      await _dio.post('/api/v4/brand/image', data: formData);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete brand image
  Future<void> deleteBrandImage() async {
    try {
      await _dio.delete('/api/v4/brand/image');
    } catch (e) {
      rethrow;
    }
  }
}
