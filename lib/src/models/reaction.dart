/// Reaction model
class Reaction {
  final String userId;
  final String postId;
  final String emojiName;
  final int? createAt;

  Reaction({
    required this.userId,
    required this.postId,
    required this.emojiName,
    this.createAt,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
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
class ReactionRequest {
  final String userId;
  final String postId;
  final String emojiName;

  ReactionRequest({
    required this.userId,
    required this.postId,
    required this.emojiName,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'post_id': postId,
      'emoji_name': emojiName,
    };
  }
}
