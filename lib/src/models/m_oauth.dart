/// OAuth app model
class MOAuthApp {
  /// The OAuth application id
  final String id;

  /// The OAuth application client id
  final String clientId;

  /// The OAuth application client secret
  final String clientSecret;

  /// The name of the OAuth application
  final String name;

  /// The description of the OAuth application
  final String description;

  /// A URL to an icon to display with the application
  final String iconUrl;

  /// A list of callback URLs for the application
  final List<String> callbackUrls;

  /// A link to information about the client application
  final String homepage;

  /// Set the application as trusted. Trusted applications do not require user consent
  final bool isTrusted;

  /// The time of creation of the OAuth application in milliseconds since the Unix epoch
  final int? createAt;

  /// The time of the last update of the OAuth application in milliseconds since the Unix epoch
  final int? updateAt;

  MOAuthApp({
    required this.id,
    required this.clientId,
    required this.clientSecret,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.callbackUrls,
    required this.homepage,
    required this.isTrusted,
    this.createAt,
    this.updateAt,
  });

  factory MOAuthApp.fromJson(Map<String, dynamic> json) {
    return MOAuthApp(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      clientSecret: json['client_secret'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['icon_url'] ?? '',
      callbackUrls: json['callback_urls'] is List
          ? List<String>.from(json['callback_urls'])
          : json['callback_urls'] != null
          ? [json['callback_urls'].toString()]
          : <String>[],
      homepage: json['homepage'] ?? '',
      isTrusted: json['is_trusted'] ?? false,
      createAt: json['create_at'],
      updateAt: json['update_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'client_secret': clientSecret,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'callback_urls': callbackUrls,
      'homepage': homepage,
      'is_trusted': isTrusted,
      if (createAt != null) 'create_at': createAt,
      if (updateAt != null) 'update_at': updateAt,
    };
  }
}

/// Public OAuth app info model (limited information for public endpoint)
class MOAuthAppInfo {
  /// The OAuth application id
  final String id;

  /// The name of the OAuth application
  final String name;

  /// The description of the OAuth application
  final String description;

  /// A URL to an icon to display with the application
  final String iconUrl;

  /// A link to information about the client application
  final String homepage;

  MOAuthAppInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.homepage,
  });

  factory MOAuthAppInfo.fromJson(Map<String, dynamic> json) {
    return MOAuthAppInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['icon_url'] ?? '',
      homepage: json['homepage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'homepage': homepage,
    };
  }
}
