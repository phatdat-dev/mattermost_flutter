/// Audit model
class MAudit {
  final String id;
  final int? createAt;
  final String userId;
  final String action;
  final String extraInfo;
  final String ipAddress;
  final String sessionId;

  MAudit({
    required this.id,
    this.createAt,
    required this.userId,
    required this.action,
    required this.extraInfo,
    required this.ipAddress,
    required this.sessionId,
  });

  factory MAudit.fromJson(Map<String, dynamic> json) {
    return MAudit(
      id: json['id'] ?? '',
      createAt: json['create_at'],
      userId: json['user_id'] ?? '',
      action: json['action'] ?? '',
      extraInfo: json['extra_info'] ?? '',
      ipAddress: json['ip_address'] ?? '',
      sessionId: json['session_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (createAt != null) 'create_at': createAt,
      'user_id': userId,
      'action': action,
      'extra_info': extraInfo,
      'ip_address': ipAddress,
      'session_id': sessionId,
    };
  }
}
