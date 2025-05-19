/// Session model
class Session {
  final String id;
  final String token;
  final String userId;
  final String deviceId;
  final int? expiresAt;
  final int? createAt;
  final int? lastActivityAt;
  final String? roles;
  final bool? isOAuth;
  final Map<String, dynamic>? props;

  Session({
    required this.id,
    required this.token,
    required this.userId,
    required this.deviceId,
    this.expiresAt,
    this.createAt,
    this.lastActivityAt,
    this.roles,
    this.isOAuth,
    this.props,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] ?? '',
      token: json['token'] ?? '',
      userId: json['user_id'] ?? '',
      deviceId: json['device_id'] ?? '',
      expiresAt: json['expires_at'],
      createAt: json['create_at'],
      lastActivityAt: json['last_activity_at'],
      roles: json['roles'],
      isOAuth: json['is_oauth'],
      props: json['props'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'user_id': userId,
      'device_id': deviceId,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (createAt != null) 'create_at': createAt,
      if (lastActivityAt != null) 'last_activity_at': lastActivityAt,
      if (roles != null) 'roles': roles,
      if (isOAuth != null) 'is_oauth': isOAuth,
      if (props != null) 'props': props,
    };
  }
}
