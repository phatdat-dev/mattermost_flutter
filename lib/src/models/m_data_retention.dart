/// Data retention policy model
class MDataRetentionPolicy {
  final String? messageRetentionDays;
  final String? fileRetentionDays;
  final String? boardsRetentionDays;

  MDataRetentionPolicy({this.messageRetentionDays, this.fileRetentionDays, this.boardsRetentionDays});

  factory MDataRetentionPolicy.fromJson(Map<String, dynamic> json) {
    return MDataRetentionPolicy(
      messageRetentionDays: json['message_retention_days'],
      fileRetentionDays: json['file_retention_days'],
      boardsRetentionDays: json['boards_retention_days'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (messageRetentionDays != null) 'message_retention_days': messageRetentionDays,
      if (fileRetentionDays != null) 'file_retention_days': fileRetentionDays,
      if (boardsRetentionDays != null) 'boards_retention_days': boardsRetentionDays,
    };
  }
}

/// Team data retention policy model
class MTeamDataRetentionPolicy {
  final String id;
  final String teamId;
  final int postDuration;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;

  MTeamDataRetentionPolicy({required this.id, required this.teamId, required this.postDuration, this.createAt, this.updateAt, this.deleteAt});

  factory MTeamDataRetentionPolicy.fromJson(Map<String, dynamic> json) {
    return MTeamDataRetentionPolicy(
      id: json['id'] ?? '',
      teamId: json['team_id'] ?? '',
      postDuration: json['post_duration'] ?? 0,
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_id': teamId,
      'post_duration': postDuration,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
    };
  }
}

/// Channel data retention policy model
class MChannelDataRetentionPolicy {
  final String id;
  final String channelId;
  final int postDuration;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;

  MChannelDataRetentionPolicy({required this.id, required this.channelId, required this.postDuration, this.createAt, this.updateAt, this.deleteAt});

  factory MChannelDataRetentionPolicy.fromJson(Map<String, dynamic> json) {
    return MChannelDataRetentionPolicy(
      id: json['id'] ?? '',
      channelId: json['channel_id'] ?? '',
      postDuration: json['post_duration'] ?? 0,
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel_id': channelId,
      'post_duration': postDuration,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
    };
  }
}

/// Create team policy request
class MCreateTeamPolicyRequest {
  final String teamId;
  final int postDuration;

  MCreateTeamPolicyRequest({required this.teamId, required this.postDuration});

  Map<String, dynamic> toJson() {
    return {'team_id': teamId, 'post_duration': postDuration};
  }
}

/// Create channel policy request
class MCreateChannelPolicyRequest {
  final String channelId;
  final int postDuration;

  MCreateChannelPolicyRequest({required this.channelId, required this.postDuration});

  Map<String, dynamic> toJson() {
    return {'channel_id': channelId, 'post_duration': postDuration};
  }
}

/// Update team policy request
class MUpdateTeamPolicyRequest {
  final int postDuration;

  MUpdateTeamPolicyRequest({required this.postDuration});

  Map<String, dynamic> toJson() {
    return {'post_duration': postDuration};
  }
}

/// Update channel policy request
class MUpdateChannelPolicyRequest {
  final int postDuration;

  MUpdateChannelPolicyRequest({required this.postDuration});

  Map<String, dynamic> toJson() {
    return {'post_duration': postDuration};
  }
}
