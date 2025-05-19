import 'package:dio/dio.dart';
import 'package:mattermost_flutter/src/models/m_cloud.dart';

/// API for cloud-related endpoints
class MCloudApi {
  final Dio _dio;

  MCloudApi(this._dio);

  /// Get cloud products
  Future<List<MCloudProduct>> getProducts() async {
    try {
      final response = await _dio.get('/api/v4/cloud/products');
      return (response.data as List).map((product) => MCloudProduct.fromJson(product)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get cloud subscription
  Future<MCloudSubscription> getSubscription() async {
    try {
      final response = await _dio.get('/api/v4/cloud/subscription');
      return MCloudSubscription.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get cloud customer
  Future<MCloudCustomer> getCustomer() async {
    try {
      final response = await _dio.get('/api/v4/cloud/customer');
      return MCloudCustomer.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update cloud customer
  Future<MCloudCustomer> updateCustomer(MUpdateCloudCustomerRequest request) async {
    try {
      final response = await _dio.put('/api/v4/cloud/customer', data: request.toJson());
      return MCloudCustomer.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get invoices
  Future<List<MInvoice>> getInvoices() async {
    try {
      final response = await _dio.get('/api/v4/cloud/subscription/invoices');
      return (response.data as List).map((invoice) => MInvoice.fromJson(invoice)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get invoice as PDF
  Future<List<int>> getInvoicePdf(String invoiceId) async {
    try {
      final response = await _dio.get('/api/v4/cloud/subscription/invoices/$invoiceId/pdf', options: Options(responseType: ResponseType.bytes));
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Create customer payment method
  Future<void> createCustomerPaymentMethod(MCreatePaymentMethodRequest request) async {
    try {
      await _dio.post('/api/v4/cloud/payment', data: request.toJson());
    } catch (e) {
      rethrow;
    }
  }

  /// Confirm payment method
  Future<void> confirmPaymentMethod(MConfirmPaymentMethodRequest request) async {
    try {
      await _dio.post('/api/v4/cloud/payment/confirm', data: request.toJson());
    } catch (e) {
      rethrow;
    }
  }
}
