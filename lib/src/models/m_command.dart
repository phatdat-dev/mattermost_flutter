/// Command model
class MCommand {
  final String id;
  final String token;
  final String creatorId;
  final String teamId;
  final String trigger;
  final String method;
  final String username;
  final String iconUrl;
  final bool autoComplete;
  final String autoCompleteDesc;
  final String autoCompleteHint;
  final String displayName;
  final String description;
  final String url;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;

  MCommand({
    required this.id,
    required this.token,
    required this.creatorId,
    required this.teamId,
    required this.trigger,
    required this.method,
    required this.username,
    required this.iconUrl,
    required this.autoComplete,
    required this.autoCompleteDesc,
    required this.autoCompleteHint,
    required this.displayName,
    required this.description,
    required this.url,
    this.createAt,
    this.updateAt,
    this.deleteAt,
  });

  factory MCommand.fromJson(Map<String, dynamic> json) {
    return MCommand(
      id: json['id'] ?? '',
      token: json['token'] ?? '',
      creatorId: json['creator_id'] ?? '',
      teamId: json['team_id'] ?? '',
      trigger: json['trigger'] ?? '',
      method: json['method'] ?? '',
      username: json['username'] ?? '',
      iconUrl: json['icon_url'] ?? '',
      autoComplete: json['auto_complete'] ?? false,
      autoCompleteDesc: json['auto_complete_desc'] ?? '',
      autoCompleteHint: json['auto_complete_hint'] ?? '',
      displayName: json['display_name'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
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
      'team_id': teamId,
      'trigger': trigger,
      'method': method,
      'username': username,
      'icon_url': iconUrl,
      'auto_complete': autoComplete,
      'auto_complete_desc': autoCompleteDesc,
      'auto_complete_hint': autoCompleteHint,
      'display_name': displayName,
      'description': description,
      'url': url,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
    };
  }
}

/// Command response model
class MCommandResponse {
  final String responseType;
  final String text;
  final String username;
  final String iconUrl;
  final List<dynamic>? attachments;
  final Map<String, dynamic>? props;
  final bool? skipSlackParsing;

  MCommandResponse({
    required this.responseType,
    required this.text,
    required this.username,
    required this.iconUrl,
    this.attachments,
    this.props,
    this.skipSlackParsing,
  });

  factory MCommandResponse.fromJson(Map<String, dynamic> json) {
    return MCommandResponse(
      responseType: json['response_type'] ?? '',
      text: json['text'] ?? '',
      username: json['username'] ?? '',
      iconUrl: json['icon_url'] ?? '',
      attachments: json['attachments'],
      props: json['props'],
      skipSlackParsing: json['skip_slack_parsing'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_type': responseType,
      'text': text,
      'username': username,
      'icon_url': iconUrl,
      if (attachments != null) 'attachments': attachments,
      if (props != null) 'props': props,
      if (skipSlackParsing != null) 'skip_slack_parsing': skipSlackParsing,
    };
  }
}

/// Create command request
class MCreateCommandRequest {
  final String teamId;
  final String trigger;
  final String method;
  final String url;
  final String? username;
  final String? iconUrl;
  final bool? autoComplete;
  final String? autoCompleteDesc;
  final String? autoCompleteHint;
  final String? displayName;
  final String? description;

  MCreateCommandRequest({
    required this.teamId,
    required this.trigger,
    required this.method,
    required this.url,
    this.username,
    this.iconUrl,
    this.autoComplete,
    this.autoCompleteDesc,
    this.autoCompleteHint,
    this.displayName,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'trigger': trigger,
      'method': method,
      'url': url,
      if (username != null) 'username': username,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (autoComplete != null) 'auto_complete': autoComplete,
      if (autoCompleteDesc != null) 'auto_complete_desc': autoCompleteDesc,
      if (autoCompleteHint != null) 'auto_complete_hint': autoCompleteHint,
      if (displayName != null) 'display_name': displayName,
      if (description != null) 'description': description,
    };
  }
}

/// Update command request
class MUpdateCommandRequest {
  final String id;
  final String? trigger;
  final String? method;
  final String? url;
  final String? username;
  final String? iconUrl;
  final bool? autoComplete;
  final String? autoCompleteDesc;
  final String? autoCompleteHint;
  final String? displayName;
  final String? description;

  MUpdateCommandRequest({
    required this.id,
    this.trigger,
    this.method,
    this.url,
    this.username,
    this.iconUrl,
    this.autoComplete,
    this.autoCompleteDesc,
    this.autoCompleteHint,
    this.displayName,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (trigger != null) 'trigger': trigger,
      if (method != null) 'method': method,
      if (url != null) 'url': url,
      if (username != null) 'username': username,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (autoComplete != null) 'auto_complete': autoComplete,
      if (autoCompleteDesc != null) 'auto_complete_desc': autoCompleteDesc,
      if (autoCompleteHint != null) 'auto_complete_hint': autoCompleteHint,
      if (displayName != null) 'display_name': displayName,
      if (description != null) 'description': description,
    };
  }
}

/// Execute command request
class MExecuteCommandRequest {
  final String channelId;
  final String command;

  MExecuteCommandRequest({required this.channelId, required this.command});

  Map<String, dynamic> toJson() {
    return {'channel_id': channelId, 'command': command};
  }
}
