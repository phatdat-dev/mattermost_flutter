/// Bot model
class MBot {
  final String userId;
  final String username;
  final String displayName;
  final String description;
  final String ownerId;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;

  MBot({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.description,
    required this.ownerId,
    this.createAt,
    this.updateAt,
    this.deleteAt,
  });

  factory MBot.fromJson(Map<String, dynamic> json) {
    return MBot(
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['display_name'] ?? '',
      description: json['description'] ?? '',
      ownerId: json['owner_id'] ?? '',
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'display_name': displayName,
      'description': description,
      'owner_id': ownerId,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
    };
  }
}

/// Create bot request
class MCreateBotRequest {
  final String username;
  final String displayName;
  final String description;

  MCreateBotRequest({
    required this.username,
    required this.displayName,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'display_name': displayName,
      'description': description,
    };
  }
}
