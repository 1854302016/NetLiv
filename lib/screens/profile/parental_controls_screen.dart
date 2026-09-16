import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../state/app_state.dart';
import '../../widgets/pin_entry_dialog.dart';

const List<String> kMaturityLevels = [
  'All Maturity Levels',
  'Teen (16+) and under',
  'Kids (13+) only',
];

class ParentalControlsScreen extends StatefulWidget {
  const ParentalControlsScreen({super.key});

  @override
  State<ParentalControlsScreen> createState() => _ParentalControlsScreenState();
}

class _ParentalControlsScreenState extends State<ParentalControlsScreen> {
  bool _unlocked = false;
  bool _checkedLock = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLock());
  }

  Future<void> _checkLock() async {
    final appState = context.read<AppState>();
    if (!appState.hasParentalPin) {
      setState(() {
        _unlocked = true;
        _checkedLock = true;
      });
      return;
    }
    final ok = await showPinEntryDialog(
      context,
      title: 'Unlock Parental Controls',
      message: 'Enter your PIN to view these settings.',
    );
    if (!mounted) return;
    if (!ok) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _unlocked = true;
      _checkedLock = true;
    });
  }

  void _showSetPinSheet(AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SetPinSheet(appState: appState),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (!_checkedLock || !_unlocked) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.netflixRed),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Parental Controls', style: AppTypography.titleLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_person_rounded, color: AppColors.netflixRed, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Enable Parental Controls', style: AppTypography.titleMedium.copyWith(fontSize: 14)),
                      Text(
                        'Require a PIN to leave Kids profiles and restrict maturity ratings.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: appState.parentalControlsEnabled,
                  activeColor: AppColors.netflixRed,
                  onChanged: (val) {
                    if (val && !appState.hasParentalPin) {
                      _showSetPinSheet(appState);
                    } else if (!val) {
                      appState.clearParentalPin();
                    } else {
                      appState.toggleParentalControls(true);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildTile(
            icon: Icons.password_rounded,
            title: appState.hasParentalPin ? 'Change PIN' : 'Set a PIN',
            onTap: () => _showSetPinSheet(appState),
          ),

          const SizedBox(height: 24),
          Text('Maturity Limit', style: AppTypography.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Applies to all non-Kids profiles. Kids profiles always use the strictest limit.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          ...kMaturityLevels.map((level) {
            final isSelected = appState.maturityLimit == level;
            return InkWell(
              onTap: () => appState.setMaturityLimit(level),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: isSelected ? AppColors.netflixRed : AppColors.textMuted,
                    ),
                    const SizedBox(width: 12),
                    Text(level, style: AppTypography.bodyLarge),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTile({required IconData icon, required String title, required VoidCallback onTap}) {
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
            Expanded(child: Text(title, style: AppTypography.titleMedium.copyWith(fontSize: 14))),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _SetPinSheet extends StatefulWidget {
  final AppState appState;
  const _SetPinSheet({required this.appState});

  @override
  State<_SetPinSheet> createState() => _SetPinSheetState();
}

class _SetPinSheetState extends State<_SetPinSheet> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final pin = _pinController.text.trim();
    final confirm = _confirmController.text.trim();
    if (pin.length != 4) {
      setState(() => _error = 'PIN must be exactly 4 digits');
      return;
    }
    if (pin != confirm) {
      setState(() => _error = 'PINs do not match');
      return;
    }
    HapticFeedback.mediumImpact();
    widget.appState.setParentalPin(pin);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set Parental PIN', style: AppTypography.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            style: const TextStyle(color: Colors.white, letterSpacing: 6),
            decoration: InputDecoration(
              labelText: 'New 4-digit PIN',
              labelStyle: const TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surfaceHighlight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          TextField(
            controller: _confirmController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            style: const TextStyle(color: Colors.white, letterSpacing: 6),
            decoration: InputDecoration(
              labelText: 'Confirm PIN',
              labelStyle: const TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surfaceHighlight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              errorText: _error,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.netflixRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save PIN'),
            ),
          ),
        ],
      ),
    );
  }
}
