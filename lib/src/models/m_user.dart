import 'm_time_zone.dart';

/// User model
class MUser {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String nickname;
  final String position;
  final Map<String, dynamic>? props;
  final Map<String, dynamic>? notifyProps;
  final int? lastPasswordUpdate;
  final int? lastPictureUpdate;
  final int? failedAttempts;
  final String? locale;
  final MTimeZone? timezone;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;
  final bool? isBot;
  final String? botDescription;
  final String? botOwnerId;

  MUser({
    required this.id,
    required this.username,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.nickname = '',
    this.position = '',
    this.props,
    this.notifyProps,
    this.lastPasswordUpdate,
    this.lastPictureUpdate,
    this.failedAttempts,
    this.locale,
    this.timezone,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.isBot,
    this.botDescription,
    this.botOwnerId,
  });

  factory MUser.fromJson(Map<String, dynamic> json) {
    return MUser(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      nickname: json['nickname'] ?? '',
      position: json['position'] ?? '',
      props: json['props'],
      notifyProps: json['notify_props'],
      lastPasswordUpdate: json['last_password_update'],
      lastPictureUpdate: json['last_picture_update'],
      failedAttempts: json['failed_attempts'],
      locale: json['locale'],
      timezone: json['timezone'] != null ? MTimeZone.fromJson(json['timezone']) : null,
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
      isBot: json['is_bot'],
      botDescription: json['bot_description'],
      botOwnerId: json['bot_owner_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'nickname': nickname,
      'position': position,
      if (props != null) 'props': props,
      if (notifyProps != null) 'notify_props': notifyProps,
      if (lastPasswordUpdate != null) 'last_password_update': lastPasswordUpdate,
      if (lastPictureUpdate != null) 'last_picture_update': lastPictureUpdate,
      if (failedAttempts != null) 'failed_attempts': failedAttempts,
      if (locale != null) 'locale': locale,
      if (timezone != null) 'timezone': timezone?.toJson(),
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
      if (isBot != null) 'is_bot': isBot,
      if (botDescription != null) 'bot_description': botDescription,
      if (botOwnerId != null) 'bot_owner_id': botOwnerId,
    };
  }
}

/// Create user request
class MCreateUserRequest {
  final String email;
  final String username;
  final String password;
  final String? firstName;
  final String? lastName;
  final String? nickname;
  final String? position;
  final Map<String, dynamic>? props;
  final Map<String, dynamic>? notifyProps;
  final String? locale;
  final MTimeZone? timezone;

  MCreateUserRequest({
    required this.email,
    required this.username,
    required this.password,
    this.firstName,
    this.lastName,
    this.nickname,
    this.position,
    this.props,
    this.notifyProps,
    this.locale,
    this.timezone,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'password': password,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (nickname != null) 'nickname': nickname,
      if (position != null) 'position': position,
      if (props != null) 'props': props,
      if (notifyProps != null) 'notify_props': notifyProps,
      if (locale != null) 'locale': locale,
      if (timezone != null) 'timezone': timezone?.toJson(),
    };
  }
}

/// Update user request
class MUpdateUserRequest {
  final String? email;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? nickname;
  final String? position;
  final Map<String, dynamic>? props;
  final Map<String, dynamic>? notifyProps;
  final String? locale;
  final MTimeZone? timezone;

  MUpdateUserRequest({
    this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.nickname,
    this.position,
    this.props,
    this.notifyProps,
    this.locale,
    this.timezone,
  });

  Map<String, dynamic> toJson() {
    return {
      if (email != null) 'email': email,
      if (username != null) 'username': username,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (nickname != null) 'nickname': nickname,
      if (position != null) 'position': position,
      if (props != null) 'props': props,
      if (notifyProps != null) 'notify_props': notifyProps,
      if (locale != null) 'locale': locale,
      if (timezone != null) 'timezone': timezone?.toJson(),
    };
  }
}

/// User search request
class MUserSearchRequest {
  final String? term;
  final String? teamId;
  final String? notInTeamId;
  final String? inChannelId;
  final String? notInChannelId;
  final String? groupConstrained;
  final bool? allowInactive;
  final bool? withoutTeam;
  final int? limit;

  MUserSearchRequest({
    this.term,
    this.teamId,
    this.notInTeamId,
    this.inChannelId,
    this.notInChannelId,
    this.groupConstrained,
    this.allowInactive,
    this.withoutTeam,
    this.limit,
  });

  Map<String, dynamic> toJson() {
    return {
      if (term != null) 'term': term,
      if (teamId != null) 'team_id': teamId,
      if (notInTeamId != null) 'not_in_team_id': notInTeamId,
      if (inChannelId != null) 'in_channel_id': inChannelId,
      if (notInChannelId != null) 'not_in_channel_id': notInChannelId,
      if (groupConstrained != null) 'group_constrained': groupConstrained,
      if (allowInactive != null) 'allow_inactive': allowInactive,
      if (withoutTeam != null) 'without_team': withoutTeam,
      if (limit != null) 'limit': limit,
    };
  }
}
