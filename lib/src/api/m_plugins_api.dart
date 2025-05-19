import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for plugin-related endpoints
class MPluginsApi {
  final Dio _dio;

  MPluginsApi(this._dio);

  /// Get plugins
  Future<MPluginManifests> getPlugins() async {
    try {
      final response = await _dio.get('/api/v4/plugins');
      return MPluginManifests.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Enable a plugin
  Future<void> enablePlugin(String pluginId) async {
    try {
      await _dio.post('/api/v4/plugins/$pluginId/enable');
    } catch (e) {
      rethrow;
    }
  }

  /// Disable a plugin
  Future<void> disablePlugin(String pluginId) async {
    try {
      await _dio.post('/api/v4/plugins/$pluginId/disable');
    } catch (e) {
      rethrow;
    }
  }

  /// Remove a plugin
  Future<void> removePlugin(String pluginId) async {
    try {
      await _dio.delete('/api/v4/plugins/$pluginId');
    } catch (e) {
      rethrow;
    }
  }

  /// Get plugin status
  Future<MPluginStatus> getPluginStatus(String pluginId) async {
    try {
      final response = await _dio.get('/api/v4/plugins/$pluginId/status');
      return MPluginStatus.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
