/// Team model
class Team {
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

  Team({
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

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
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
class TeamMember {
  final String teamId;
  final String userId;
  final String roles;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;
  final String? schemeUser;
  final String? schemeAdmin;
  final String? explicitRoles;

  TeamMember({
    required this.teamId,
    required this.userId,
    required this.roles,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.schemeUser,
    this.schemeAdmin,
    this.explicitRoles,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      teamId: json['team_id'] ?? '',
      userId: json['user_id'] ?? '',
      roles: json['roles'] ?? '',
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
      schemeUser: json['scheme_user'],
      schemeAdmin: json['scheme_admin'],
      explicitRoles: json['explicit_roles'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'user_id': userId,
      'roles': roles,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
      if (schemeUser != null) 'scheme_user': schemeUser,
      if (schemeAdmin != null) 'scheme_admin': schemeAdmin,
      if (explicitRoles != null) 'explicit_roles': explicitRoles,
    };
  }
}

/// Team stats model
class TeamStats {
  final String teamId;
  final int totalMemberCount;
  final int activeMemberCount;

  TeamStats({
    required this.teamId,
    required this.totalMemberCount,
    required this.activeMemberCount,
  });

  factory TeamStats.fromJson(Map<String, dynamic> json) {
    return TeamStats(
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

/// Create team request
class CreateTeamRequest {
  final String name;
  final String displayName;
  final String type;
  final String? description;
  final String? companyName;
  final String? allowedDomains;
  final bool? allowOpenInvite;

  CreateTeamRequest({
    required this.name,
    required this.displayName,
    required this.type,
    this.description,
    this.companyName,
    this.allowedDomains,
    this.allowOpenInvite,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'display_name': displayName,
      'type': type,
      if (description != null) 'description': description,
      if (companyName != null) 'company_name': companyName,
      if (allowedDomains != null) 'allowed_domains': allowedDomains,
      if (allowOpenInvite != null) 'allow_open_invite': allowOpenInvite,
    };
  }
}

/// Update team request
class UpdateTeamRequest {
  final String? name;
  final String? displayName;
  final String? description;
  final String? companyName;
  final String? allowedDomains;
  final bool? allowOpenInvite;

  UpdateTeamRequest({
    this.name,
    this.displayName,
    this.description,
    this.companyName,
    this.allowedDomains,
    this.allowOpenInvite,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (displayName != null) 'display_name': displayName,
      if (description != null) 'description': description,
      if (companyName != null) 'company_name': companyName,
      if (allowedDomains != null) 'allowed_domains': allowedDomains,
      if (allowOpenInvite != null) 'allow_open_invite': allowOpenInvite,
    };
  }
}

/// Add team member request
class AddTeamMemberRequest {
  final String teamId;
  final String userId;
  final String? roles;

  AddTeamMemberRequest({
    required this.teamId,
    required this.userId,
    this.roles,
  });

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'user_id': userId,
      if (roles != null) 'roles': roles,
    };
  }
}

/// Team search request
class TeamSearchRequest {
  final String? term;
  final bool? allowOpenInvite;
  final int? page;
  final int? perPage;
  final bool? excludePolicyConstrained;

  TeamSearchRequest({
    this.term,
    this.allowOpenInvite,
    this.page,
    this.perPage,
    this.excludePolicyConstrained,
  });

  Map<String, dynamic> toJson() {
    return {
      if (term != null) 'term': term,
      if (allowOpenInvite != null) 'allow_open_invite': allowOpenInvite,
      if (page != null) 'page': page,
      if (perPage != null) 'per_page': perPage,
      if (excludePolicyConstrained != null)
        'exclude_policy_constrained': excludePolicyConstrained,
    };
  }
}
