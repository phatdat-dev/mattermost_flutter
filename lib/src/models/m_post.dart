import 'm_meta_data.dart';

/// Post model
class MPost {
  final String id;
  final String channelId;
  final String userId;
  final String message;
  final String type;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;
  final int? editAt;
  final bool? isPinned;
  final String? rootId;
  final String? parentId;
  final String? originalId;
  final Map<String, dynamic>? props;
  final MMetaData? metadata;
  final List<String>? fileIds;
  final String? hashtag;

  MPost({
    required this.id,
    required this.channelId,
    required this.userId,
    required this.message,
    this.type = '',
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.editAt,
    this.isPinned,
    this.rootId,
    this.parentId,
    this.originalId,
    this.props,
    this.metadata,
    this.fileIds,
    this.hashtag,
  });

  factory MPost.fromJson(Map<String, dynamic> json) {
    return MPost(
      id: json['id'] ?? '',
      channelId: json['channel_id'] ?? '',
      userId: json['user_id'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
      editAt: json['edit_at'], // Field mới
      isPinned: json['is_pinned'],
      rootId: json['root_id'],
      parentId: json['parent_id'],
      originalId: json['original_id'],
      props: json['props'],
      metadata: json['metadata'] != null ? MMetaData.fromJson(json['metadata'] as Map<String, dynamic>) : null,
      fileIds: (json['file_ids'] as List?)?.map((e) => e.toString()).toList(),
      hashtag: json['hashtag'],
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
      if (editAt != null) 'edit_at': editAt, // Field mới
      if (isPinned != null) 'is_pinned': isPinned,
      if (rootId != null) 'root_id': rootId,
      if (parentId != null) 'parent_id': parentId,
      if (originalId != null) 'original_id': originalId,
      if (props != null) 'props': props,
      if (metadata != null) 'metadata': metadata?.toJson(),
      if (fileIds != null) 'file_ids': fileIds,
      if (hashtag != null) 'hashtag': hashtag,
    };
  }
}

/// Post list model
class MPostList {
  final Map<String, MPost> posts;
  final List<String> order;
  final String? nextPostId;
  final String? prevPostId;
  final bool? hasNext;

  MPostList({
    required this.posts,
    required this.order,
    this.nextPostId,
    this.prevPostId,
    this.hasNext,
  });

  factory MPostList.fromJson(Map<String, dynamic> json) {
    final postsMap = <String, MPost>{};
    final postsJson = json['posts'] as Map<String, dynamic>? ?? {};

    postsJson.forEach((key, value) {
      postsMap[key] = MPost.fromJson(value);
    });

    return MPostList(
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
