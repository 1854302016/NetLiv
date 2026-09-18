import 'package:flutter/material.dart';

enum NotificationType { newEpisode, downloadReady, recommendation, general }

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String timeAgo;
  final String? imageUrl;
  final String? relatedItemId;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.imageUrl,
    this.relatedItemId,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    NotificationType parseType(String? typeStr) {
      switch (typeStr?.toLowerCase()) {
        case 'new_episode':
        case 'newepisode':
          return NotificationType.newEpisode;
        case 'download_ready':
        case 'downloadready':
          return NotificationType.downloadReady;
        case 'recommendation':
          return NotificationType.recommendation;
        default:
          return NotificationType.general;
      }
    }

    return NotificationItem(
      id: json['id']?.toString() ?? '',
      type: parseType(json['type'] as String?),
      title: json['title'] as String? ?? 'Notification',
      message: json['message'] as String? ?? '',
      timeAgo: json['timeAgo'] as String? ?? json['created_at_human'] as String? ?? 'Just now',
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
      relatedItemId: json['relatedItemId']?.toString() ?? json['media_id']?.toString(),
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.newEpisode:
        return Icons.new_releases_rounded;
      case NotificationType.downloadReady:
        return Icons.download_done_rounded;
      case NotificationType.recommendation:
        return Icons.auto_awesome_rounded;
      case NotificationType.general:
        return Icons.notifications_rounded;
    }
  }
}
