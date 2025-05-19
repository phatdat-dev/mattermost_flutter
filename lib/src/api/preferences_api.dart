import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/models.dart';

/// API for user preferences-related endpoints
class PreferencesApi {
  final Dio _dio;

  PreferencesApi(this._dio);

  /// Get user preferences
  Future<List<Preference>> getUserPreferences(String userId) async {
    try {
      final response = await _dio.get('/api/v4/users/$userId/preferences');
      return (response.data as List)
          .map((prefData) => Preference.fromJson(prefData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Save user preferences
  Future<void> saveUserPreferences(
    String userId,
    List<Preference> preferences,
  ) async {
    try {
      await _dio.put(
        '/api/v4/users/$userId/preferences',
        data: preferences.map((pref) => pref.toJson()).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user preferences
  Future<void> deleteUserPreferences(
    String userId,
    List<Preference> preferences,
  ) async {
    try {
      await _dio.post(
        '/api/v4/users/$userId/preferences/delete',
        data: preferences.map((pref) => pref.toJson()).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get user preference by category
  Future<List<Preference>> getUserPreferencesByCategory(
    String userId,
    String category,
  ) async {
    try {
      final response = await _dio.get(
        '/api/v4/users/$userId/preferences/$category',
      );
      return (response.data as List)
          .map((prefData) => Preference.fromJson(prefData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get specific user preference
  Future<Preference> getUserPreference(
    String userId,
    String category,
    String name,
  ) async {
    try {
      final response = await _dio.get(
        '/api/v4/users/$userId/preferences/$category/name/$name',
      );
      return Preference.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
