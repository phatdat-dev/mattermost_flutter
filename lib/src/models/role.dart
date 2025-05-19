/// Role model
class Role {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final List<String> permissions;
  final String schemeManaged;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;
  final bool? builtIn;

  Role({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.permissions,
    required this.schemeManaged,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.builtIn,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
      description: json['description'] ?? '',
      permissions: (json['permissions'] as List<dynamic>? ?? []).cast<String>(),
      schemeManaged: json['scheme_managed'] ?? '',
      createAt: json['create_at'],
      updateAt: json['update_at'],
      deleteAt: json['delete_at'],
      builtIn: json['built_in'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'description': description,
      'permissions': permissions,
      'scheme_managed': schemeManaged,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
      if (deleteAt != null) 'delete_at': deleteAt,
      if (builtIn != null) 'built_in': builtIn,
    };
  }
}

/// Patch role request
class PatchRoleRequest {
  final List<String>? permissions;

  PatchRoleRequest({
    this.permissions,
  });

  Map<String, dynamic> toJson() {
    return {
      if (permissions != null) 'permissions': permissions,
    };
  }
}
