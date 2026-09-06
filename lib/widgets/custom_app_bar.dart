import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../state/app_state.dart';
import 'netliv_logo.dart';
import 'shimmer_image.dart';

class CustomAppBar extends StatelessWidget {
  final double scrollOffset;
  final VoidCallback? onSearchTap;
  final VoidCallback? onProfileTap;

  const CustomAppBar({
    super.key,
    required this.scrollOffset,
    this.onSearchTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic opacity based on scroll (fully transparent at top, solid dark after 120px)
    final double opacity = (scrollOffset / 110.0).clamp(0.0, 0.94);
    final appState = Provider.of<AppState>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(opacity),
        border: Border(
          bottom: BorderSide(
            color: opacity > 0.4
                ? Colors.white.withOpacity(0.08)
                : Colors.transparent,
            width: 0.8,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        bottom: 10,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: NetLiv Monogram Logo, Cast, Search, Profile Avatar
          Row(
            children: [
              const NetLivLogo(fontSize: 22),
              const Spacer(),
              // Cast button
              IconButton(
                icon: const Icon(Icons.cast_rounded, color: Colors.white, size: 21),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.surfaceElevated,
                      content: Text(
                        'Searching for NetLiv Studio Cast displays...',
                        style: TextStyle(color: Colors.white),
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              // Search button
              IconButton(
                icon: const Icon(Icons.search_rounded, color: Colors.white, size: 23),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (onSearchTap != null) {
                    onSearchTap!();
                  } else {
                    appState.setTabIndex(1);
                  }
                },
              ),
              const SizedBox(width: 4),
              // Profile Avatar with subtle Netflix border
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (onProfileTap != null) {
                    onProfileTap!();
                  } else {
                    appState.setTabIndex(4);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.netflixRed.withOpacity(0.8),
                      width: 1.8,
                    ),
                  ),
                  child: ShimmerImage(
                    imageUrl: appState.activeProfile.avatarUrl,
                    width: 32,
                    height: 32,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Horizontal Category Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildCategoryPill(context, 'All', appState),
                _buildCategoryPill(context, 'TV Shows', appState),
                _buildCategoryPill(context, 'Movies', appState),
                _buildCategoryPill(context, 'Originals', appState),
                _buildCategoryPill(context, 'Categories', appState, isDropdown: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(
    BuildContext context,
    String title,
    AppState appState, {
    bool isDropdown = false,
  }) {
    final bool isSelected = appState.selectedHomeCategory == title;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          if (isDropdown) {
            _showCategoryModal(context, appState);
          } else {
            appState.setSelectedHomeCategory(title);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6.5),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : const Color(0xFF191919),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.white : const Color(0xFF383838),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.black : const Color(0xFFE5E5E5),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 12.5,
                  letterSpacing: -0.2,
                ),
              ),
              if (isDropdown) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: isSelected ? Colors.black : const Color(0xFFE5E5E5),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryModal(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        final categories = [
          'All Genres',
          'Action Blockbusters',
          'Cyberpunk & Futuristic',
          'Crime & Dark Thrillers',
          'Critically Acclaimed Cinema',
          'Documentary Series',
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Select Genre', style: AppTypography.titleMedium),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return ListTile(
                        title: Text(cat, style: AppTypography.bodyLarge),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: AppColors.textMuted),
                        onTap: () {
                          appState.setSelectedHomeCategory(cat);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
