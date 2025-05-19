import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for webhook-related endpoints
class WebhooksApi {
  final Dio _dio;

  WebhooksApi(this._dio);

  /// Create an incoming webhook
  Future<IncomingWebhook> createIncomingWebhook(
    CreateIncomingWebhookRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/hooks/incoming',
        data: request.toJson(),
      );
      return IncomingWebhook.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get an incoming webhook
  Future<IncomingWebhook> getIncomingWebhook(String hookId) async {
    try {
      final response = await _dio.get('/api/v4/hooks/incoming/$hookId');
      return IncomingWebhook.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get incoming webhooks
  Future<List<IncomingWebhook>> getIncomingWebhooks({
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
      return (response.data as List)
          .map((webhookData) => IncomingWebhook.fromJson(webhookData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Update an incoming webhook
  Future<IncomingWebhook> updateIncomingWebhook(
    String hookId,
    UpdateIncomingWebhookRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v4/hooks/incoming/$hookId',
        data: request.toJson(),
      );
      return IncomingWebhook.fromJson(response.data);
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
  Future<OutgoingWebhook> createOutgoingWebhook(
    CreateOutgoingWebhookRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v4/hooks/outgoing',
        data: request.toJson(),
      );
      return OutgoingWebhook.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get an outgoing webhook
  Future<OutgoingWebhook> getOutgoingWebhook(String hookId) async {
    try {
      final response = await _dio.get('/api/v4/hooks/outgoing/$hookId');
      return OutgoingWebhook.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get outgoing webhooks
  Future<List<OutgoingWebhook>> getOutgoingWebhooks({
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
      return (response.data as List)
          .map((webhookData) => OutgoingWebhook.fromJson(webhookData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Update an outgoing webhook
  Future<OutgoingWebhook> updateOutgoingWebhook(
    String hookId,
    UpdateOutgoingWebhookRequest request,
  ) async {
    try {
      final response = await _dio.put(
        '/api/v4/hooks/outgoing/$hookId',
        data: request.toJson(),
      );
      return OutgoingWebhook.fromJson(response.data);
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
  Future<OutgoingWebhook> regenerateOutgoingWebhookToken(String hookId) async {
    try {
      final response = await _dio.post(
        '/api/v4/hooks/outgoing/$hookId/regen_token',
      );
      return OutgoingWebhook.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
