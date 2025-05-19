/// User status model
class UserStatus {
  final String userId;
  final String status;
  final bool manual;
  final int? lastActivityAt;

  UserStatus({
    required this.userId,
    required this.status,
    required this.manual,
    this.lastActivityAt,
  });

  factory UserStatus.fromJson(Map<String, dynamic> json) {
    return UserStatus(
      userId: json['user_id'] ?? '',
      status: json['status'] ?? '',
      manual: json['manual'] ?? false,
      lastActivityAt: json['last_activity_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'status': status,
      'manual': manual,
      if (lastActivityAt != null) 'last_activity_at': lastActivityAt,
    };
  }
}

/// Update user status request
class UpdateUserStatusRequest {
  final String userId;
  final String status;

  UpdateUserStatusRequest({
    required this.userId,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'status': status,
    };
  }
}
