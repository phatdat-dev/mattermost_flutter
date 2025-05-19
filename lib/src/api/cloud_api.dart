import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/cloud.dart';

/// API for cloud-related endpoints
class CloudApi {
  final Dio _dio;

  CloudApi(this._dio);

  /// Get cloud products
  Future<List<CloudProduct>> getProducts() async {
    try {
      final response = await _dio.get('/api/v4/cloud/products');
      return (response.data as List)
          .map((product) => CloudProduct.fromJson(product))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get cloud subscription
  Future<CloudSubscription> getSubscription() async {
    try {
      final response = await _dio.get('/api/v4/cloud/subscription');
      return CloudSubscription.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get cloud customer
  Future<CloudCustomer> getCustomer() async {
    try {
      final response = await _dio.get('/api/v4/cloud/customer');
      return CloudCustomer.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update cloud customer
  Future<CloudCustomer> updateCustomer(UpdateCloudCustomerRequest request) async {
    try {
      final response = await _dio.put(
        '/api/v4/cloud/customer',
        data: request.toJson(),
      );
      return CloudCustomer.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get invoices
  Future<List<Invoice>> getInvoices() async {
    try {
      final response = await _dio.get('/api/v4/cloud/subscription/invoices');
      return (response.data as List)
          .map((invoice) => Invoice.fromJson(invoice))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get invoice as PDF
  Future<List<int>> getInvoicePdf(String invoiceId) async {
    try {
      final response = await _dio.get(
        '/api/v4/cloud/subscription/invoices/$invoiceId/pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Create customer payment method
  Future<void> createCustomerPaymentMethod(
    CreatePaymentMethodRequest request,
  ) async {
    try {
      await _dio.post(
        '/api/v4/cloud/payment',
        data: request.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Confirm payment method
  Future<void> confirmPaymentMethod(ConfirmPaymentMethodRequest request) async {
    try {
      await _dio.post(
        '/api/v4/cloud/payment/confirm',
        data: request.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
