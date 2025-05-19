import 'package:dio/dio.dart';

/// API for LDAP-related endpoints
class LdapApi {
  final Dio _dio;

  LdapApi(this._dio);

  /// Sync LDAP
  Future<void> syncLdap() async {
    try {
      await _dio.post('/api/v4/ldap/sync');
    } catch (e) {
      rethrow;
    }
  }

  /// Test LDAP connection
  Future<bool> testLdapConnection() async {
    try {
      await _dio.post('/api/v4/ldap/test');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Migrate LDAP authentication to email
  Future<void> migrateLdapToEmail() async {
    try {
      await _dio.post('/api/v4/ldap/migrateid');
    } catch (e) {
      rethrow;
    }
  }
}
