import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for user preferences-related endpoints
class MPreferencesApi {
  final Dio _dio;

  MPreferencesApi(this._dio);

  /// Get user preferences
  Future<List<MPreference>> getUserPreferences(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/preferences');
      return (response.data as List).map((prefData) => MPreference.fromJson(prefData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Save user preferences
  Future<void> saveUserPreferences(String userId, List<MPreference> preferences) async {
    try {
      await _dio.put('/api/v4/users/$userId/preferences', data: preferences.map((pref) => pref.toJson()).toList());
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user preferences
  Future<void> deleteUserPreferences(String userId, List<MPreference> preferences) async {
    try {
      await _dio.post('/api/v4/users/$userId/preferences/delete', data: preferences.map((pref) => pref.toJson()).toList());
    } catch (e) {
      rethrow;
    }
  }

  /// Get user preference by category
  Future<List<MPreference>> getUserPreferencesByCategory(String userId, String category) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/preferences/$category');
      return (response.data as List).map((prefData) => MPreference.fromJson(prefData)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get specific user preference
  Future<MPreference> getUserPreference(String userId, String category, String name) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/preferences/$category/name/$name');
      return MPreference.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
