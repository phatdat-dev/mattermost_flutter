import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for post-related endpoints
class MPostsApi {
  final Dio _dio;

  MPostsApi(this._dio);

  /// Create a new post
  ///
  /// Create a new post in a channel. To create the post as a comment on another post, provide `root_id`.
  /// ##### Permissions
  /// Must have `create_post` permission for the channel the post is being created in.
  ///
  /// Parameters:
  /// - [channelId]: The channel ID to post in
  /// - [message]: The message contents, can be formatted with Markdown
  /// - [rootId]: The post ID to comment on
  /// - [fileIds]: A list of file IDs to associate with the post. Note that posts are limited to 5 files maximum.
  /// - [props]: A general JSON property bag to attach to the post
  /// - [metadata]: A JSON object to add post metadata, e.g the post's priority
  /// - [setOnline]: Whether to set the user status as online or not
  Future<MPost> createPost({
    required String channelId,
    required String message,
    String? rootId,
    List<String>? fileIds,
    Map<String, dynamic>? props,
    Map<String, dynamic>? metadata,
    bool? setOnline,
  }) async {
    try {
      final data = <String, dynamic>{
        'channel_id': channelId,
        'message': message,
      };
      if (rootId != null) data['root_id'] = rootId;
      if (fileIds != null) data['file_ids'] = fileIds;
      if (props != null) data['props'] = props;
      if (metadata != null) data['metadata'] = metadata;

      final queryParams = <String, dynamic>{};
      if (setOnline != null) queryParams['set_online'] = setOnline.toString();

      final response = await _dio.post(
        '/api/v4/posts',
        data: data,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return MPost.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a post by ID
  ///
  /// Get a single post.
  /// ##### Permissions
  /// Must have `read_channel` permission for the channel the post is in or if the channel is public,
  /// have the `read_public_channels` permission for the team.
  ///
  /// Parameters:
  /// - [postId]: ID of the post to get
  /// - [includeDeleted]: Defines if result should include deleted posts, must have 'manage_system' (admin) permission
  Future<MPost> getPost(String postId, {bool? includeDeleted}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (includeDeleted != null) queryParams['include_deleted'] = includeDeleted.toString();

      final response = await _dio.get(
        '/api/v4/posts/$postId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return MPost.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a post
  ///
  /// Update a post. Only the fields listed below are updatable, omitted fields will be treated as blank.
  /// ##### Permissions
  /// Must have `edit_post` permission for the channel the post is in.
  ///
  /// Parameters:
  /// - [id]: ID of the post to update
  /// - [message]: The message text of the post
  /// - [isPinned]: Set to `true` to pin the post to the channel it is in
  /// - [hasReactions]: Set to `true` if the post has reactions to it
  /// - [props]: A general JSON property bag to attach to the post
  Future<MPost> updatePost({
    required String id,
    String? message,
    bool? isPinned,
    bool? hasReactions,
    Map<String, dynamic>? props,
  }) async {
    try {
      final data = <String, dynamic>{
        'id': id,
      };
      if (message != null) data['message'] = message;
      if (isPinned != null) data['is_pinned'] = isPinned;
      if (hasReactions != null) data['has_reactions'] = hasReactions;
      if (props != null) data['props'] = props;

      final response = await _dio.put(
        '/api/v4/posts/$id',
        data: data,
      );
      return MPost.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a ephemeral post
  ///
  /// Create a new ephemeral post in a channel.
  /// ##### Permissions
  /// Must have `create_post_ephemeral` permission (currently only given to system admin)
  ///
  /// Parameters:
  /// - [userId]: The target user id for the ephemeral post
  /// - [channelId]: The channel ID to post in
  /// - [message]: The message contents, can be formatted with Markdown
  Future<MPost> createEphemeralPost({
    required String userId,
    required String channelId,
    required String message,
  }) async {
    try {
      final data = {
        'user_id': userId,
        'post': {
          'channel_id': channelId,
          'message': message,
        },
      };

      final response = await _dio.post('/api/v4/posts/ephemeral', data: data);
      return MPost.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Patch a post
  ///
  /// Partially update a post by providing only the fields you want to update.
  /// Omitted fields will not be updated.
  /// ##### Permissions
  /// Must have the `edit_post` permission.
  ///
  /// Parameters:
  /// - [postId]: Post GUID
  /// - [message]: The message text of the post
  /// - [isPinned]: Set to `true` to pin the post to the channel it is in
  /// - [fileIds]: The list of files attached to this post
  /// - [hasReactions]: Set to `true` if the post has reactions to it
  /// - [props]: A general JSON property bag to attach to the post
  Future<MPost> patchPost({
    required String postId,
    String? message,
    bool? isPinned,
    List<String>? fileIds,
    bool? hasReactions,
    Map<String, dynamic>? props,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (message != null) data['message'] = message;
      if (isPinned != null) data['is_pinned'] = isPinned;
      if (fileIds != null) data['file_ids'] = fileIds;
      if (hasReactions != null) data['has_reactions'] = hasReactions;
      if (props != null) data['props'] = props;

      final response = await _dio.put(
        '/api/v4/posts/$postId/patch',
        data: data,
      );
      return MPost.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a post
  ///
  /// Soft deletes a post, by marking the post as deleted in the database.
  /// Soft deleted posts will not be returned in post queries.
  /// ##### Permissions
  /// Must be logged in as the user or have `delete_others_posts` permission.
  ///
  /// Parameters:
  /// - [postId]: ID of the post to delete
  Future<void> deletePost(String postId) async {
    try {
      await _dio.delete('/api/v4/posts/$postId');
    } catch (e) {
      rethrow;
    }
  }

  /// Get posts for a channel
  Future<MPostList> getPostsForChannel(
    String channelId, {
    int page = 0,
    int perPage = 60,
    String? since,
    String? before,
    String? after,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (since != null) queryParams['since'] = since;
      if (before != null) queryParams['before'] = before;
      if (after != null) queryParams['after'] = after;

      final response = await _dio.get(
        '/api/v4/channels/$channelId/posts',
        queryParameters: queryParams,
      );
      return MPostList.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get a thread
  ///
  /// Get a post and the rest of the posts in the same thread.
  /// ##### Permissions
  /// Must have `read_channel` permission for the channel the post is in or if the channel is public,
  /// have the `read_public_channels` permission for the team.
  ///
  /// Parameters:
  /// - [postId]: ID of a post in the thread
  /// - [perPage]: The number of posts per page
  /// - [fromPost]: The post_id to return the next page of posts from
  /// - [fromCreateAt]: The create_at timestamp to return the next page of posts from
  /// - [fromUpdateAt]: The update_at timestamp to return the next page of posts from. You cannot set this flag with direction=down.
  /// - [direction]: The direction to return the posts. Either up or down.
  /// - [skipFetchThreads]: Whether to skip fetching threads or not
  /// - [collapsedThreads]: Whether the client uses CRT or not
  /// - [collapsedThreadsExtended]: Whether to return the associated users as part of the response or not
  /// - [updatesOnly]: This flag is used to make the API work with the updateAt value. If you set this flag, you must set a value for fromUpdateAt.
  Future<MPostList> getPostThread(
    String postId, {
    int? perPage,
    String? fromPost,
    int? fromCreateAt,
    int? fromUpdateAt,
    String? direction,
    bool? skipFetchThreads,
    bool? collapsedThreads,
    bool? collapsedThreadsExtended,
    bool? updatesOnly,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (perPage != null) queryParams['perPage'] = perPage.toString();
      if (fromPost != null) queryParams['fromPost'] = fromPost;
      if (fromCreateAt != null) queryParams['fromCreateAt'] = fromCreateAt.toString();
      if (fromUpdateAt != null) queryParams['fromUpdateAt'] = fromUpdateAt.toString();
      if (direction != null) queryParams['direction'] = direction;
      if (skipFetchThreads != null) queryParams['skipFetchThreads'] = skipFetchThreads.toString();
      if (collapsedThreads != null) queryParams['collapsedThreads'] = collapsedThreads.toString();
      if (collapsedThreadsExtended != null) queryParams['collapsedThreadsExtended'] = collapsedThreadsExtended.toString();
      if (updatesOnly != null) queryParams['updatesOnly'] = updatesOnly.toString();

      final response = await _dio.get(
        '/api/v4/posts/$postId/thread',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return MPostList.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Search posts
  Future<MPostList> searchPosts(
    String teamId, {
    required String terms,
    bool? isOrSearch,
    int? timeZoneOffset,
    bool? includeDeletedChannels,
    int? page,
    int? perPage,
  }) async {
    try {
      final data = <String, dynamic>{
        'terms': terms,
      };
      if (isOrSearch != null) data['is_or_search'] = isOrSearch;
      if (timeZoneOffset != null) data['time_zone_offset'] = timeZoneOffset;
      if (includeDeletedChannels != null) data['include_deleted_channels'] = includeDeletedChannels;
      if (page != null) data['page'] = page;
      if (perPage != null) data['per_page'] = perPage;

      final response = await _dio.post(
        '/api/v4/teams/$teamId/posts/search',
        data: data,
      );
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
  Future<MReaction> addReaction({
    required String userId,
    required String postId,
    required String emojiName,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v4/reactions',
        data: {
          'user_id': userId,
          'post_id': postId,
          'emoji_name': emojiName,
        },
      );
      return MReaction.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Remove reaction from a post
  Future<void> removeReaction(
    String userId,
    String postId,
    String emojiName,
  ) async {
    try {
      await _dio.delete(
        '/api/v4/users/$userId/posts/$postId/reactions/$emojiName',
      );
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
  Future<MPostList> getFlaggedPosts(
    String userId, {
    String? channelId,
    String? teamId,
    int page = 0,
    int perPage = 60,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (channelId != null) queryParams['channel_id'] = channelId;
      if (teamId != null) queryParams['team_id'] = teamId;

      final response = await _dio.get(
        '/api/v4/users/$userId/posts/flagged',
        queryParameters: queryParams,
      );
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

  /// Get file info for post
  ///
  /// Gets a list of file information objects for the files attached to a post.
  /// ##### Permissions
  /// Must have `read_channel` permission for the channel the post is in.
  ///
  /// Parameters:
  /// - [postId]: ID of the post
  /// - [includeDeleted]: Defines if result should include deleted posts, must have 'manage_system' (admin) permission
  Future<List<MFileInfo>> getFileInfosForPost(String postId, {bool? includeDeleted}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (includeDeleted != null) queryParams['include_deleted'] = includeDeleted.toString();

      final response = await _dio.get(
        '/api/v4/posts/$postId/files/info',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return (response.data as List).map((fileData) => MFileInfo.fromJson(fileData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Perform a post action
  ///
  /// Perform a post action, which allows users to interact with integrations through posts.
  /// ##### Permissions
  /// Must be authenticated and have the `read_channel` permission to the channel the post is in.
  ///
  /// Parameters:
  /// - [postId]: Post GUID
  /// - [actionId]: Action GUID
  Future<void> doPostAction(String postId, String actionId) async {
    try {
      await _dio.post('/api/v4/posts/$postId/actions/$actionId');
    } catch (e) {
      rethrow;
    }
  }

  /// Get posts by a list of ids
  ///
  /// Fetch a list of posts based on the provided postIDs
  /// ##### Permissions
  /// Must have `read_channel` permission for the channel the post is in or if the channel is public,
  /// have the `read_public_channels` permission for the team.
  ///
  /// Parameters:
  /// - [postIds]: List of post ids
  Future<List<MPost>> getPostsByIds(List<String> postIds) async {
    try {
      final response = await _dio.post('/api/v4/posts/ids', data: postIds);
      return (response.data as List).map((postData) => MPost.fromJson(postData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Move a post (and any posts within that post's thread)
  ///
  /// Move a post/thread to another channel.
  /// THIS IS A BETA FEATURE. The API is subject to change without notice.
  /// ##### Permissions
  /// Must have `read_channel` permission for the channel the post is in.
  /// Must have `write_post` permission for the channel the post is being moved to.
  /// __Minimum server version__: 9.3
  ///
  /// Parameters:
  /// - [postId]: The identifier of the post to move
  /// - [channelId]: The channel identifier of where the post/thread is to be moved
  Future<void> moveThread(String postId, String channelId) async {
    try {
      await _dio.post(
        '/api/v4/posts/$postId/move',
        data: {'channel_id': channelId},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Restores a past version of a post
  ///
  /// Restores the post with `post_id` to its past version having the ID `restore_version_id`.
  /// ##### Permissions
  /// Must have `read_channel` permission for the channel the post is in.
  /// Must have `edit_post` permission for the channel the post is being moved to.
  /// Must be the author of the post being restored.
  /// __Minimum server version__: 10.5
  ///
  /// Parameters:
  /// - [postId]: The identifier of the post to restore
  /// - [restoreVersionId]: The identifier of the past version of post to restore to
  Future<MPost> restorePostVersion(String postId, String restoreVersionId) async {
    try {
      final response = await _dio.post('/api/v4/posts/$postId/restore/$restoreVersionId');
      return MPost.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Bulk get the reaction for posts
  ///
  /// Get a list of reactions made by all users to a given post.
  /// ##### Permissions
  /// Must have `read_channel` permission for the channel the post is in.
  /// __Minimum server version__: 5.8
  ///
  /// Parameters:
  /// - [postIds]: Array of post IDs
  Future<Map<String, List<MReaction>>> getBulkReactions(List<String> postIds) async {
    try {
      final response = await _dio.post('/api/v4/posts/ids/reactions', data: postIds);
      final Map<String, dynamic> rawData = response.data;
      final Map<String, List<MReaction>> result = {};

      rawData.forEach((postId, reactions) {
        result[postId] = (reactions as List).map((reaction) => MReaction.fromJson(reaction)).toList();
      });

      return result;
    } catch (e) {
      rethrow;
    }
  }
}
