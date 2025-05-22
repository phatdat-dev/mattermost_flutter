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

/// Create incoming webhook request
class MCreateIncomingWebhookRequest {
  final String channelId;
  final String displayName;
  final String description;
  final String? username;
  final String? iconUrl;

  MCreateIncomingWebhookRequest({
    required this.channelId,
    required this.displayName,
    required this.description,
    this.username,
    this.iconUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'channel_id': channelId,
      'display_name': displayName,
      'description': description,
      if (username != null) 'username': username,
      if (iconUrl != null) 'icon_url': iconUrl,
    };
  }
}

/// Update incoming webhook request
class MUpdateIncomingWebhookRequest {
  final String hookId;
  final String channelId;
  final String displayName;
  final String description;
  final String? username;
  final String? iconUrl;

  MUpdateIncomingWebhookRequest({
    required this.hookId,
    required this.channelId,
    required this.displayName,
    required this.description,
    this.username,
    this.iconUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': hookId,
      'channel_id': channelId,
      'display_name': displayName,
      'description': description,
      if (username != null) 'username': username,
      if (iconUrl != null) 'icon_url': iconUrl,
    };
  }
}

/// Create outgoing webhook request
class MCreateOutgoingWebhookRequest {
  final String teamId;
  final String displayName;
  final String description;
  final String? channelId;
  final List<String>? triggerWords;
  final String? triggerWhen;
  final List<String>? callbackUrls;
  final String? contentType;

  MCreateOutgoingWebhookRequest({
    required this.teamId,
    required this.displayName,
    required this.description,
    this.channelId,
    this.triggerWords,
    this.triggerWhen,
    this.callbackUrls,
    this.contentType,
  });

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'display_name': displayName,
      'description': description,
      if (channelId != null) 'channel_id': channelId,
      if (triggerWords != null) 'trigger_words': triggerWords,
      if (triggerWhen != null) 'trigger_when': triggerWhen,
      if (callbackUrls != null) 'callback_urls': callbackUrls,
      if (contentType != null) 'content_type': contentType,
    };
  }
}

/// Update outgoing webhook request
class MUpdateOutgoingWebhookRequest {
  final String hookId;
  final String displayName;
  final String description;
  final String? channelId;
  final List<String>? triggerWords;
  final String? triggerWhen;
  final List<String>? callbackUrls;
  final String? contentType;

  MUpdateOutgoingWebhookRequest({
    required this.hookId,
    required this.displayName,
    required this.description,
    this.channelId,
    this.triggerWords,
    this.triggerWhen,
    this.callbackUrls,
    this.contentType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': hookId,
      'display_name': displayName,
      'description': description,
      if (channelId != null) 'channel_id': channelId,
      if (triggerWords != null) 'trigger_words': triggerWords,
      if (triggerWhen != null) 'trigger_when': triggerWhen,
      if (callbackUrls != null) 'callback_urls': callbackUrls,
      if (contentType != null) 'content_type': contentType,
    };
  }
}
