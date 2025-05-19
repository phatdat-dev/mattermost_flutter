import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for command-related endpoints
class CommandsApi {
  final Dio _dio;

  CommandsApi(this._dio);

  /// Create a command
  Future<Command> createCommand(CreateCommandRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v4/commands',
        data: request.toJson(),
      );
      return Command.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all commands
  Future<List<Command>> getCommands({
    String? teamId,
    bool? customOnly,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (teamId != null) queryParams['team_id'] = teamId;
      if (customOnly != null) queryParams['custom_only'] = customOnly.toString();

      final response = await _dio.get(
        '/api/v4/commands',
        queryParameters: queryParams,
      );
      return (response.data as List)
          .map((commandData) => Command.fromJson(commandData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a command
  Future<Command> getCommand(String commandId) async {
    try {
      final response = await _dio.get('/api/v4/commands/$commandId');
      return Command.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update a command
  Future<Command> updateCommand(
    String commandId,
    UpdateCommandRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v4/commands/$commandId',
        data: request.toJson(),
      );
      return Command.fromJson(response.data);
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
  Future<CommandResponse> executeCommand(ExecuteCommandRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v4/commands/execute',
        data: request.toJson(),
      );
      return CommandResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// List autocomplete commands
  Future<List<Command>> listAutocompleteCommands(String teamId) async {
    try {
      final response = await _dio.get(
        '/api/v4/teams/$teamId/commands/autocomplete',
      );
      return (response.data as List)
          .map((commandData) => Command.fromJson(commandData))
          .toList();
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
      return {
        'token': response.data['token'],
      };
    } catch (e) {
      rethrow;
    }
  }
}
