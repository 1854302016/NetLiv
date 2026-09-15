import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// NetLiv signature logo displaying the official NetLiv TV 'logo.png'.
class NetLivLogo extends StatelessWidget {
  final double? height;
  final double fontSize;
  final bool showTagline;

  const NetLivLogo({
    super.key,
    this.height,
    this.fontSize = 24,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? (fontSize * 1.35);

    final imageWidget = Image.asset(
      'assets/images/logo.png',
      height: effectiveHeight,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NET',
              style: GoogleFonts.syne(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                color: Colors.white,
              ),
            ),
            Text(
              'LIV',
              style: GoogleFonts.syne(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: AppColors.netflixRed,
              ),
            ),
          ],
        );
      },
    );

    if (!showTagline) return imageWidget;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        imageWidget,
        const SizedBox(height: 4),
        Text(
          'POCKET ME CINEMA',
          style: GoogleFonts.inter(
            fontSize: effectiveHeight * 0.28,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.0,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
