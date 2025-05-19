/// Group model
class MGroup {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final String source;
  final String remoteId;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;
  final bool? hasSyncables;

  MGroup({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.source,
    required this.remoteId,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.hasSyncables,
  });

  factory MGroup.fromJson(Map<String, dynamic> json) {
    return MGroup(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      description: json['description'] ?? '',
      source: json['source'] ?? '',
      remoteId: json['remote_id'] ?? '',
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
      hasSyncables: json['has_syncables'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'description': description,
      'source': source,
      'remote_id': remoteId,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
      if (hasSyncables != null) 'has_syncables': hasSyncables,
    };
  }
}

/// Group member model
class MGroupMember {
  final String groupId;
  final String userId;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;

  MGroupMember({required this.groupId, required this.userId, this.createAt, this.updateAt, this.deleteAt});

  factory MGroupMember.fromJson(Map<String, dynamic> json) {
    return MGroupMember(
      groupId: json['group_id'] ?? '',
      userId: json['user_id'] ?? '',
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'user_id': userId,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
    };
  }
}

/// Group stats model
class MGroupStats {
  final String groupId;
  final int totalMemberCount;

  MGroupStats({required this.groupId, required this.totalMemberCount});

  factory MGroupStats.fromJson(Map<String, dynamic> json) {
    return MGroupStats(groupId: json['group_id'] ?? '', totalMemberCount: json['total_member_count'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'group_id': groupId, 'total_member_count': totalMemberCount};
  }
}

/// Group channel model
class MGroupChannel {
  final String groupId;
  final String channelId;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;

  MGroupChannel({required this.groupId, required this.channelId, this.createAt, this.updateAt, this.deleteAt});

  factory MGroupChannel.fromJson(Map<String, dynamic> json) {
    return MGroupChannel(
      groupId: json['group_id'] ?? '',
      channelId: json['channel_id'] ?? '',
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'channel_id': channelId,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
    };
  }
}

/// Group team model
class MGroupTeam {
  final String groupId;
  final String teamId;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;

  MGroupTeam({required this.groupId, required this.teamId, this.createAt, this.updateAt, this.deleteAt});

  factory MGroupTeam.fromJson(Map<String, dynamic> json) {
    return MGroupTeam(
      groupId: json['group_id'] ?? '',
      teamId: json['team_id'] ?? '',
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'team_id': teamId,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
    };
  }
}
