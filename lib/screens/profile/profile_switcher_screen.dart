import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../models/user_profile.dart';
import '../../state/app_state.dart';
import '../../widgets/pin_entry_dialog.dart';
import '../../widgets/shimmer_image.dart';

const List<String> kPresetAvatars = [
  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop&q=80',
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop&q=80',
  'https://images.unsplash.com/photo-1566492031773-4f4e44671857?w=200&auto=format&fit=crop&q=80',
  'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200&auto=format&fit=crop&q=80',
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop&q=80',
  'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?w=200&auto=format&fit=crop&q=80',
  'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop&q=80',
  'https://images.unsplash.com/photo-1607346256330-dee7af15f7c5?w=200&auto=format&fit=crop&q=80',
];

class ProfileSwitcherScreen extends StatefulWidget {
  const ProfileSwitcherScreen({super.key});

  @override
  State<ProfileSwitcherScreen> createState() => _ProfileSwitcherScreenState();
}

class _ProfileSwitcherScreenState extends State<ProfileSwitcherScreen> {
  bool _isManaging = false;

  Future<void> _selectProfile(BuildContext context, AppState appState, UserProfile profile) async {
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
    if (context.mounted) Navigator.of(context).pop();
  }

  void _openProfileEditor(BuildContext context, AppState appState, {UserProfile? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _ProfileEditorSheet(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final profiles = appState.profiles;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Who's Watching?", style: AppTypography.displayMedium),
                ],
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  ...profiles.map(
                    (profile) => _ProfileAvatarTile(
                      profile: profile,
                      isManaging: _isManaging,
                      isActive: profile.id == appState.activeProfile.id,
                      onTap: () => _isManaging
                          ? _openProfileEditor(context, appState, existing: profile)
                          : _selectProfile(context, appState, profile),
                    ),
                  ),
                  if (profiles.length < 5)
                    _AddProfileTile(onTap: () => _openProfileEditor(context, appState)),
                ],
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () => setState(() => _isManaging = !_isManaging),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF555555)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(
                  _isManaging ? 'Done' : 'Manage Profiles',
                  style: AppTypography.button.copyWith(letterSpacing: 1.0),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatarTile extends StatelessWidget {
  final UserProfile profile;
  final bool isManaging;
  final bool isActive;
  final VoidCallback onTap;

  const _ProfileAvatarTile({
    required this.profile,
    required this.isManaging,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isActive ? AppColors.netflixRed : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: Opacity(
                    opacity: isManaging ? 0.5 : 1.0,
                    child: ShimmerImage(
                      imageUrl: profile.avatarUrl,
                      width: 80,
                      height: 80,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (profile.isKids)
                  Positioned(
                    bottom: -4,
                    left: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'KIDS',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                if (isManaging)
                  const Positioned.fill(
                    child: Center(
                      child: Icon(Icons.edit_rounded, color: Colors.white, size: 28),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              profile.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium.copyWith(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddProfileTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddProfileTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.surfaceElevated,
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 10),
            Text('Add Profile',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ProfileEditorSheet extends StatefulWidget {
  final UserProfile? existing;
  const _ProfileEditorSheet({this.existing});

  @override
  State<_ProfileEditorSheet> createState() => _ProfileEditorSheetState();
}

class _ProfileEditorSheetState extends State<_ProfileEditorSheet> {
  late final TextEditingController _nameController;
  late String _selectedAvatar;
  late bool _isKids;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _selectedAvatar = widget.existing?.avatarUrl ?? kPresetAvatars.first;
    _isKids = widget.existing?.isKids ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _isSaving = false;

  Future<void> _save(AppState appState) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a profile name')),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);
    try {
      if (widget.existing != null) {
        await appState.updateProfile(
          UserProfile(
            id: widget.existing!.id,
            name: name,
            avatarUrl: _selectedAvatar,
            isKids: _isKids,
            themeColor: widget.existing!.themeColor,
          ),
        );
      } else {
        await appState.addProfile(
          UserProfile(
            id: 'p-${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            avatarUrl: _selectedAvatar,
            isKids: _isKids,
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't save this profile. Please try again.")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete(AppState appState) async {
    setState(() => _isSaving = true);
    try {
      final removed = await appState.removeProfile(widget.existing!.id);
      if (!removed) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('At least one profile must remain')),
        );
        return;
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't delete this profile. Please try again.")),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final isEditing = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isEditing ? 'Edit Profile' : 'Add Profile',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Profile Name',
                labelStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceHighlight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Choose an avatar', style: AppTypography.bodyMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: kPresetAvatars.map((url) {
                final isSelected = url == _selectedAvatar;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedAvatar = url);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.netflixRed : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: ShimmerImage(
                      imageUrl: url,
                      width: 56,
                      height: 56,
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.child_care_rounded, color: AppColors.accentGold, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Kids Profile', style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                ),
                Switch.adaptive(
                  value: _isKids,
                  activeColor: AppColors.accentGold,
                  onChanged: (val) => setState(() => _isKids = val),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : () => _save(appState),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.netflixRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(isEditing ? 'Save Changes' : 'Add Profile', style: AppTypography.button),
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => _delete(appState),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Delete Profile'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
