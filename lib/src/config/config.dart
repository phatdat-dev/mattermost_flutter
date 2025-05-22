/// Configuration for Mattermost client
class MattermostConfig {
  /// Base URL of the Mattermost server
  final String baseUrl;

  /// Authentication token
  String? token;

  /// Connection timeout in milliseconds
  final Duration connectTimeout;

  /// Receive timeout in milliseconds
  final Duration receiveTimeout;

  /// Enable debug logs
  final bool enableDebugLogs;

  MattermostConfig({
    required this.baseUrl,
    this.token,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.enableDebugLogs = false,
  });
}
