import 'package:flutter/material.dart';
import '../models/subscription_plan.dart';

class PlansData {
  static const List<SubscriptionPlan> all = [
    SubscriptionPlan(
      id: 'all_access',
      name: 'NetLiv VIP All-Access',
      icon: Icons.movie_filter_rounded,
      price: '₹49',
      resolution: 'Best · 4K Ultra HD + Dolby Atmos',
      features: [
        'Watch on Mobile, TV, Laptop & Tablet',
        'Unlimited Movies, Web Series & Auditions',
        '4K Ultra HD + Dolby Atmos audio',
        'Cancel anytime — No commitment',
      ],
      isPopular: true,
    ),
  ];

  static SubscriptionPlan byId(String? id) => all.first;
}
