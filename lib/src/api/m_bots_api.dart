import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for bot-related endpoints
class MBotsApi {
  final Dio _dio;

  MBotsApi(this._dio);

  /// Create a bot
  Future<MBot> createBot(MCreateBotRequest request) async {
    try {
      final response = await _dio.post('/api/v4/bots', data: request.toJson());
      return MBot.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get bots
  Future<List<MBot>> getBots({
    int page = 0,
    int perPage = 60,
    bool? includeDeleted,
    bool? onlyOrphaned,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (includeDeleted != null) {
        queryParams['include_deleted'] = includeDeleted.toString();
      }
      if (onlyOrphaned != null) {
        queryParams['only_orphaned'] = onlyOrphaned.toString();
      }

      final response = await _dio.get(
        '/api/v4/bots',
        queryParameters: queryParams,
      );
      return (response.data as List).map((botData) => MBot.fromJson(botData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a bot
  Future<MBot> getBot(String botUserId, {bool? includeDeleted}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (includeDeleted != null) {
        queryParams['include_deleted'] = includeDeleted.toString();
      }

      final response = await _dio.get(
        '/api/v4/bots/$botUserId',
        queryParameters: queryParams,
      );
      return MBot.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Disable a bot
  Future<MBot> disableBot(String botUserId) async {
    try {
      final response = await _dio.post('/api/v4/bots/$botUserId/disable');
      return MBot.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Enable a bot
  Future<MBot> enableBot(String botUserId) async {
    try {
      final response = await _dio.post('/api/v4/bots/$botUserId/enable');
      return MBot.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Assign a bot to a user
  Future<MBot> assignBotToUser(String botUserId, String userId) async {
    try {
      final response = await _dio.post(
        '/api/v4/bots/$botUserId/assign/$userId',
      );
      return MBot.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
