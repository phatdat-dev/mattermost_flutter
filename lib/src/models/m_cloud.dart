/// Cloud product model
class MCloudProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String pricePerSeat;
  final List<String>? features;

  MCloudProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.pricePerSeat,
    this.features,
  });

  factory MCloudProduct.fromJson(Map<String, dynamic> json) {
    return MCloudProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0.0,
      pricePerSeat: json['price_per_seat'] ?? '',
      features: json['features'] != null ? (json['features'] as List).cast<String>() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'price_per_seat': pricePerSeat,
      if (features != null) 'features': features,
    };
  }
}

/// Cloud subscription model
class MCloudSubscription {
  final String id;
  final String customerId;
  final String productId;
  final int seats;
  final String status;
  final int? createAt;
  final int? startAt;
  final int? endAt;

  MCloudSubscription({
    required this.id,
    required this.customerId,
    required this.productId,
    required this.seats,
    required this.status,
    this.createAt,
    this.startAt,
    this.endAt,
  });

  factory MCloudSubscription.fromJson(Map<String, dynamic> json) {
    return MCloudSubscription(
      id: json['id'] ?? '',
      customerId: json['customer_id'] ?? '',
      productId: json['product_id'] ?? '',
      seats: json['seats'] ?? 0,
      status: json['status'] ?? '',
      createAt: json['create_at'],
      startAt: json['start_at'],
      endAt: json['end_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'product_id': productId,
      'seats': seats,
      'status': status,
      if (createAt != null) 'create_at': createAt,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
    };
  }
}

/// Cloud customer model
class MCloudCustomer {
  final String id;
  final String name;
  final String email;
  final MCloudCustomerAddress? billingAddress;
  final MCloudCustomerPaymentMethod? paymentMethod;
  final int? createAt;

  MCloudCustomer({
    required this.id,
    required this.name,
    required this.email,
    this.billingAddress,
    this.paymentMethod,
    this.createAt,
  });

  factory MCloudCustomer.fromJson(Map<String, dynamic> json) {
    return MCloudCustomer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      billingAddress: json['billing_address'] != null ? MCloudCustomerAddress.fromJson(json['billing_address']) : null,
      paymentMethod: json['payment_method'] != null ? MCloudCustomerPaymentMethod.fromJson(json['payment_method']) : null,
      createAt: json['create_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (billingAddress != null) 'billing_address': billingAddress!.toJson(),
      if (paymentMethod != null) 'payment_method': paymentMethod!.toJson(),
      if (createAt != null) 'create_at': createAt,
    };
  }
}

/// Cloud customer address model
class MCloudCustomerAddress {
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String country;
  final String postalCode;

  MCloudCustomerAddress({
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
  });

  factory MCloudCustomerAddress.fromJson(Map<String, dynamic> json) {
    return MCloudCustomerAddress(
      line1: json['line1'] ?? '',
      line2: json['line2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postal_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line1': line1,
      if (line2 != null) 'line2': line2,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
    };
  }
}

/// Cloud customer payment method model
class MCloudCustomerPaymentMethod {
  final String type;
  final String lastFour;
  final String expMonth;
  final String expYear;
  final String cardBrand;
  final String name;

  MCloudCustomerPaymentMethod({
    required this.type,
    required this.lastFour,
    required this.expMonth,
    required this.expYear,
    required this.cardBrand,
    required this.name,
  });

  factory MCloudCustomerPaymentMethod.fromJson(Map<String, dynamic> json) {
    return MCloudCustomerPaymentMethod(
      type: json['type'] ?? '',
      lastFour: json['last_four'] ?? '',
      expMonth: json['exp_month'] ?? '',
      expYear: json['exp_year'] ?? '',
      cardBrand: json['card_brand'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'last_four': lastFour,
      'exp_month': expMonth,
      'exp_year': expYear,
      'card_brand': cardBrand,
      'name': name,
    };
  }
}

/// Invoice model
class MInvoice {
  final String id;
  final String number;
  final int? createAt;
  final int? total;
  final String? status;
  final String? description;
  final int? periodStart;
  final int? periodEnd;
  final String? currencyCode;

  MInvoice({
    required this.id,
    required this.number,
    this.createAt,
    this.total,
    this.status,
    this.description,
    this.periodStart,
    this.periodEnd,
    this.currencyCode,
  });

  factory MInvoice.fromJson(Map<String, dynamic> json) {
    return MInvoice(
      id: json['id'] ?? '',
      number: json['number'] ?? '',
      createAt: json['create_at'],
      total: json['total'],
      status: json['status'],
      description: json['description'],
      periodStart: json['period_start'],
      periodEnd: json['period_end'],
      currencyCode: json['currency_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      if (createAt != null) 'create_at': createAt,
      if (total != null) 'total': total,
      if (status != null) 'status': status,
      if (description != null) 'description': description,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (currencyCode != null) 'currency_code': currencyCode,
    };
  }
}

/// Payment setup intent model
class MPaymentSetupIntent {
  final String id;
  final String? clientSecret;

  MPaymentSetupIntent({
    required this.id,
    this.clientSecret,
  });

  factory MPaymentSetupIntent.fromJson(Map<String, dynamic> json) {
    return MPaymentSetupIntent(
      id: json['id'] ?? '',
      clientSecret: json['client_secret'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (clientSecret != null) 'client_secret': clientSecret,
    };
  }
}
