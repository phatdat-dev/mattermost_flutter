import 'package:dio/dio.dart';

import '../models/models.dart';

/// API for webhook-related endpoints
class MWebhooksApi {
  final Dio _dio;

  MWebhooksApi(this._dio);

  /// Create an incoming webhook
  Future<MIncomingWebhook> createIncomingWebhook({
    required String channelId,
    required String displayName,
    String? description,
    String? username,
    String? iconUrl,
  }) async {
    try {
      final data = {
        'channel_id': channelId,
        'display_name': displayName,
        if (description != null) 'description': description,
        if (username != null) 'username': username,
        if (iconUrl != null) 'icon_url': iconUrl,
      };

      final response = await _dio.post(
        '/api/v4/hooks/incoming',
        data: data,
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
    String hookId, {
    String? channelId,
    String? displayName,
    String? description,
    String? username,
    String? iconUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (channelId != null) data['channel_id'] = channelId;
      if (displayName != null) data['display_name'] = displayName;
      if (description != null) data['description'] = description;
      if (username != null) data['username'] = username;
      if (iconUrl != null) data['icon_url'] = iconUrl;

      final response = await _dio.put(
        '/api/v4/hooks/incoming/$hookId',
        data: data,
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
  Future<MOutgoingWebhook> createOutgoingWebhook({
    required String channelId,
    required String teamId,
    required String displayName,
    required String triggerWords,
    required String callbackUrls,
    String? description,
    String? triggerWhen,
    String? contentType,
  }) async {
    try {
      final data = {
        'channel_id': channelId,
        'team_id': teamId,
        'display_name': displayName,
        'trigger_words': triggerWords,
        'callback_urls': callbackUrls,
        if (description != null) 'description': description,
        if (triggerWhen != null) 'trigger_when': triggerWhen,
        if (contentType != null) 'content_type': contentType,
      };

      final response = await _dio.post(
        '/api/v4/hooks/outgoing',
        data: data,
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
    String hookId, {
    String? channelId,
    String? displayName,
    String? description,
    String? triggerWords,
    String? triggerWhen,
    String? callbackUrls,
    String? contentType,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (channelId != null) data['channel_id'] = channelId;
      if (displayName != null) data['display_name'] = displayName;
      if (description != null) data['description'] = description;
      if (triggerWords != null) data['trigger_words'] = triggerWords;
      if (triggerWhen != null) data['trigger_when'] = triggerWhen;
      if (callbackUrls != null) data['callback_urls'] = callbackUrls;
      if (contentType != null) data['content_type'] = contentType;

      final response = await _dio.put(
        '/api/v4/hooks/outgoing/$hookId',
        data: data,
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
