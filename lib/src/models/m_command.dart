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
  final String? username;
  final String? iconUrl;
  final String? gotoLocation;
  final List<MCommandAttachment>? attachments;

  MCommandResponse({
    required this.responseType,
    required this.text,
    this.username,
    this.iconUrl,
    this.gotoLocation,
    this.attachments,
  });

  factory MCommandResponse.fromJson(Map<String, dynamic> json) {
    return MCommandResponse(
      responseType: json['response_type'] ?? '',
      text: json['text'] ?? '',
      username: json['username'],
      iconUrl: json['icon_url'],
      gotoLocation: json['goto_location'],
      attachments: (json['attachments'] as List?)?.map((item) => MCommandAttachment.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_type': responseType,
      'text': text,
      if (username != null) 'username': username,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (gotoLocation != null) 'goto_location': gotoLocation,
      if (attachments != null) 'attachments': attachments!.map((a) => a.toJson()).toList(),
    };
  }
}

/// Command attachment model
class MCommandAttachment {
  final String id;
  final String fallback;
  final String? color;
  final String? pretext;
  final String? authorName;
  final String? authorLink;
  final String? authorIcon;
  final String? title;
  final String? titleLink;
  final String? text;
  final List<MCommandAttachmentField>? fields;
  final String? imageUrl;
  final String? thumbUrl;
  final String? footer;
  final String? footerIcon;
  final dynamic timestamp; // Can be string or integer

  MCommandAttachment({
    required this.id,
    required this.fallback,
    this.color,
    this.pretext,
    this.authorName,
    this.authorLink,
    this.authorIcon,
    this.title,
    this.titleLink,
    this.text,
    this.fields,
    this.imageUrl,
    this.thumbUrl,
    this.footer,
    this.footerIcon,
    this.timestamp,
  });

  factory MCommandAttachment.fromJson(Map<String, dynamic> json) {
    return MCommandAttachment(
      id: json['id'] ?? '',
      fallback: json['fallback'] ?? '',
      color: json['color'],
      pretext: json['pretext'],
      authorName: json['author_name'],
      authorLink: json['author_link'],
      authorIcon: json['author_icon'],
      title: json['title'],
      titleLink: json['title_link'],
      text: json['text'],
      fields: (json['fields'] as List?)?.map((item) => MCommandAttachmentField.fromJson(item)).toList(),
      imageUrl: json['image_url'],
      thumbUrl: json['thumb_url'],
      footer: json['footer'],
      footerIcon: json['footer_icon'],
      timestamp: json['timestamp'], // Can be string or integer
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fallback': fallback,
      if (color != null) 'color': color,
      if (pretext != null) 'pretext': pretext,
      if (authorName != null) 'author_name': authorName,
      if (authorLink != null) 'author_link': authorLink,
      if (authorIcon != null) 'author_icon': authorIcon,
      if (title != null) 'title': title,
      if (title != null) 'title_link': titleLink,
      if (text != null) 'text': text,
      if (fields != null) 'fields': fields!.map((f) => f.toJson()).toList(),
      if (imageUrl != null) 'image_url': imageUrl,
      if (thumbUrl != null) 'thumb_url': thumbUrl,
      if (footer != null) 'footer': footer,
      if (footerIcon != null) 'footer_icon': footerIcon,
      if (timestamp != null) 'timestamp': timestamp,
    };
  }
}

/// Command attachment field model
class MCommandAttachmentField {
  final String title;
  final String value;
  final bool short;

  MCommandAttachmentField({
    required this.title,
    required this.value,
    required this.short,
  });

  factory MCommandAttachmentField.fromJson(Map<String, dynamic> json) {
    return MCommandAttachmentField(
      title: json['title'] ?? '',
      value: json['value'] ?? '',
      short: json['short'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'value': value,
      'short': short,
    };
  }
}
