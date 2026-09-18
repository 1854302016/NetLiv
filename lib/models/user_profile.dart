import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isKids;
  final Color themeColor;

  const UserProfile({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.isKids = false,
    this.themeColor = const Color(0xFF8B5CF6),
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
      isKids: json['isKids'] as bool? ?? false,
      themeColor: _parseHexColor(json['themeColor'] as String?),
    );
  }

  static Color _parseHexColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF8B5CF6);
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}
