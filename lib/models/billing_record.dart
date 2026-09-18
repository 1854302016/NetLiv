class BillingRecord {
  final String date;
  final String planName;
  final String amount;
  final String status;

  const BillingRecord({
    required this.date,
    required this.planName,
    required this.amount,
    required this.status,
  });

  factory BillingRecord.fromJson(Map<String, dynamic> json) {
    return BillingRecord(
      date: json['date'] as String? ?? '',
      planName: json['planName'] as String? ?? 'Plan',
      amount: json['amount'] as String? ?? '',
      status: json['status'] as String? ?? '',
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
