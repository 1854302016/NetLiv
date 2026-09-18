import 'package:flutter/material.dart';

class SubscriptionPlan {
  final String id;
  final String name;
  final IconData icon;
  final String price;
  final String resolution;
  final List<String> features;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.icon,
    required this.price,
    required this.resolution,
    required this.features,
    this.isPopular = false,
  });

  static IconData _iconForName(String name) {
    switch (name.toLowerCase()) {
      case 'mobile':
        return Icons.smartphone_rounded;
      case 'basic':
        return Icons.tablet_mac_rounded;
      case 'premium':
        return Icons.tv_rounded;
      default:
        return Icons.play_circle_outline_rounded;
    }
  }

  /// [isPopular] is decided by the caller (e.g. the middle-priced plan),
  /// since the backend doesn't track a "most popular" flag.
  factory SubscriptionPlan.fromJson(Map<String, dynamic> json, {bool isPopular = false}) {
    final allFeatures = List<String>.from(json['features'] as List? ?? []);
    return SubscriptionPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: _iconForName(json['name'] as String),
      price: json['price'] as String,
      resolution: allFeatures.isNotEmpty ? allFeatures.first : '',
      features: allFeatures.length > 1 ? allFeatures.sublist(1) : [],
      isPopular: isPopular,
    );
  }
}
