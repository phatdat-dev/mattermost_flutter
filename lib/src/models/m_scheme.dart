/// Scheme model
class MScheme {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final String scope;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;
  final String? defaultTeamAdminRole;
  final String? defaultTeamUserRole;
  final String? defaultChannelAdminRole;
  final String? defaultChannelUserRole;

  MScheme({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.scope,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.defaultTeamAdminRole,
    this.defaultTeamUserRole,
    this.defaultChannelAdminRole,
    this.defaultChannelUserRole,
  });

  factory MScheme.fromJson(Map<String, dynamic> json) {
    return MScheme(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      description: json['description'] ?? '',
      scope: json['scope'] ?? '',
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
      defaultTeamAdminRole: json['default_team_admin_role'],
      defaultTeamUserRole: json['default_team_user_role'],
      defaultChannelAdminRole: json['default_channel_admin_role'],
      defaultChannelUserRole: json['default_channel_user_role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'description': description,
      'scope': scope,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
      if (defaultTeamAdminRole != null) 'default_team_admin_role': defaultTeamAdminRole,
      if (defaultTeamUserRole != null) 'default_team_user_role': defaultTeamUserRole,
      if (defaultChannelAdminRole != null) 'default_channel_admin_role': defaultChannelAdminRole,
      if (defaultChannelUserRole != null) 'default_channel_user_role': defaultChannelUserRole,
    };
  }
}

/// Create scheme request
class MCreateSchemeRequest {
  final String name;
  final String displayName;
  final String description;
  final String scope;

  MCreateSchemeRequest({required this.name, required this.displayName, required this.description, required this.scope});

  Map<String, dynamic> toJson() {
    return {'name': name, 'display_name': displayName, 'description': description, 'scope': scope};
  }
}

/// Patch scheme request
class MPatchSchemeRequest {
  final String name;
  final String displayName;
  final String description;

  MPatchSchemeRequest({required this.name, required this.displayName, required this.description});

  Map<String, dynamic> toJson() {
    return {'name': name, 'display_name': displayName, 'description': description};
  }
}
