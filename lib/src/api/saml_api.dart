import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mattermost_flutter/src/models/saml.dart';

/// API for SAML-related endpoints
class SamlApi {
  final Dio _dio;

  SamlApi(this._dio);

  /// Get SAML metadata
  Future<String> getMetadata() async {
    try {
      final response = await _dio.get('/api/v4/saml/metadata');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload SAML IDP certificate
  Future<void> uploadIdpCertificate(File certificate) async {
    try {
      final formData = FormData.fromMap({
        'certificate': await MultipartFile.fromFile(
          certificate.path,
          filename: certificate.path.split('/').last,
          contentType: MediaType.parse('application/x-pem-file'),
        ),
      });

      await _dio.post(
        '/api/v4/saml/certificate/idp',
        data: formData,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Upload SAML public certificate
  Future<void> uploadPublicCertificate(File certificate) async {
    try {
      final formData = FormData.fromMap({
        'certificate': await MultipartFile.fromFile(
          certificate.path,
          filename: certificate.path.split('/').last,
          contentType: MediaType.parse('application/x-pem-file'),
        ),
      });

      await _dio.post(
        '/api/v4/saml/certificate/public',
        data: formData,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Upload SAML private key
  Future<void> uploadPrivateKey(File key) async {
    try {
      final formData = FormData.fromMap({
        'private_key': await MultipartFile.fromFile(
          key.path,
          filename: key.path.split('/').last,
          contentType: MediaType.parse('application/x-pem-file'),
        ),
      });

      await _dio.post(
        '/api/v4/saml/certificate/private',
        data: formData,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete SAML IDP certificate
  Future<void> deleteIdpCertificate() async {
    try {
      await _dio.delete('/api/v4/saml/certificate/idp');
    } catch (e) {
      rethrow;
    }
  }

  /// Delete SAML public certificate
  Future<void> deletePublicCertificate() async {
    try {
      await _dio.delete('/api/v4/saml/certificate/public');
    } catch (e) {
      rethrow;
    }
  }

  /// Delete SAML private key
  Future<void> deletePrivateKey() async {
    try {
      await _dio.delete('/api/v4/saml/certificate/private');
    } catch (e) {
      rethrow;
    }
  }

  /// Get SAML certificate status
  Future<SamlCertificateStatus> getCertificateStatus() async {
    try {
      final response = await _dio.get('/api/v4/saml/certificate/status');
      return SamlCertificateStatus.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Reset SAML auth data
  Future<void> resetAuthData() async {
    try {
      await _dio.post('/api/v4/saml/reset');
    } catch (e) {
      rethrow;
    }
  }
}
