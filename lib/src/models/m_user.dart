import 'm_notify_props.dart';
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
  final MUserNotifyProps? notifyProps;
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
