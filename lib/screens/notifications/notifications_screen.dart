import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../data/mock_data.dart';
import '../../models/notification_item.dart';
import '../../state/app_state.dart';
import '../../widgets/shimmer_image.dart';
import '../details/content_details_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Color _iconColor(NotificationType type) {
    switch (type) {
      case NotificationType.newEpisode:
        return AppColors.netflixRed;
      case NotificationType.downloadReady:
        return AppColors.accentEmerald;
      case NotificationType.recommendation:
        return AppColors.accentGold;
      case NotificationType.general:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final notifications = MockData.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Notifications', style: AppTypography.titleLarge),
        actions: [
          if (appState.unreadNotificationCount > 0)
            TextButton(
              onPressed: () => appState.markAllNotificationsRead(),
              child: Text(
                'Mark all read',
                style: AppTypography.chip.copyWith(color: AppColors.primaryLight),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_none_rounded,
                      size: 56, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('No notifications yet', style: AppTypography.titleMedium),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: AppColors.borderSubtle, height: 1),
              itemBuilder: (context, index) {
                final item = notifications[index];
                final isUnread = !appState.isNotificationRead(item.id);

                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    appState.markNotificationRead(item.id);
                    if (item.relatedItemId != null) {
                      final related = MockData.allItems
                          .where((m) => m.id == item.relatedItemId)
                          .toList();
                      if (related.isNotEmpty) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ContentDetailsScreen(item: related.first),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    color: isUnread ? AppColors.surfaceElevated.withOpacity(0.4) : null,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _iconColor(item.type).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon, color: _iconColor(item.type), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: AppTypography.titleMedium.copyWith(fontSize: 14),
                                    ),
                                  ),
                                  if (isUnread)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.netflixRed,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.message,
                                style: AppTypography.bodyMedium.copyWith(height: 1.4),
                              ),
                              const SizedBox(height: 6),
                              Text(item.timeAgo, style: AppTypography.bodySmall),
                            ],
                          ),
                        ),
                        if (item.imageUrl != null) ...[
                          const SizedBox(width: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: ShimmerImage(
                              imageUrl: item.imageUrl!,
                              width: 64,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
