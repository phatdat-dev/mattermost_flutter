/// Team model
class MTeam {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final String email;
  final String type;
  final String companyName;
  final String allowedDomains;
  final String inviteId;
  final bool allowOpenInvite;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;
  final String? schemeId;
  final String? policyId;

  MTeam({
    required this.id,
    required this.name,
    required this.displayName,
    this.description = '',
    this.email = '',
    required this.type,
    this.companyName = '',
    this.allowedDomains = '',
    required this.inviteId,
    this.allowOpenInvite = false,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.schemeId,
    this.policyId,
  });

  factory MTeam.fromJson(Map<String, dynamic> json) {
    return MTeam(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      description: json['description'] ?? '',
      email: json['email'] ?? '',
      type: json['type'] ?? '',
      companyName: json['company_name'] ?? '',
      allowedDomains: json['allowed_domains'] ?? '',
      inviteId: json['invite_id'] ?? '',
      allowOpenInvite: json['allow_open_invite'] ?? false,
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
      schemeId: json['scheme_id'],
      policyId: json['policy_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'description': description,
      'email': email,
      'type': type,
      'company_name': companyName,
      'allowed_domains': allowedDomains,
      'invite_id': inviteId,
      'allow_open_invite': allowOpenInvite,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
      if (schemeId != null) 'scheme_id': schemeId,
      if (policyId != null) 'policy_id': policyId,
    };
  }
}

/// Team member model
class MTeamMember {
  /// The ID of the team this member belongs to.
  final String teamId;

  /// The ID of the user this member relates to.
  final String userId;

  /// The complete list of roles assigned to this team member, as a space-separated list of role names,
  /// including any roles granted implicitly through permissions schemes.
  final String roles;

  /// The time in milliseconds that this team member was deleted.
  final int? deleteAt;

  /// Whether this team member holds the default user role defined by the team's permissions scheme.
  final bool schemeUser;

  /// Whether this team member holds the default admin role defined by the team's permissions scheme.
  final bool schemeAdmin;

  /// The list of roles explicitly assigned to this team member, as a space separated list of role names.
  /// This list does *not* include any roles granted implicitly through permissions schemes.
  final String explicitRoles;

  MTeamMember({
    required this.teamId,
    required this.userId,
    required this.roles,
    this.deleteAt,
    this.schemeUser = false,
    this.schemeAdmin = false,
    this.explicitRoles = '',
  });

  factory MTeamMember.fromJson(Map<String, dynamic> json) {
    return MTeamMember(
      teamId: json['team_id'] ?? '',
      userId: json['user_id'] ?? '',
      roles: json['roles'] ?? '',
      deleteAt: json['delete_at'],
      schemeUser: json['scheme_user'] ?? false,
      schemeAdmin: json['scheme_admin'] ?? false,
      explicitRoles: json['explicit_roles'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'user_id': userId,
      'roles': roles,
      if (deleteAt != null) 'delete_at': deleteAt,
      'scheme_user': schemeUser,
      'scheme_admin': schemeAdmin,
      'explicit_roles': explicitRoles,
    };
  }
}

/// Team stats model
class MTeamStats {
  final String teamId;
  final int totalMemberCount;
  final int activeMemberCount;

  MTeamStats({
    required this.teamId,
    required this.totalMemberCount,
    required this.activeMemberCount,
  });

  factory MTeamStats.fromJson(Map<String, dynamic> json) {
    return MTeamStats(
      teamId: json['team_id'] ?? '',
      totalMemberCount: json['total_member_count'] ?? 0,
      activeMemberCount: json['active_member_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'total_member_count': totalMemberCount,
      'active_member_count': activeMemberCount,
    };
  }
}

/// Team unread model for tracking unread messages in a team
class MTeamUnread {
  final String teamId;
  final int msgCount;
  final int mentionCount;
  final bool hasUrgent;

  MTeamUnread({
    required this.teamId,
    required this.msgCount,
    required this.mentionCount,
    required this.hasUrgent,
  });

  factory MTeamUnread.fromJson(Map<String, dynamic> json) {
    return MTeamUnread(
      teamId: json['team_id'] ?? '',
      msgCount: json['msg_count'] ?? 0,
      mentionCount: json['mention_count'] ?? 0,
      hasUrgent: json['has_urgent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'msg_count': msgCount,
      'mention_count': mentionCount,
      'has_urgent': hasUrgent,
    };
  }
}
