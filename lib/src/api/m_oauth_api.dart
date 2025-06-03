import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for OAuth-related endpoints
class MOAuthApi {
  final Dio _dio;

  MOAuthApi(this._dio);

  /// Register OAuth app
  ///
  /// Register an OAuth 2.0 client application with Mattermost as the service provider.
  /// ##### Permissions
  /// Must have `manage_oauth` permission.
  ///
  /// Parameters:
  /// - [name]: The name of the client application
  /// - [description]: A short description of the application
  /// - [callbackUrls]: A list of callback URLs for the appliation
  /// - [homepage]: A link to information about the client application
  /// - [iconUrl]: A URL to an icon to display with the application
  /// - [isTrusted]: Set the application as trusted. Trusted applications do not require user consent and skip the authorization step.
  Future<MOAuthApp> registerOAuthApp({
    required String name,
    required String description,
    required List<String> callbackUrls,
    required String homepage,
    String? iconUrl,
    bool? isTrusted,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description,
        'callback_urls': callbackUrls,
        'homepage': homepage,
        if (iconUrl != null) 'icon_url': iconUrl,
        if (isTrusted != null) 'is_trusted': isTrusted,
      };

      final response = await _dio.post(
        '/api/v4/oauth/apps',
        data: data,
      );
      return MOAuthApp.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get OAuth apps
  ///
  /// Get a page of OAuth 2.0 client applications registered with your Mattermost server.
  /// ##### Permissions
  /// With `manage_oauth` permission, the apps registered by the current user are returned.
  /// With `manage_system_wide_oauth` permission, all apps regardless of creator are returned.
  ///
  /// Parameters:
  /// - [page]: The page to select
  /// - [perPage]: The number of apps per page
  Future<List<MOAuthApp>> getOAuthApps({int page = 0, int perPage = 60}) async {
    try {
      final response = await _dio.get(
        '/api/v4/oauth/apps',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );
      return (response.data as List).map((appData) => MOAuthApp.fromJson(appData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get OAuth app
  ///
  /// Get an OAuth 2.0 client application registered with your Mattermost server.
  /// ##### Permissions
  /// If app creator, must have `mange_oauth` permission otherwise `manage_system_wide_oauth` permission is required.
  ///
  /// Parameters:
  /// - [appId]: Application client id
  Future<MOAuthApp> getOAuthApp(String appId) async {
    try {
      final response = await _dio.get('/api/v4/oauth/apps/$appId');
      return MOAuthApp.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update OAuth app
  ///
  /// Update an OAuth 2.0 client application.
  /// ##### Permissions
  /// If app creator, must have `mange_oauth` permission otherwise `manage_system_wide_oauth` permission is required.
  ///
  /// Parameters:
  /// - [appId]: Application client id
  /// - [name]: The name of the client application
  /// - [description]: A short description of the application
  /// - [callbackUrls]: A list of callback URLs for the appliation
  /// - [homepage]: A link to information about the client application
  /// - [iconUrl]: A URL to an icon to display with the application
  /// - [isTrusted]: Set the application as trusted. Trusted applications do not require user consent and skip the authorization step.
  Future<MOAuthApp> updateOAuthApp(
    String appId, {
    String? name,
    String? description,
    List<String>? callbackUrls,
    String? homepage,
    String? iconUrl,
    bool? isTrusted,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (callbackUrls != null) data['callback_urls'] = callbackUrls;
      if (homepage != null) data['homepage'] = homepage;
      if (iconUrl != null) data['icon_url'] = iconUrl;
      if (isTrusted != null) data['is_trusted'] = isTrusted;

      final response = await _dio.put(
        '/api/v4/oauth/apps/$appId',
        data: data,
      );
      return MOAuthApp.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get OAuth app info (public endpoint with limited information)
  ///
  /// Get public information about an OAuth 2.0 client application registered with your Mattermost server.
  /// ##### Permissions
  /// Must be authenticated.
  ///
  /// Parameters:
  /// - [appId]: Application client id
  Future<MOAuthAppInfo> getOAuthAppInfo(String appId) async {
    try {
      final response = await _dio.get('/api/v4/oauth/apps/$appId/info');
      return MOAuthAppInfo.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete OAuth app
  ///
  /// Delete an OAuth 2.0 client application registered with your Mattermost server.
  /// ##### Permissions
  /// If app creator, must have `manage_oauth` permission otherwise `manage_system_wide_oauth` permission is required.
  ///
  /// Parameters:
  /// - [appId]: Application client id
  Future<void> deleteOAuthApp(String appId) async {
    try {
      await _dio.delete('/api/v4/oauth/apps/$appId');
    } catch (e) {
      rethrow;
    }
  }

  /// Regenerate OAuth app secret
  ///
  /// Regenerate the client secret for an OAuth 2.0 client application registered with your Mattermost server.
  /// ##### Permissions
  /// If app creator, must have `manage_oauth` permission otherwise `manage_system_wide_oauth` permission is required.
  ///
  /// Parameters:
  /// - [appId]: Application client id
  Future<MOAuthApp> regenerateOAuthAppSecret(String appId) async {
    try {
      final response = await _dio.post(
        '/api/v4/oauth/apps/$appId/regen_secret',
      );
      return MOAuthApp.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get authorized OAuth apps
  ///
  /// Get a page of OAuth 2.0 client applications authorized to access a user's account.
  /// ##### Permissions
  /// Must be authenticated.
  ///
  /// Parameters:
  /// - [page]: The page to select
  /// - [perPage]: The number of apps per page
  Future<List<MOAuthApp>> getAuthorizedOAuthApps() async {
    try {
      final response = await _dio.get('/api/v4/oauth/authorized');
      return (response.data as List).map((appData) => MOAuthApp.fromJson(appData)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
