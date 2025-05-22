import 'dart:io';

import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for emoji-related endpoints
class MEmojisApi {
  final Dio _dio;

  MEmojisApi(this._dio);

  /// Get all custom emojis
  Future<List<MEmoji>> getCustomEmojis({int page = 0, int perPage = 60}) async {
    try {
      final response = await _dio.get(
        '/api/v4/emoji',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).map((emojiData) => MEmoji.fromJson(emojiData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create a custom emoji
  Future<MEmoji> createCustomEmoji({
    required String name,
    required File image,
  }) async {
    try {
      final formData = FormData.fromMap({
        'emoji': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
          contentType: DioMediaType.parse('image/png'),
        ),
      });

      final response = await _dio.post(
        '/api/v4/emoji',
        data: formData,
        options: Options(
          headers: {
            'Content-Disposition': 'form-data; name="emoji"; filename="${image.path.split('/').last}"',
            'Content-Type': 'image/png',
          },
        ),
      );
      return MEmoji.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a custom emoji
  Future<MEmoji> getCustomEmoji(String emojiId) async {
    try {
      final response = await _dio.get('/api/v4/emoji/$emojiId');
      return MEmoji.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a custom emoji
  Future<void> deleteCustomEmoji(String emojiId) async {
    try {
      await _dio.delete('/api/v4/emoji/$emojiId');
    } catch (e) {
      rethrow;
    }
  }

  /// Get custom emoji image
  Future<List<int>> getCustomEmojiImage(String emojiId) async {
    try {
      final response = await _dio.get(
        '/api/v4/emoji/$emojiId/image',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Search custom emojis
  Future<List<MEmoji>> searchCustomEmojis(MEmojiSearchRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v4/emoji/search',
        data: request.toJson(),
      );
      return (response.data as List).map((emojiData) => MEmoji.fromJson(emojiData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get custom emoji by name
  Future<MEmoji> getCustomEmojiByName(String emojiName) async {
    try {
      final response = await _dio.get('/api/v4/emoji/name/$emojiName');
      return MEmoji.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get custom emojis by name
  Future<List<MEmoji>> getCustomEmojisByName(List<String> emojiNames) async {
    try {
      final response = await _dio.post('/api/v4/emoji/names', data: emojiNames);
      return (response.data as List).map((emojiData) => MEmoji.fromJson(emojiData)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
