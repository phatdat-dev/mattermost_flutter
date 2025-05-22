import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for command-related endpoints
class MCommandsApi {
  final Dio _dio;

  MCommandsApi(this._dio);

  /// Create a command
  Future<MCommand> createCommand(MCreateCommandRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v4/commands',
        data: request.toJson(),
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
    String commandId,
    MUpdateCommandRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v4/commands/$commandId',
        data: request.toJson(),
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
  Future<MCommandResponse> executeCommand(
    MExecuteCommandRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/commands/execute',
        data: request.toJson(),
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
