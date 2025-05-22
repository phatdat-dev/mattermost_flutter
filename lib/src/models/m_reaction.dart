/// Reaction model
class MReaction {
  final String userId;
  final String postId;
  final String emojiName;
  final int? createAt;

  MReaction({
    required this.userId,
    required this.postId,
    required this.emojiName,
    this.createAt,
  });

  factory MReaction.fromJson(Map<String, dynamic> json) {
    return MReaction(
      userId: json['user_id'] ?? '',
      postId: json['post_id'] ?? '',
      emojiName: json['emoji_name'] ?? '',
      createAt: json['create_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'post_id': postId,
      'emoji_name': emojiName,
      if (createAt != null) 'create_at': createAt,
    };
  }
}

/// Reaction request model
class MReactionRequest {
  final String userId;
  final String postId;
  final String emojiName;

  MReactionRequest({
    required this.userId,
    required this.postId,
    required this.emojiName,
  });

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'post_id': postId, 'emoji_name': emojiName};
  }
}
