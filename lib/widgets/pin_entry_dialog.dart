import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../state/app_state.dart';

/// Shows a 4-digit PIN prompt and returns true only if the entered PIN
/// matches the parental PIN stored in [AppState].
Future<bool> showPinEntryDialog(
  BuildContext context, {
  String title = 'Enter Parental PIN',
  String message = 'Enter your 4-digit PIN to continue.',
}) async {
  final appState = context.read<AppState>();
  final controller = TextEditingController();
  bool errorShown = false;

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.surfaceElevated,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(title, style: AppTypography.titleMedium),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: AppTypography.bodyMedium),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 8),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.surfaceHighlight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    errorText: errorShown ? 'Incorrect PIN' : null,
                  ),
                  onChanged: (_) {
                    if (errorShown) setState(() => errorShown = false);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text('Cancel', style: AppTypography.chip),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.netflixRed),
                onPressed: () {
                  if (appState.verifyParentalPin(controller.text.trim())) {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(dialogContext, true);
                  } else {
                    HapticFeedback.heavyImpact();
                    setState(() => errorShown = true);
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    },
  );

  return result ?? false;
}
