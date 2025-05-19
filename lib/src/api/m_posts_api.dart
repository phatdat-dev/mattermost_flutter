import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for post-related endpoints
class MPostsApi {
  final Dio _dio;

  MPostsApi(this._dio);

  /// Create a new post
  Future<MPost> createPost(MCreatePostRequest request) async {
    try {
      final response = await _dio.post('/api/v4/posts', data: request.toJson());
      return MPost.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a post by ID
  Future<MPost> getPost(String postId) async {
    try {
      final response = await _dio.get('/api/v4/posts/$postId');
      return MPost.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a post
  Future<MPost> updatePost(String postId, MUpdatePostRequest request) async {
    try {
      final response = await _dio.put('/api/v4/posts/$postId', data: request.toJson());
      return MPost.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    try {
      await _dio.delete('/api/v4/posts/$postId');
    } catch (e) {
      rethrow;
    }
  }

  /// Get posts for a channel
  Future<MPostList> getPostsForChannel(String channelId, {int page = 0, int perPage = 60, String? since, String? before, String? after}) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page.toString(), 'per_page': perPage.toString()};

      if (since != null) queryParams['since'] = since;
      if (before != null) queryParams['before'] = before;
      if (after != null) queryParams['after'] = after;

      final response = await _dio.get('/api/v4/channels/$channelId/posts', queryParameters: queryParams);
      return MPostList.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a thread
  Future<MPostList> getPostThread(String postId) async {
    try {
      final response = await _dio.get('/api/v4/posts/$postId/thread');
      return MPostList.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Search posts
  Future<MPostList> searchPosts(String teamId, MPostSearchRequest request) async {
    try {
      final response = await _dio.post('/api/v4/teams/$teamId/posts/search', data: request.toJson());
      return MPostList.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Pin a post
  Future<void> pinPost(String postId) async {
    try {
      await _dio.post('/api/v4/posts/$postId/pin');
    } catch (e) {
      rethrow;
    }
  }

  /// Unpin a post
  Future<void> unpinPost(String postId) async {
    try {
      await _dio.post('/api/v4/posts/$postId/unpin');
    } catch (e) {
      rethrow;
    }
  }

  /// Add reaction to a post
  Future<MReaction> addReaction(MReactionRequest request) async {
    try {
      final response = await _dio.post('/api/v4/reactions', data: request.toJson());
      return MReaction.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Remove reaction from a post
  Future<void> removeReaction(String userId, String postId, String emojiName) async {
    try {
      await _dio.delete('/api/v4/users/$userId/posts/$postId/reactions/$emojiName');
    } catch (e) {
      rethrow;
    }
  }

  /// Get reactions for a post
  Future<List<MReaction>> getReactions(String postId) async {
    try {
      final response = await _dio.get('/api/v4/posts/$postId/reactions');
      return (response.data as List).map((reactionData) => MReaction.fromJson(reactionData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get flagged posts
  Future<MPostList> getFlaggedPosts(String userId, {String? channelId, String? teamId, int page = 0, int perPage = 60}) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page.toString(), 'per_page': perPage.toString()};

      if (channelId != null) queryParams['channel_id'] = channelId;
      if (teamId != null) queryParams['team_id'] = teamId;

      final response = await _dio.get('/api/v4/users/$userId/posts/flagged', queryParameters: queryParams);
      return MPostList.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Flag a post
  Future<void> flagPost(String postId) async {
    try {
      await _dio.post('/api/v4/posts/$postId/flag');
    } catch (e) {
      rethrow;
    }
  }

  /// Unflag a post
  Future<void> unflagPost(String postId) async {
    try {
      await _dio.post('/api/v4/posts/$postId/unflag');
    } catch (e) {
      rethrow;
    }
  }
}
