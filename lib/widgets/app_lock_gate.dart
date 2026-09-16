import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../state/app_state.dart';

/// Wraps [child] with a full-screen PIN lock that appears the first time the
/// gate mounts (fresh session) and again whenever the app returns to the
/// foreground after being backgrounded, whenever App Lock is enabled.
class AppLockGate extends StatefulWidget {
  final Widget child;
  const AppLockGate({super.key, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  bool _locked = false;
  bool _wasBackgrounded = false;
  bool _initialCheckDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      if (appState.appLockEnabled && appState.hasAppLockPin) {
        setState(() => _locked = true);
      }
      _initialCheckDone = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_initialCheckDone) return;
    final appState = context.read<AppState>();
    final lockActive = appState.appLockEnabled && appState.hasAppLockPin;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _wasBackgrounded = true;
    } else if (state == AppLifecycleState.resumed && _wasBackgrounded && lockActive) {
      _wasBackgrounded = false;
      setState(() => _locked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_locked)
          _AppLockScreenOverlay(onUnlocked: () => setState(() => _locked = false)),
      ],
    );
  }
}

class _AppLockScreenOverlay extends StatefulWidget {
  final VoidCallback onUnlocked;
  const _AppLockScreenOverlay({required this.onUnlocked});

  @override
  State<_AppLockScreenOverlay> createState() => _AppLockScreenOverlayState();
}

class _AppLockScreenOverlayState extends State<_AppLockScreenOverlay> {
  final TextEditingController _pinController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _submit(AppState appState) {
    if (appState.verifyAppLockPin(_pinController.text.trim())) {
      HapticFeedback.mediumImpact();
      widget.onUnlocked();
    } else {
      HapticFeedback.heavyImpact();
      setState(() => _error = 'Incorrect PIN');
      _pinController.clear();
    }
  }

  void _simulateBiometric(AppState appState) {
    HapticFeedback.mediumImpact();
    widget.onUnlocked();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();

    return Positioned.fill(
      child: Material(
        color: Colors.black,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_rounded, color: AppColors.netflixRed, size: 48),
                const SizedBox(height: 16),
                Text(
                  'NetLiv Locked',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter your PIN to continue',
                  style: GoogleFonts.inter(color: const Color(0xFFB3B3B3), fontSize: 14),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _pinController,
                  obscureText: true,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 10),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onSubmitted: (_) => _submit(appState),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    errorText: _error,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _submit(appState),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.netflixRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Unlock'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => _simulateBiometric(appState),
                  icon: const Icon(Icons.fingerprint_rounded, color: Colors.white70),
                  label: const Text(
                    'Use Biometric Unlock',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
