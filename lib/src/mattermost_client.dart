import 'package:dio/dio.dart';

import 'api/api.dart';
import 'config/config.dart';
import 'websocket/websocket_client.dart';

/// Main client class for interacting with Mattermost API
class MattermostClient {
  final MattermostConfig config;
  final Dio _dio;
  late final MUsersApi users;
  late final MTeamsApi teams;
  late final MChannelsApi channels;
  late final MPostsApi posts;
  late final MFilesApi files;
  late final MSystemApi system;
  late final MWebhooksApi webhooks;
  late final MPreferencesApi preferences;
  late final MStatusApi status;
  late final MEmojisApi emojis;
  late final MComplianceApi compliance;
  late final MClustersApi clusters;
  late final MLdapApi ldap;
  late final MOAuthApi oauth;
  late final MElasticsearchApi elasticsearch;
  late final MPluginsApi plugins;
  late final MRolesApi roles;
  late final MSchemesApi schemes;
  late final MIntegrationsApi integrations;
  late final MBrandApi brand;
  late final MCommandsApi commands;
  late final MGroupsApi groups;
  late final MBotsApi bots;
  late final MJobsApi jobs;
  late final MDataRetentionApi dataRetention;
  late final MExportsApi exports;
  late final MImportsApi imports;
  late final MSamlApi saml;
  late final MPermissionsApi permissions;
  late final MSharedChannelsApi sharedChannels;
  late final MCloudApi cloud;
  late final MattermostWebSocketClient webSocket;

  MattermostClient({required this.config, Dio? dio}) : _dio = dio ?? Dio() {
    _configureDio();
    _initializeApis();
    webSocket = MattermostWebSocketClient(config: config, client: this);
  }

  void _configureDio() {
    _dio.options.baseUrl = config.baseUrl;
    _dio.options.connectTimeout = config.connectTimeout;
    _dio.options.receiveTimeout = config.receiveTimeout;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Mobile', // {"Mobile", "Android", "iOS", "iPhone", "iPad"}
    };

    // Add logging interceptor in debug mode
    if (config.enableDebugLogs) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (config.token != null && config.token!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${config.token}';
          }
          return handler.next(options);
        },
      ),
    );
  }

  void _initializeApis() {
    users = MUsersApi(_dio);
    teams = MTeamsApi(_dio);
    channels = MChannelsApi(_dio);
    posts = MPostsApi(_dio);
    files = MFilesApi(_dio);
    system = MSystemApi(_dio);
    webhooks = MWebhooksApi(_dio);
    preferences = MPreferencesApi(_dio);
    status = MStatusApi(_dio);
    emojis = MEmojisApi(_dio);
    compliance = MComplianceApi(_dio);
    clusters = MClustersApi(_dio);
    ldap = MLdapApi(_dio);
    oauth = MOAuthApi(_dio);
    elasticsearch = MElasticsearchApi(_dio);
    plugins = MPluginsApi(_dio);
    roles = MRolesApi(_dio);
    schemes = MSchemesApi(_dio);
    integrations = MIntegrationsApi(_dio);
    brand = MBrandApi(_dio);
    commands = MCommandsApi(_dio);
    groups = MGroupsApi(_dio);
    bots = MBotsApi(_dio);
    jobs = MJobsApi(_dio);
    dataRetention = MDataRetentionApi(_dio);
    exports = MExportsApi(_dio);
    imports = MImportsApi(_dio);
    saml = MSamlApi(_dio);
    permissions = MPermissionsApi(_dio);
    sharedChannels = MSharedChannelsApi(_dio);
    cloud = MCloudApi(_dio);
  }

  /// Login to Mattermost server
  /// You can get infomation about the current user after login by calling [MUsersApi.getMe] method on the [users] API.
  /// ```dart
  /// final currentUser = await client.users.getMe();
  /// ```
  Future<void> login({
    String? id,
    String? loginId,
    String? password,

    /// Optional token for token-based authentication
    String? token,
    String? deviceId,
    String? ldapOnly,
  }) async {
    assert(
      (loginId != null && password != null) || token != null,
      'Either loginId and password or token must be provided',
    );

    try {
      if (token == null || token.isEmpty) {
        final response = await _dio.post(
          '/api/v4/users/login',
          data: {
            if (id != null) 'id': id,
            if (loginId != null) 'login_id': loginId,
            if (password != null) 'password': password,
            if (token != null) 'token': token,
            if (deviceId != null) 'device_id': deviceId,
            if (ldapOnly != null) 'ldap_only': ldapOnly,
          },
        );

        token = response.headers.map['token']?.first;
      }

      config.token = token;
      _dio.options.headers['Authorization'] = 'Bearer $token';

      // Connect to WebSocket after successful login
      await webSocket.connect();
    } catch (e) {
      rethrow;
    }
  }

  // MSwitchLoginRequest
  /// Switch login method
  Future<void> switchLogin({
    required String currentService,
    required String newService,
    String? email,
    String? password,
    String? mfaCode,
    String? ldapId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v4/users/login/switch',
        data: {
          'current_service': currentService,
          'new_service': newService,
          if (email != null) 'email': email,
          if (password != null) 'password': password,
          if (mfaCode != null) 'mfa_code': mfaCode,
          if (ldapId != null) 'ldap_id': ldapId,
        },
      );

      final token = response.headers.map['token']?.first;
      if (token != null && token.isNotEmpty) {
        config.token = token;
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }

      // Reconnect WebSocket after switching login
      await webSocket.connect();
    } catch (e) {
      rethrow;
    }
  }

  /// Logout from Mattermost server
  Future<void> logout() async {
    try {
      await _dio.post('/api/v4/users/logout');
      config.token = null;
      _dio.options.headers.remove('Authorization');
      webSocket.disconnect();
    } catch (e) {
      rethrow;
    }
  }

  /// Close the client and all connections
  void close() {
    webSocket.disconnect();
  }
}
