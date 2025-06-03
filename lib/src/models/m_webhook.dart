/// Incoming webhook model
class MIncomingWebhook {
  final String id;
  final String channelId;
  final String description;
  final String displayName;
  final String userId;
  final String teamId;
  final String username;
  final String iconUrl;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;

  MIncomingWebhook({
    required this.id,
    required this.channelId,
    required this.description,
    required this.displayName,
    required this.userId,
    required this.teamId,
    this.username = '',
    this.iconUrl = '',
    this.createAt,
    this.updateAt,
    this.deleteAt,
  });

  factory MIncomingWebhook.fromJson(Map<String, dynamic> json) {
    return MIncomingWebhook(
      id: json['id'] ?? '',
      channelId: json['channel_id'] ?? '',
      description: json['description'] ?? '',
      displayName: json['display_name'] ?? '',
      userId: json['user_id'] ?? '',
      teamId: json['team_id'] ?? '',
      username: json['username'] ?? '',
      iconUrl: json['icon_url'] ?? '',
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel_id': channelId,
      'description': description,
      'display_name': displayName,
      'user_id': userId,
      'team_id': teamId,
      'username': username,
      'icon_url': iconUrl,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
    };
  }
}

/// Outgoing webhook model
class MOutgoingWebhook {
  final String id;
  final String token;
  final String creatorId;
  final String channelId;
  final String teamId;
  final String triggerWords;
  final String triggerWhen;
  final String callbackUrls;
  final String displayName;
  final String description;
  final String contentType;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;

  MOutgoingWebhook({
    required this.id,
    required this.token,
    required this.creatorId,
    required this.channelId,
    required this.teamId,
    required this.triggerWords,
    required this.triggerWhen,
    required this.callbackUrls,
    required this.displayName,
    required this.description,
    this.contentType = 'application/x-www-form-urlencoded',
    this.createAt,
    this.updateAt,
    this.deleteAt,
  });

  factory MOutgoingWebhook.fromJson(Map<String, dynamic> json) {
    return MOutgoingWebhook(
      id: json['id'] ?? '',
      token: json['token'] ?? '',
      creatorId: json['creator_id'] ?? '',
      channelId: json['channel_id'] ?? '',
      teamId: json['team_id'] ?? '',
      triggerWords: json['trigger_words'] ?? '',
      triggerWhen: json['trigger_when'] ?? '',
      callbackUrls: json['callback_urls'] ?? '',
      displayName: json['display_name'] ?? '',
      description: json['description'] ?? '',
      contentType: json['content_type'] ?? 'application/x-www-form-urlencoded',
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'creator_id': creatorId,
      'channel_id': channelId,
      'team_id': teamId,
      'trigger_words': triggerWords,
      'trigger_when': triggerWhen,
      'callback_urls': callbackUrls,
      'display_name': displayName,
      'description': description,
      'content_type': contentType,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
    };
  }
}
