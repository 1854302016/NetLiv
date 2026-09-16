import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../data/plans_data.dart';
import '../../models/user_profile.dart';
import '../../state/app_state.dart';
import '../../widgets/pin_entry_dialog.dart';
import '../../widgets/shimmer_image.dart';
import '../landing/netflix_landing_screen.dart';
import 'account_billing_screen.dart';
import 'app_lock_screen.dart';
import 'parental_controls_screen.dart';
import 'profile_switcher_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final activeProfile = appState.activeProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Profiles & More', style: AppTypography.titleLarge),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Who's Watching?" Profile Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Who's Watching?", style: AppTypography.titleMedium),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ProfileSwitcherScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Manage',
                          style: AppTypography.chip.copyWith(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: appState.profiles.length + 1,
                      separatorBuilder: (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        if (index == appState.profiles.length) {
                          return _buildAddProfileButton(context);
                        }
                        final profile = appState.profiles[index];
                        final isCurrent = profile.id == activeProfile.id;
                        return _buildProfileItem(context, profile, isCurrent, appState);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, thickness: 1),

            // Settings List Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preferences', style: AppTypography.bodySmall),
                  const SizedBox(height: 8),

                  _buildSettingSwitch(
                    icon: Icons.play_circle_filled_rounded,
                    title: 'Autoplay Next Episode',
                    subtitle: 'Play next episode automatically when finished',
                    value: appState.autoplayPreviews,
                    onChanged: (val) => appState.toggleAutoplayPreviews(val),
                  ),

                  _buildSettingSwitch(
                    icon: Icons.video_library_rounded,
                    title: 'Autoplay Video Previews',
                    subtitle: 'Preview videos with sound while browsing',
                    value: appState.autoplayPreviews,
                    onChanged: (val) => appState.toggleAutoplayPreviews(val),
                  ),

                  _buildSettingSwitch(
                    icon: Icons.notifications_active_rounded,
                    title: 'Notifications',
                    subtitle: 'Recommendations, new releases and downloads',
                    value: appState.notificationsEnabled,
                    onChanged: (val) => appState.toggleNotifications(val),
                  ),

                  _buildSettingSwitch(
                    icon: Icons.wifi_rounded,
                    title: 'Wi-Fi Only Streaming',
                    subtitle: 'Save cellular mobile data when outside',
                    value: appState.wifiOnly,
                    onChanged: (val) => appState.toggleWifiOnly(val),
                  ),

                  _buildSettingTile(
                    icon: Icons.high_quality_rounded,
                    title: 'Video Quality',
                    trailingText: appState.videoQuality,
                    onTap: () => _showQualityPicker(context, appState),
                  ),

                  _buildSettingTile(
                    icon: Icons.download_for_offline_rounded,
                    title: 'Smart Downloads Settings',
                    trailingText: appState.smartDownloads ? 'Enabled' : 'Disabled',
                    onTap: () {
                      appState.toggleSmartDownloads(!appState.smartDownloads);
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, thickness: 1),

            // Account & Support Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account & Legal', style: AppTypography.bodySmall),
                  const SizedBox(height: 8),

                  _buildSettingTile(
                    icon: Icons.manage_accounts_rounded,
                    title: 'Account & Plan',
                    trailingText: PlansData.byId(appState.selectedPlanId).name,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AccountBillingScreen(),
                        ),
                      );
                    },
                  ),

                  _buildSettingTile(
                    icon: Icons.lock_rounded,
                    title: 'App Lock',
                    trailingText: appState.appLockEnabled ? 'Enabled' : 'Off',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AppLockScreen(),
                        ),
                      );
                    },
                  ),

                  _buildSettingTile(
                    icon: Icons.devices_rounded,
                    title: 'Manage Registered Devices',
                    trailingText: '3 Devices Active',
                    onTap: () {},
                  ),

                  _buildSettingTile(
                    icon: Icons.lock_person_rounded,
                    title: 'Parental Controls & PIN',
                    trailingText: appState.parentalControlsEnabled ? 'Enabled' : 'Off',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ParentalControlsScreen(),
                        ),
                      );
                    },
                  ),

                  _buildSettingTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help Center & Support',
                    onTap: () {},
                  ),

                  _buildSettingTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy & Terms',
                    onTap: () {},
                  ),
                  _buildSettingTile(
                    icon: Icons.web_rounded,
                    title: 'View Netflix Landing Page',
                    trailingText: 'Showcase',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NetflixLandingScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmSignOut(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: Text(
                        'Sign Out of NetLiv',
                        style: AppTypography.button.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // NetLiv Version Info
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'NetLiv App v1.0.0 (Build 2026.09)',
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Stream Beyond • Ultra HD Cinema',
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectProfile(
    BuildContext context,
    AppState appState,
    UserProfile profile,
  ) async {
    final leavingKids = appState.isKidsModeActive && !profile.isKids;
    if (leavingKids && appState.parentalControlsEnabled && appState.hasParentalPin) {
      final ok = await showPinEntryDialog(
        context,
        title: 'Parental PIN Required',
        message: 'Enter your PIN to leave Kids Mode.',
      );
      if (!ok) return;
    }
    HapticFeedback.selectionClick();
    appState.setActiveProfile(profile);
  }

  Widget _buildProfileItem(
    BuildContext context,
    UserProfile profile,
    bool isCurrent,
    AppState appState,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectProfile(context, appState, profile),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrent ? AppColors.netflixRed : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: ShimmerImage(
              imageUrl: profile.avatarUrl,
              width: 58,
              height: 58,
              borderRadius: BorderRadius.circular(29),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profile.name,
            style: AppTypography.chip.copyWith(
              color: isCurrent ? Colors.white : AppColors.textSecondary,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddProfileButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProfileSwitcherScreen()),
        );
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceElevated,
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text('Add Profile',
              style: AppTypography.chip.copyWith(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryLight, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                Text(subtitle,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primaryLight, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: AppTypography.titleMedium.copyWith(fontSize: 14)),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: AppTypography.chip.copyWith(
                  color: AppColors.primaryLight,
                  fontSize: 12,
                ),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  void _showQualityPicker(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final options = [
          'Ultra HD (4K & Dolby Vision)',
          'High Definition (1080p)',
          'Standard (720p - Data Saver)',
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Select Video Playback Quality',
                    style: AppTypography.titleMedium),
                const SizedBox(height: 12),
                ...options.map((opt) {
                  final isSelected = appState.videoQuality == opt;
                  return ListTile(
                    title: Text(opt, style: AppTypography.bodyMedium),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.primaryLight)
                        : null,
                    onTap: () {
                      appState.setVideoQuality(opt);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Sign Out of NetLiv?', style: AppTypography.titleMedium),
        content: Text(
          'You will need to sign in again to access downloads and personal watchlists.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTypography.chip),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const NetflixLandingScreen()),
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
