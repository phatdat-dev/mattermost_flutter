/// User status model
class MUserStatus {
  final String userId;
  final String status;
  final bool manual;
  final int? lastActivityAt;

  MUserStatus({
    required this.userId,
    required this.status,
    required this.manual,
    this.lastActivityAt,
  });

  factory MUserStatus.fromJson(Map<String, dynamic> json) {
    return MUserStatus(
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
class MUpdateUserStatusRequest {
  final String userId;
  final String status;

  MUpdateUserStatusRequest({required this.userId, required this.status});

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'status': status};
  }
}

/// System status model
class MSystemStatus {
  final String androidLatestVersion;
  final String androidMinVersion;
  final String desktopLatestVersion;
  final String desktopMinVersion;
  final String iosLatestVersion;
  final String iosMinVersion;
  final String databaseStatus;
  final String fileStorageStatus;
  final String status;

  MSystemStatus({
    required this.androidLatestVersion,
    required this.androidMinVersion,
    required this.desktopLatestVersion,
    required this.desktopMinVersion,
    required this.iosLatestVersion,
    required this.iosMinVersion,
    required this.databaseStatus,
    required this.fileStorageStatus,
    required this.status,
  });

  factory MSystemStatus.fromJson(Map<String, dynamic> json) {
    return MSystemStatus(
      androidLatestVersion: json['android_latest_version'] ?? '',
      androidMinVersion: json['android_min_version'] ?? '',
      desktopLatestVersion: json['desktop_latest_version'] ?? '',
      desktopMinVersion: json['desktop_min_version'] ?? '',
      iosLatestVersion: json['ios_latest_version'] ?? '',
      iosMinVersion: json['ios_min_version'] ?? '',
      databaseStatus: json['database_status'] ?? '',
      fileStorageStatus: json['file_storage_status'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'android_latest_version': androidLatestVersion,
      'android_min_version': androidMinVersion,
      'desktop_latest_version': desktopLatestVersion,
      'desktop_min_version': desktopMinVersion,
      'ios_latest_version': iosLatestVersion,
      'ios_min_version': iosMinVersion,
      'database_status': databaseStatus,
      'file_storage_status': fileStorageStatus,
      'status': status,
    };
  }
}
