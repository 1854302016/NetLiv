import 'package:flutter/material.dart';
import '../constants/app_typography.dart';
import '../models/media_item.dart';
import 'poster_card.dart';
import 'top_ten_card.dart';

class ContentRow extends StatelessWidget {
  final String title;
  final List<MediaItem> items;
  final bool isTopTen;
  final bool isLandscape;
  final VoidCallback? onSeeAll;
  final String heroPrefix;

  const ContentRow({
    super.key,
    required this.title,
    required this.items,
    this.isTopTen = false,
    this.isLandscape = false,
    this.onSeeAll,
    this.heroPrefix = 'row',
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final double listHeight = isLandscape
        ? 140.0
        : isTopTen
            ? 195.0
            : 185.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (onSeeAll != null)
                  InkWell(
                    onTap: onSeeAll,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            'See All',
                            style: AppTypography.chip.copyWith(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 10,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Horizontal List
          SizedBox(
            height: listHeight,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                if (isTopTen) {
                  return TopTenCard(
                    item: item,
                    rank: index + 1,
                  );
                }

                return PosterCard(
                  item: item,
                  heroPrefix: '$heroPrefix-$index',
                  isLandscape: isLandscape,
                  width: isLandscape ? 220 : 125,
                  height: isLandscape ? 135 : 185,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
