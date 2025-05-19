/// Plugin manifest model
class MPluginManifest {
  final String id;
  final String name;
  final String description;
  final String version;
  final int? minServerVersion;
  final Map<String, dynamic>? server;
  final Map<String, dynamic>? webapp;
  final Map<String, dynamic>? settings;

  MPluginManifest({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    this.minServerVersion,
    this.server,
    this.webapp,
    this.settings,
  });

  factory MPluginManifest.fromJson(Map<String, dynamic> json) {
    return MPluginManifest(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      version: json['version'] ?? '',
      minServerVersion: json['min_server_version'],
      server: json['server'],
      webapp: json['webapp'],
      settings: json['settings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'version': version,
      if (minServerVersion != null) 'min_server_version': minServerVersion,
      if (server != null) 'server': server,
      if (webapp != null) 'webapp': webapp,
      if (settings != null) 'settings': settings,
    };
  }
}

/// Plugin manifests model
class MPluginManifests {
  final List<MPluginManifest> active;
  final List<MPluginManifest> inactive;

  MPluginManifests({required this.active, required this.inactive});

  factory MPluginManifests.fromJson(Map<String, dynamic> json) {
    return MPluginManifests(
      active: (json['active'] as List<dynamic>? ?? []).map((manifest) => MPluginManifest.fromJson(manifest)).toList(),
      inactive: (json['inactive'] as List<dynamic>? ?? []).map((manifest) => MPluginManifest.fromJson(manifest)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'active': active.map((manifest) => manifest.toJson()).toList(), 'inactive': inactive.map((manifest) => manifest.toJson()).toList()};
  }
}

/// Plugin status model
class MPluginStatus {
  final String pluginId;
  final String name;
  final String description;
  final String version;
  final bool isActive;
  final String state;

  MPluginStatus({
    required this.pluginId,
    required this.name,
    required this.description,
    required this.version,
    required this.isActive,
    required this.state,
  });

  factory MPluginStatus.fromJson(Map<String, dynamic> json) {
    return MPluginStatus(
      pluginId: json['plugin_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      version: json['version'] ?? '',
      isActive: json['is_active'] ?? false,
      state: json['state'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'plugin_id': pluginId, 'name': name, 'description': description, 'version': version, 'is_active': isActive, 'state': state};
  }
}
