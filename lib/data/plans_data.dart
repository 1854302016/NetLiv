import 'package:flutter/material.dart';
import '../models/subscription_plan.dart';

class PlansData {
  static const List<SubscriptionPlan> all = [
    SubscriptionPlan(
      id: 'mobile',
      name: 'Mobile',
      icon: Icons.smartphone_rounded,
      price: '₹149',
      resolution: 'Good · 480p',
      features: ['Watch on 1 phone or tablet', 'Downloads on 1 device'],
    ),
    SubscriptionPlan(
      id: 'basic',
      name: 'Basic',
      icon: Icons.tablet_mac_rounded,
      price: '₹199',
      resolution: 'Good · 480p',
      features: ['Watch on 1 device at a time', 'Downloads on 1 device'],
    ),
    SubscriptionPlan(
      id: 'standard',
      name: 'Standard',
      icon: Icons.laptop_mac_rounded,
      price: '₹499',
      resolution: 'Great · 1080p Full HD',
      features: [
        'Watch on 2 devices at a time',
        'Downloads on 2 devices',
        'Full HD available',
      ],
      isPopular: true,
    ),
    SubscriptionPlan(
      id: 'premium',
      name: 'Premium',
      icon: Icons.tv_rounded,
      price: '₹649',
      resolution: 'Best · 4K + HDR',
      features: [
        'Watch on 4 devices at a time',
        'Downloads on 4 devices',
        '4K + HDR available',
        'Spatial audio',
      ],
    ),
  ];

  static SubscriptionPlan byId(String? id) =>
      all.firstWhere((p) => p.id == id, orElse: () => all[2]);
}
