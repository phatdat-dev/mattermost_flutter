import 'dart:io';

import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for file-related endpoints
class MFilesApi {
  final Dio _dio;

  MFilesApi(this._dio);

  /// Upload a file
  Future<MFileUploadResponse> uploadFile({
    required String channelId,
    required File file,
    String? fileName,
    String? clientId,
  }) async {
    try {
      final String name = fileName ?? file.path.split('/').last;
      final String mimeType = _getMimeType(name);

      final formData = FormData.fromMap({
        'channel_id': channelId,
        'files': await MultipartFile.fromFile(
          file.path,
          filename: name,
          contentType: DioMediaType.parse(mimeType),
        ),
        if (clientId != null) 'client_ids': clientId,
      });

      final response = await _dio.post('/api/v4/files', data: formData);
      return MFileUploadResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get file info
  Future<MFileInfo> getFileInfo(String fileId) async {
    try {
      final response = await _dio.get('/api/v4/files/$fileId/info');
      return MFileInfo.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get file link
  Future<String> getFileLink(String fileId) async {
    try {
      final response = await _dio.get('/api/v4/files/$fileId/link');
      return response.data['link'];
    } catch (e) {
      rethrow;
    }
  }

  /// Download file
  Future<List<int>> downloadFile(String fileId) async {
    try {
      final response = await _dio.get(
        '/api/v4/files/$fileId',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get file thumbnail
  Future<List<int>> getFileThumbnail(String fileId) async {
    try {
      final response = await _dio.get(
        '/api/v4/files/$fileId/thumbnail',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get file preview
  Future<List<int>> getFilePreview(String fileId) async {
    try {
      final response = await _dio.get(
        '/api/v4/files/$fileId/preview',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get public file link
  Future<String> getPublicFileLink(String fileId) async {
    try {
      final response = await _dio.get('/api/v4/files/$fileId/link');
      return response.data['link'];
    } catch (e) {
      rethrow;
    }
  }

  /// Helper method to determine MIME type from file extension
  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'mp4':
        return 'video/mp4';
      case 'mp3':
        return 'audio/mpeg';
      default:
        return 'application/octet-stream';
    }
  }
}
