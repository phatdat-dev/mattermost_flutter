class MUserNotifyProps {
  /// Set to "true" to enable email notifications, "false" to disable. Defaults to "true".
  final String email;

  /// Set to "all" to receive push notifications for all activity,
  /// "mention" for mentions and direct messages only, and "none" to disable. Defaults to "mention".
  final String push;

  /// Set to "all" to receive desktop notifications for all activity,
  /// "mention" for mentions and direct messages only, and "none" to disable. Defaults to "all".
  final String desktop;

  /// Set to "true" to enable sound on desktop notifications, "false" to disable. Defaults to "true".
  final String desktopSound;

  /// A comma-separated list of words to count as mentions. Defaults to username and @username.
  final String mentionKeys;

  /// Set to "true" to enable channel-wide notifications (@channel, @all, etc.), "false" to disable. Defaults to "true".
  final String channel;

  /// Set to "true" to enable mentions for first name. Defaults to "true" if a first name is set, "false" otherwise.
  final String firstName;

  MUserNotifyProps({
    this.email = 'true',
    this.push = 'mention',
    this.desktop = 'all',
    this.desktopSound = 'true',
    this.mentionKeys = '',
    this.channel = 'true',
    this.firstName = 'true',
  });

  factory MUserNotifyProps.fromJson(Map<String, dynamic> json) {
    return MUserNotifyProps(
      email: json['email'] ?? 'true',
      push: json['push'] ?? 'mention',
      desktop: json['desktop'] ?? 'all',
      desktopSound: json['desktop_sound'] ?? 'true',
      mentionKeys: json['mention_keys'] ?? '',
      channel: json['channel'] ?? 'true',
      firstName: json['first_name'] ?? 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'push': push,
      'desktop': desktop,
      'desktop_sound': desktopSound,
      'mention_keys': mentionKeys,
      'channel': channel,
      'first_name': firstName,
    };
  }
}

class MChannelNotifyProps {
  /// Set to "true" to enable email notifications, "false" to disable, or "default" to use the global user notification setting.
  final String email;

  /// Set to "all" to receive push notifications for all activity,
  /// "mention" for mentions and direct messages only, "none" to disable,
  /// or "default" to use the global user notification setting.
  final String push;

  /// Set to "all" to receive desktop notifications for all activity,
  /// "mention" for mentions and direct messages only, "none" to disable,
  /// or "default" to use the global user notification setting.
  final String desktop;

  /// Set to "all" to mark the channel unread for any new message,
  /// "mention" to mark unread for new mentions only. Defaults to "all".
  final String markUnread;

  MChannelNotifyProps({
    this.email = 'default',
    this.push = 'default',
    this.desktop = 'default',
    this.markUnread = 'all',
  });

  factory MChannelNotifyProps.fromJson(Map<String, dynamic> json) {
    return MChannelNotifyProps(
      email: json['email'] ?? 'default',
      push: json['push'] ?? 'default',
      desktop: json['desktop'] ?? 'default',
      markUnread: json['mark_unread'] ?? 'all',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'push': push,
      'desktop': desktop,
      'mark_unread': markUnread,
    };
  }
}
