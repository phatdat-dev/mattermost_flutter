import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for command-related endpoints
class MCommandsApi {
  final Dio _dio;

  MCommandsApi(this._dio);

  /// Create a command
  Future<MCommand> createCommand({
    required String teamId,
    required String trigger,
    required String method,
    required String username,
    required String displayName,
    required String description,
    required String url,
    String? iconUrl,
    bool? autoComplete,
    String? autoCompleteDesc,
    String? autoCompleteHint,
  }) async {
    try {
      final data = {
        'team_id': teamId,
        'trigger': trigger,
        'method': method,
        'username': username,
        'display_name': displayName,
        'description': description,
        'url': url,
        if (iconUrl != null) 'icon_url': iconUrl,
        if (autoComplete != null) 'auto_complete': autoComplete,
        if (autoCompleteDesc != null) 'auto_complete_desc': autoCompleteDesc,
        if (autoCompleteHint != null) 'auto_complete_hint': autoCompleteHint,
      };

      final response = await _dio.post(
        '/api/v4/commands',
        data: data,
      );
      return MCommand.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all commands
  Future<List<MCommand>> getCommands({String? teamId, bool? customOnly}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (teamId != null) queryParams['team_id'] = teamId;
      if (customOnly != null) queryParams['custom_only'] = customOnly.toString();

      final response = await _dio.get(
        '/api/v4/commands',
        queryParameters: queryParams,
      );
      return (response.data as List).map((commandData) => MCommand.fromJson(commandData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a command
  Future<MCommand> getCommand(String commandId) async {
    try {
      final response = await _dio.get('/api/v4/commands/$commandId');
      return MCommand.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a command
  Future<MCommand> updateCommand(
    String commandId, {
    String? trigger,
    String? method,
    String? username,
    String? displayName,
    String? description,
    String? url,
    String? iconUrl,
    bool? autoComplete,
    String? autoCompleteDesc,
    String? autoCompleteHint,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (trigger != null) data['trigger'] = trigger;
      if (method != null) data['method'] = method;
      if (username != null) data['username'] = username;
      if (displayName != null) data['display_name'] = displayName;
      if (description != null) data['description'] = description;
      if (url != null) data['url'] = url;
      if (iconUrl != null) data['icon_url'] = iconUrl;
      if (autoComplete != null) data['auto_complete'] = autoComplete;
      if (autoCompleteDesc != null) data['auto_complete_desc'] = autoCompleteDesc;
      if (autoCompleteHint != null) data['auto_complete_hint'] = autoCompleteHint;

      final response = await _dio.put(
        '/api/v4/commands/$commandId',
        data: data,
      );
      return MCommand.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a command
  Future<void> deleteCommand(String commandId) async {
    try {
      await _dio.delete('/api/v4/commands/$commandId');
    } catch (e) {
      rethrow;
    }
  }

  /// Execute a command
  Future<MCommandResponse> executeCommand({
    required String channelId,
    required String command,
    String? teamId,
  }) async {
    try {
      final data = {
        'channel_id': channelId,
        'command': command,
        if (teamId != null) 'team_id': teamId,
      };

      final response = await _dio.post(
        '/api/v4/commands/execute',
        data: data,
      );
      return MCommandResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// List autocomplete commands
  Future<List<MCommand>> listAutocompleteCommands(String teamId) async {
    try {
      final response = await _dio.get(
        '/api/v4/teams/$teamId/commands/autocomplete',
      );
      return (response.data as List).map((commandData) => MCommand.fromJson(commandData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Regenerate command token
  Future<Map<String, String>> regenerateCommandToken(String commandId) async {
    try {
      final response = await _dio.put(
        '/api/v4/commands/$commandId/regen_token',
      );
      return {'token': response.data['token']};
    } catch (e) {
      rethrow;
    }
  }
}
