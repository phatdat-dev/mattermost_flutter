import 'dart:io';

import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for file-related endpoints
class MFilesApi {
  final Dio _dio;

  MFilesApi(this._dio);

  /// Upload a file
  ///
  /// Uploads a file that can later be attached to a post.
  /// This request can either be a multipart/form-data request with a channel_id, files and optional
  /// client_ids defined in the FormData, or it can be a request with the channel_id and filename
  /// defined as query parameters with the contents of a single file in the body of the request.
  ///
  /// ##### Permissions
  /// Must have `upload_file` permission.
  Future<MFileUploadResponse> uploadFile({
    required String channelId,
    required File file,
    String? fileName,
    String? clientId,
    bool bookmark = false,
  }) async {
    try {
      final String name = fileName ?? file.path.split('/').last;

      // Using multipart/form-data approach (recommended)
      final formData = FormData.fromMap({
        'channel_id': channelId,
        'files': await MultipartFile.fromFile(
          file.path,
          filename: name,
        ),
        if (clientId != null) 'client_ids': clientId,
      });

      final Map<String, dynamic> queryParams = {};
      if (bookmark) {
        queryParams['bookmark'] = 'true';
      }

      final response = await _dio.post(
        '/api/v4/files',
        data: formData,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return MFileUploadResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Upload multiple files
  ///
  /// Uploads multiple files that can later be attached to a post.
  /// ##### Permissions
  /// Must have `upload_file` permission.
  Future<MFileUploadResponse> uploadFiles({
    required String channelId,
    required List<File> files,
    List<String>? clientIds,
    bool bookmark = false,
  }) async {
    try {
      final List<MultipartFile> multipartFiles = [];

      for (final file in files) {
        multipartFiles.add(
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        );
      }

      final Map<String, dynamic> formDataMap = {
        'channel_id': channelId,
        'files': multipartFiles,
      };

      if (clientIds != null && clientIds.isNotEmpty) {
        formDataMap['client_ids'] = clientIds.join(',');
      }

      final formData = FormData.fromMap(formDataMap);

      final Map<String, dynamic> queryParams = {};
      if (bookmark) {
        queryParams['bookmark'] = 'true';
      }

      final response = await _dio.post(
        '/api/v4/files',
        data: formData,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return MFileUploadResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a file
  ///
  /// Gets a file that has been uploaded previously.
  /// ##### Permissions
  /// Must have `read_channel` permission or be uploader of the file.
  Future<List<int>> getFile(String fileId) async {
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

  /// Get a file's thumbnail
  ///
  /// Gets a file's thumbnail.
  /// ##### Permissions
  /// Must have `read_channel` permission or be uploader of the file.
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

  /// Get a file's preview
  ///
  /// Gets a file's preview.
  /// ##### Permissions
  /// Must have `read_channel` permission or be uploader of the file.
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

  /// Get a public file link
  ///
  /// Gets a public link for a file that can be accessed without logging into Mattermost.
  /// ##### Permissions
  /// Must have `read_channel` permission or be uploader of the file.
  Future<String> getFileLink(String fileId) async {
    try {
      final response = await _dio.get('/api/v4/files/$fileId/link');
      return response.data['link'];
    } catch (e) {
      rethrow;
    }
  }

  /// Get metadata for a file
  ///
  /// Gets a file's info.
  /// ##### Permissions
  /// Must have `read_channel` permission or be uploader of the file.
  Future<MFileInfo> getFileInfo(String fileId) async {
    try {
      final response = await _dio.get('/api/v4/files/$fileId/info');
      return MFileInfo.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a public file
  ///
  /// ##### Permissions
  /// No permissions required.
  Future<List<int>> getFilePublic(String fileId, String hash) async {
    try {
      final response = await _dio.get(
        '/files/$fileId/public',
        queryParameters: {'h': hash},
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Search files in a team
  ///
  /// Search for files in a team based on file name, extension and file content
  /// (if file content extraction is enabled and supported for the files).
  ///
  /// __Minimum server version__: 5.34
  /// ##### Permissions
  /// Must be authenticated and have the `view_team` permission.
  Future<MFileSearchResponse> searchFilesInTeam({
    required String teamId,
    required String terms,
    required bool isOrSearch,
    int timeZoneOffset = 0,
    bool includeDeletedChannels = false,
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final formData = FormData.fromMap({
        'terms': terms,
        'is_or_search': isOrSearch,
        'time_zone_offset': timeZoneOffset,
        'include_deleted_channels': includeDeletedChannels,
        'page': page,
        'per_page': perPage,
      });

      final response = await _dio.post(
        '/api/v4/teams/$teamId/files/search',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return MFileSearchResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Search files across the teams of the current user
  ///
  /// Search for files in the teams of the current user based on file name,
  /// extension and file content (if file content extraction is enabled and
  /// supported for the files).
  ///
  /// __Minimum server version__: 10.2
  /// ##### Permissions
  /// Must be authenticated and have the `view_team` permission.
  Future<MFileSearchResponse> searchFiles({
    required String terms,
    required bool isOrSearch,
    int timeZoneOffset = 0,
    bool includeDeletedChannels = false,
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final formData = FormData.fromMap({
        'terms': terms,
        'is_or_search': isOrSearch,
        'time_zone_offset': timeZoneOffset,
        'include_deleted_channels': includeDeletedChannels,
        'page': page,
        'per_page': perPage,
      });

      final response = await _dio.post(
        '/api/v4/files/search',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return MFileSearchResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
