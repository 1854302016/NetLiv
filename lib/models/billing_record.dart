class BillingRecord {
  final int? id;
  final String invoiceNumber;
  final String date;
  final String dateTime;
  final String planName;
  final String amount;
  final double rawAmount;
  final String currency;
  final String status;
  final String validUntil;
  final String billingCycle;
  final String orderId;
  final String paymentId;
  final String paymentMethod;
  final String customerName;
  final String customerPhone;

  const BillingRecord({
    this.id,
    required this.invoiceNumber,
    required this.date,
    required this.dateTime,
    required this.planName,
    required this.amount,
    this.rawAmount = 0.0,
    this.currency = 'INR',
    required this.status,
    this.validUntil = 'N/A',
    this.billingCycle = 'Monthly',
    this.orderId = 'N/A',
    this.paymentId = 'N/A',
    this.paymentMethod = 'Online Payment',
    this.customerName = '',
    this.customerPhone = '',
  });

  factory BillingRecord.fromJson(Map<String, dynamic> json) {
    return BillingRecord(
      id: json['id'] as int?,
      invoiceNumber: json['invoiceNumber'] as String? ?? 'INV-${DateTime.now().year}-00001',
      date: json['date'] as String? ?? '',
      dateTime: json['dateTime'] as String? ?? (json['date'] as String? ?? ''),
      planName: json['planName'] as String? ?? 'Subscription Plan',
      amount: json['amount'] as String? ?? '',
      rawAmount: (json['rawAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      status: json['status'] as String? ?? 'Paid',
      validUntil: json['validUntil'] as String? ?? 'N/A',
      billingCycle: json['billingCycle'] as String? ?? 'Monthly',
      orderId: json['orderId'] as String? ?? 'N/A',
      paymentId: json['paymentId'] as String? ?? 'N/A',
      paymentMethod: json['paymentMethod'] as String? ?? 'Razorpay Secure',
      customerName: json['customerName'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
    );
  }
}

class PaymentMethodSummary {
  final String type;
  final String? brand;
  final String? last4;

  const PaymentMethodSummary({required this.type, this.brand, this.last4});

  factory PaymentMethodSummary.fromJson(Map<String, dynamic> json) {
    return PaymentMethodSummary(
      type: json['type'] as String? ?? '',
      brand: json['brand'] as String?,
      last4: json['last4'] as String?,
    );
  }

  String get displayTitle {
    if (last4 != null && last4!.isNotEmpty) {
      return '${brand ?? 'Card'} •••• $last4';
    }
    return brand ?? type;
  }
}
