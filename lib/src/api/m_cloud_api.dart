import 'package:dio/dio.dart';

import '../models/m_cloud.dart';

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
  Future<MCloudCustomer> updateCustomer({
    String? name,
    String? email,
    MCloudCustomerAddress? billingAddress,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (billingAddress != null) data['billing_address'] = billingAddress.toJson();

      final response = await _dio.put(
        '/api/v4/cloud/customer',
        data: data,
      );
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
      final response = await _dio.get(
        '/api/v4/cloud/subscription/invoices/$invoiceId/pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Create customer setup payment intent
  Future<MPaymentSetupIntent> createCustomerPayment() async {
    try {
      final response = await _dio.post('/api/v4/cloud/payment');
      return MPaymentSetupIntent.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Complete the payment setup intent
  Future<void> confirmCustomerPayment({
    required String stripeSetupIntentId,
  }) async {
    try {
      final data = FormData.fromMap({
        'stripe_setup_intent_id': stripeSetupIntentId,
      });
      await _dio.post('/api/v4/cloud/payment/confirm', data: data);
    } catch (e) {
      rethrow;
    }
  }
}
