/// Model for Plugin Manifest
class MPluginManifest {
  /// Globally unique identifier that represents the plugin.
  final String id;

  /// Name of the plugin.
  final String name;

  /// Description of what the plugin is and does.
  final String description;

  /// Version number of the plugin.
  final String version;

  /// The minimum Mattermost server version required for the plugin.
  final String? minServerVersion;

  /// Deprecated in Mattermost 5.2 release.
  final MPluginBackend? backend;

  /// Server configuration for the plugin.
  final MPluginServer? server;

  /// Webapp configuration for the plugin.
  final MPluginWebapp? webapp;

  /// Settings schema used to define the System Console UI for the plugin.
  final Map<String, dynamic>? settingsSchema;

  MPluginManifest({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    this.minServerVersion,
    this.backend,
    this.server,
    this.webapp,
    this.settingsSchema,
  });

  factory MPluginManifest.fromJson(Map<String, dynamic> json) {
    return MPluginManifest(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      version: json['version'] ?? '',
      minServerVersion: json['min_server_version'],
      backend: json['backend'] != null ? MPluginBackend.fromJson(json['backend']) : null,
      server: json['server'] != null ? MPluginServer.fromJson(json['server']) : null,
      webapp: json['webapp'] != null ? MPluginWebapp.fromJson(json['webapp']) : null,
      settingsSchema: json['settings_schema'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'version': version,
      'min_server_version': minServerVersion,
      'backend': backend?.toJson(),
      'server': server?.toJson(),
      'webapp': webapp?.toJson(),
      'settings_schema': settingsSchema,
    };
  }
}

/// Deprecated backend configuration (Mattermost 5.2).
class MPluginBackend {
  /// Path to the executable binary.
  final String? executable;

  MPluginBackend({this.executable});

  factory MPluginBackend.fromJson(Map<String, dynamic> json) {
    return MPluginBackend(
      executable: json['executable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'executable': executable,
    };
  }
}

/// Server configuration for the plugin.
class MPluginServer {
  /// Paths to executable binaries for different platforms.
  final Map<String, String>? executables;

  /// Path to the executable binary.
  final String? executable;

  MPluginServer({this.executables, this.executable});

  factory MPluginServer.fromJson(Map<String, dynamic> json) {
    Map<String, String>? executables;
    if (json['executables'] != null && json['executables'] is Map) {
      executables = (json['executables'] as Map<String, dynamic>).map((k, v) => MapEntry(k, v as String));
    }
    return MPluginServer(
      executables: executables,
      executable: json['executable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'executables': executables,
      'executable': executable,
    };
  }
}

/// Webapp configuration for the plugin.
class MPluginWebapp {
  /// Path to the webapp JavaScript bundle.
  final String? bundlePath;

  MPluginWebapp({this.bundlePath});

  factory MPluginWebapp.fromJson(Map<String, dynamic> json) {
    return MPluginWebapp(
      bundlePath: json['bundle_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bundle_path': bundlePath,
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
    return {
      'active': active.map((manifest) => manifest.toJson()).toList(),
      'inactive': inactive.map((manifest) => manifest.toJson()).toList(),
    };
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
