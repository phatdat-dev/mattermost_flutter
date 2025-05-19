/// OAuth app model
class MOAuthApp {
  final String id;
  final String clientId;
  final String clientSecret;
  final String name;
  final String description;
  final String iconUrl;
  final String callbackUrls;
  final String homepage;
  final bool isTrusted;
  final int? createAt;
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
      callbackUrls: json['callback_urls'] ?? '',
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

/// Register OAuth app request
class MRegisterOAuthAppRequest {
  final String name;
  final String description;
  final String iconUrl;
  final List<String> callbackUrls;
  final String homepage;
  final bool? isTrusted;

  MRegisterOAuthAppRequest({
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.callbackUrls,
    required this.homepage,
    this.isTrusted,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'callback_urls': callbackUrls,
      'homepage': homepage,
      if (isTrusted != null) 'is_trusted': isTrusted,
    };
  }
}

/// Update OAuth app request
class MUpdateOAuthAppRequest {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final List<String> callbackUrls;
  final String homepage;
  final bool? isTrusted;

  MUpdateOAuthAppRequest({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.callbackUrls,
    required this.homepage,
    this.isTrusted,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'callback_urls': callbackUrls,
      'homepage': homepage,
      if (isTrusted != null) 'is_trusted': isTrusted,
    };
  }
}
