import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for post-related endpoints
class PostsApi {
  final Dio _dio;

  PostsApi(this._dio);

  /// Create a new post
  Future<Post> createPost(CreatePostRequest request) async {
    try {
      final response = await _dio.post('/api/v4/posts', data: request.toJson());
      return Post.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a post by ID
  Future<Post> getPost(String postId) async {
    try {
      final response = await _dio.get('/api/v4/posts/$postId');
      return Post.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a post
  Future<Post> updatePost(String postId, UpdatePostRequest request) async {
    try {
      final response = await _dio.put('/api/v4/posts/$postId', data: request.toJson());
      return Post.fromJson(response.data);
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
  Future<PostList> getPostsForChannel(String channelId, {int page = 0, int perPage = 60, String? since, String? before, String? after}) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page.toString(), 'per_page': perPage.toString()};

      if (since != null) queryParams['since'] = since;
      if (before != null) queryParams['before'] = before;
      if (after != null) queryParams['after'] = after;

      final response = await _dio.get('/api/v4/channels/$channelId/posts', queryParameters: queryParams);
      return PostList.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a thread
  Future<PostList> getPostThread(String postId) async {
    try {
      final response = await _dio.get('/api/v4/posts/$postId/thread');
      return PostList.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Search posts
  Future<PostList> searchPosts(String teamId, PostSearchRequest request) async {
    try {
      final response = await _dio.post('/api/v4/teams/$teamId/posts/search', data: request.toJson());
      return PostList.fromJson(response.data);
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
  Future<Reaction> addReaction(ReactionRequest request) async {
    try {
      final response = await _dio.post('/api/v4/reactions', data: request.toJson());
      return Reaction.fromJson(response.data);
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
  Future<List<Reaction>> getReactions(String postId) async {
    try {
      final response = await _dio.get('/api/v4/posts/$postId/reactions');
      return (response.data as List).map((reactionData) => Reaction.fromJson(reactionData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get flagged posts
  Future<PostList> getFlaggedPosts(String userId, {String? channelId, String? teamId, int page = 0, int perPage = 60}) async {
    try {
      final Map<String, dynamic> queryParams = {'page': page.toString(), 'per_page': perPage.toString()};

      if (channelId != null) queryParams['channel_id'] = channelId;
      if (teamId != null) queryParams['team_id'] = teamId;

      final response = await _dio.get('/api/v4/users/$userId/posts/flagged', queryParameters: queryParams);
      return PostList.fromJson(response.data);
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
