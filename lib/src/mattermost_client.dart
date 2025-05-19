import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/api/api.dart';
import 'package:mattermost_flutter/src/config/config.dart';
import 'package:mattermost_flutter/src/websocket/websocket_client.dart';

/// Main client class for interacting with Mattermost API
class MattermostClient {
  final MattermostConfig config;
  final Dio _dio;
  late final UsersApi users;
  late final TeamsApi teams;
  late final ChannelsApi channels;
  late final PostsApi posts;
  late final FilesApi files;
  late final SystemApi system;
  late final WebhooksApi webhooks;
  late final PreferencesApi preferences;
  late final StatusApi status;
  late final EmojisApi emojis;
  late final ComplianceApi compliance;
  late final ClustersApi clusters;
  late final LdapApi ldap;
  late final OAuthApi oauth;
  late final ElasticsearchApi elasticsearch;
  late final PluginsApi plugins;
  late final RolesApi roles;
  late final SchemesApi schemes;
  late final IntegrationsApi integrations;
  late final BrandApi brand;
  late final CommandsApi commands;
  late final GroupsApi groups;
  late final BotsApi bots;
  late final JobsApi jobs;
  late final DataRetentionApi dataRetention;
  late final ExportsApi exports;
  late final ImportsApi imports;
  late final SamlApi saml;
  late final PermissionsApi permissions;
  late final SharedChannelsApi sharedChannels;
  late final CloudApi cloud;
  late final MattermostWebSocketClient webSocket;

  MattermostClient({
    required this.config,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
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
    };

    // Add logging interceptor in debug mode
    if (config.enableDebugLogs) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (config.token != null && config.token!.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer ${config.token}';
        }
        return handler.next(options);
      },
    ));
  }

  void _initializeApis() {
    users = UsersApi(_dio);
    teams = TeamsApi(_dio);
    channels = ChannelsApi(_dio);
    posts = PostsApi(_dio);
    files = FilesApi(_dio);
    system = SystemApi(_dio);
    webhooks = WebhooksApi(_dio);
    preferences = PreferencesApi(_dio);
    status = StatusApi(_dio);
    emojis = EmojisApi(_dio);
    compliance = ComplianceApi(_dio);
    clusters = ClustersApi(_dio);
    ldap = LdapApi(_dio);
    oauth = OAuthApi(_dio);
    elasticsearch = ElasticsearchApi(_dio);
    plugins = PluginsApi(_dio);
    roles = RolesApi(_dio);
    schemes = SchemesApi(_dio);
    integrations = IntegrationsApi(_dio);
    brand = BrandApi(_dio);
    commands = CommandsApi(_dio);
    groups = GroupsApi(_dio);
    bots = BotsApi(_dio);
    jobs = JobsApi(_dio);
    dataRetention = DataRetentionApi(_dio);
    exports = ExportsApi(_dio);
    imports = ImportsApi(_dio);
    saml = SamlApi(_dio);
    permissions = PermissionsApi(_dio);
    sharedChannels = SharedChannelsApi(_dio);
    cloud = CloudApi(_dio);
  }

  /// Login to Mattermost server
  Future<void> login({
    required String loginId,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v4/users/login',
        data: {
          'login_id': loginId,
          'password': password,
        },
      );
      
      final token = response.headers.map['token']?.first;
      if (token != null) {
        config.token = token;
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      
      // Connect to WebSocket after successful login
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
