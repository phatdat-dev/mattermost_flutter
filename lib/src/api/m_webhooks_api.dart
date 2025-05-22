import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for webhook-related endpoints
class MWebhooksApi {
  final Dio _dio;

  MWebhooksApi(this._dio);

  /// Create an incoming webhook
  Future<MIncomingWebhook> createIncomingWebhook(
    MCreateIncomingWebhookRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/hooks/incoming',
        data: request.toJson(),
      );
      return MIncomingWebhook.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get an incoming webhook
  Future<MIncomingWebhook> getIncomingWebhook(String hookId) async {
    try {
      final response = await _dio.get('/api/v4/hooks/incoming/$hookId');
      return MIncomingWebhook.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get incoming webhooks
  Future<List<MIncomingWebhook>> getIncomingWebhooks({
    int page = 0,
    int perPage = 60,
    String? teamId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (teamId != null) queryParams['team_id'] = teamId;

      final response = await _dio.get(
        '/api/v4/hooks/incoming',
        queryParameters: queryParams,
      );
      return (response.data as List).map((webhookData) => MIncomingWebhook.fromJson(webhookData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Update an incoming webhook
  Future<MIncomingWebhook> updateIncomingWebhook(
    String hookId,
    MUpdateIncomingWebhookRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v4/hooks/incoming/$hookId',
        data: request.toJson(),
      );
      return MIncomingWebhook.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete an incoming webhook
  Future<void> deleteIncomingWebhook(String hookId) async {
    try {
      await _dio.delete('/api/v4/hooks/incoming/$hookId');
    } catch (e) {
      rethrow;
    }
  }

  /// Create an outgoing webhook
  Future<MOutgoingWebhook> createOutgoingWebhook(
    MCreateOutgoingWebhookRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/hooks/outgoing',
        data: request.toJson(),
      );
      return MOutgoingWebhook.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get an outgoing webhook
  Future<MOutgoingWebhook> getOutgoingWebhook(String hookId) async {
    try {
      final response = await _dio.get('/api/v4/hooks/outgoing/$hookId');
      return MOutgoingWebhook.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get outgoing webhooks
  Future<List<MOutgoingWebhook>> getOutgoingWebhooks({
    int page = 0,
    int perPage = 60,
    String? teamId,
    String? channelId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (teamId != null) queryParams['team_id'] = teamId;
      if (channelId != null) queryParams['channel_id'] = channelId;

      final response = await _dio.get(
        '/api/v4/hooks/outgoing',
        queryParameters: queryParams,
      );
      return (response.data as List).map((webhookData) => MOutgoingWebhook.fromJson(webhookData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Update an outgoing webhook
  Future<MOutgoingWebhook> updateOutgoingWebhook(
    String hookId,
    MUpdateOutgoingWebhookRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v4/hooks/outgoing/$hookId',
        data: request.toJson(),
      );
      return MOutgoingWebhook.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete an outgoing webhook
  Future<void> deleteOutgoingWebhook(String hookId) async {
    try {
      await _dio.delete('/api/v4/hooks/outgoing/$hookId');
    } catch (e) {
      rethrow;
    }
  }

  /// Regenerate the token for an outgoing webhook
  Future<MOutgoingWebhook> regenerateOutgoingWebhookToken(String hookId) async {
    try {
      final response = await _dio.post(
        '/api/v4/hooks/outgoing/$hookId/regen_token',
      );
      return MOutgoingWebhook.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
