/// Post model
class Post {
  final String id;
  final String channelId;
  final String userId;
  final String message;
  final String type;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;
  final bool? isPinned;
  final String? rootId;
  final String? parentId;
  final String? originalId;
  final Map<String, dynamic>? props;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? fileIds;

  Post({
    required this.id,
    required this.channelId,
    required this.userId,
    required this.message,
    this.type = '',
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.isPinned,
    this.rootId,
    this.parentId,
    this.originalId,
    this.props,
    this.metadata,
    this.fileIds,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      channelId: json['channel_id'] ?? '',
      userId: json['user_id'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
      isPinned: json['is_pinned'],
      rootId: json['root_id'],
      parentId: json['parent_id'],
      originalId: json['original_id'],
      props: json['props'],
      metadata: json['metadata'],
      fileIds: json['file_ids'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel_id': channelId,
      'user_id': userId,
      'message': message,
      'type': type,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
      if (isPinned != null) 'is_pinned': isPinned,
      if (rootId != null) 'root_id': rootId,
      if (parentId != null) 'parent_id': parentId,
      if (originalId != null) 'original_id': originalId,
      if (props != null) 'props': props,
      if (metadata != null) 'metadata': metadata,
      if (fileIds != null) 'file_ids': fileIds,
    };
  }
}

/// Post list model
class PostList {
  final Map<String, Post> posts;
  final List<String> order;
  final String? nextPostId;
  final String? prevPostId;
  final bool? hasNext;

  PostList({required this.posts, required this.order, this.nextPostId, this.prevPostId, this.hasNext});

  factory PostList.fromJson(Map<String, dynamic> json) {
    final postsMap = <String, Post>{};
    final postsJson = json['posts'] as Map<String, dynamic>? ?? {};

    postsJson.forEach((key, value) {
      postsMap[key] = Post.fromJson(value);
    });

    return PostList(
      posts: postsMap,
      order: (json['order'] as List<dynamic>? ?? []).cast<String>(),
      nextPostId: json['next_post_id'],
      prevPostId: json['prev_post_id'],
      hasNext: json['has_next'],
    );
  }

  Map<String, dynamic> toJson() {
    final postsJson = <String, dynamic>{};
    posts.forEach((key, value) {
      postsJson[key] = value.toJson();
    });

    return {
      'posts': postsJson,
      'order': order,
      if (nextPostId != null) 'next_post_id': nextPostId,
      if (prevPostId != null) 'prev_post_id': prevPostId,
      if (hasNext != null) 'has_next': hasNext,
    };
  }
}

/// Create post request
class CreatePostRequest {
  final String channelId;
  final String message;
  final String? rootId;
  final String? fileIds;
  final Map<String, dynamic>? props;

  CreatePostRequest({required this.channelId, required this.message, this.rootId, this.fileIds, this.props});

  Map<String, dynamic> toJson() {
    return {
      'channel_id': channelId,
      'message': message,
      if (rootId != null) 'root_id': rootId,
      if (fileIds != null) 'file_ids': fileIds,
      if (props != null) 'props': props,
    };
  }
}

/// Update post request
class UpdatePostRequest {
  final String id;
  final String message;
  final bool? isPinned;
  final Map<String, dynamic>? props;

  UpdatePostRequest({required this.id, required this.message, this.isPinned, this.props});

  Map<String, dynamic> toJson() {
    return {'id': id, 'message': message, if (isPinned != null) 'is_pinned': isPinned, if (props != null) 'props': props};
  }
}

/// Post search request
class PostSearchRequest {
  final String terms;
  final bool? isOrSearch;
  final int? timeZoneOffset;
  final bool? includeDeletedChannels;
  final int? page;
  final int? perPage;

  PostSearchRequest({required this.terms, this.isOrSearch, this.timeZoneOffset, this.includeDeletedChannels, this.page, this.perPage});

  Map<String, dynamic> toJson() {
    return {
      'terms': terms,
      if (isOrSearch != null) 'is_or_search': isOrSearch,
      if (timeZoneOffset != null) 'time_zone_offset': timeZoneOffset,
      if (includeDeletedChannels != null) 'include_deleted_channels': includeDeletedChannels,
      if (page != null) 'page': page,
      if (perPage != null) 'per_page': perPage,
    };
  }
}
