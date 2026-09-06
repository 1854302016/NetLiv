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
}
