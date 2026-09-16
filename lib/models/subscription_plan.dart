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
}
