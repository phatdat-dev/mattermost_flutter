/// Plugin manifest model
class PluginManifest {
  final String id;
  final String name;
  final String description;
  final String version;
  final int? minServerVersion;
  final Map<String, dynamic>? server;
  final Map<String, dynamic>? webapp;
  final Map<String, dynamic>? settings;

  PluginManifest({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    this.minServerVersion,
    this.server,
    this.webapp,
    this.settings,
  });

  factory PluginManifest.fromJson(Map<String, dynamic> json) {
    return PluginManifest(
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
class PluginManifests {
  final List<PluginManifest> active;
  final List<PluginManifest> inactive;

  PluginManifests({
    required this.active,
    required this.inactive,
  });

  factory PluginManifests.fromJson(Map<String, dynamic> json) {
    return PluginManifests(
      active: (json['active'] as List<dynamic>? ?? [])
          .map((manifest) => PluginManifest.fromJson(manifest))
          .toList(),
      inactive: (json['inactive'] as List<dynamic>? ?? [])
          .map((manifest) => PluginManifest.fromJson(manifest))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active': active.map((manifest) => manifest.toJson()).toList(),
      'inactive': inactive.map((manifest) => manifest.toJson()).toList(),
    };
  }
}

/// Plugin status model
class PluginStatus {
  final String pluginId;
  final String name;
  final String description;
  final String version;
  final bool isActive;
  final String state;

  PluginStatus({
    required this.pluginId,
    required this.name,
    required this.description,
    required this.version,
    required this.isActive,
    required this.state,
  });

  factory PluginStatus.fromJson(Map<String, dynamic> json) {
    return PluginStatus(
      pluginId: json['plugin_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      version: json['version'] ?? '',
      isActive: json['is_active'] ?? false,
      state: json['state'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plugin_id': pluginId,
      'name': name,
      'description': description,
      'version': version,
      'is_active': isActive,
      'state': state,
    };
  }
}
