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
