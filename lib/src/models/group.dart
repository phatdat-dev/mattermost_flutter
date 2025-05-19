/// Group model
class Group {
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

  Group({
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

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
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
class GroupMember {
  final String groupId;
  final String userId;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;

  GroupMember({
    required this.groupId,
    required this.userId,
    this.createAt,
    this.updateAt,
    this.deleteAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
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
class GroupStats {
  final String groupId;
  final int totalMemberCount;

  GroupStats({
    required this.groupId,
    required this.totalMemberCount,
  });

  factory GroupStats.fromJson(Map<String, dynamic> json) {
    return GroupStats(
      groupId: json['group_id'] ?? '',
      totalMemberCount: json['total_member_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'total_member_count': totalMemberCount,
    };
  }
}

/// Group channel model
class GroupChannel {
  final String groupId;
  final String channelId;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;

  GroupChannel({
    required this.groupId,
    required this.channelId,
    this.createAt,
    this.updateAt,
    this.deleteAt,
  });

  factory GroupChannel.fromJson(Map<String, dynamic> json) {
    return GroupChannel(
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
class GroupTeam {
  final String groupId;
  final String teamId;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;

  GroupTeam({
    required this.groupId,
    required this.teamId,
    this.createAt,
    this.updateAt,
    this.deleteAt,
  });

  factory GroupTeam.fromJson(Map<String, dynamic> json) {
    return GroupTeam(
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
