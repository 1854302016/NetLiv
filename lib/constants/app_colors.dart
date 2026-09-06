import 'package:flutter/material.dart';

/// NetLiv Luxury Cinema Design System Palette.
/// Authentic Netflix Color Identity.
/// OLED Blacks paired with Official Netflix Red (#E50914) and Dark Charcoal surfaces.
class AppColors {
  // Deep Cinematic Darkness (Pure OLED & Netflix Dark Slate)
  static const Color background = Color(0xFF000000);
  static const Color backgroundSecondary = Color(0xFF121212);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceElevated = Color(0xFF1F1F1F);
  static const Color surfaceHighlight = Color(0xFF2B2B2B);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFF1F1F1F);
  static const Color border = Color(0xFF2E2E2E);
  static const Color borderFocus = Color(0xFFE50914);

  // Single Signature Brand Accent: Official Netflix Red
  static const Color primary = Color(0xFFE50914); // Netflix Signature Red
  static const Color primaryLight = Color(0xFFF40612); // Vibrant Red
  static const Color primaryDark = Color(0xFFB81D24); // Dark Red
  static const Color secondary = Color(0xFFFFFFFF); // Crisp White Secondary

  // Netflix Signature Brand Color (for OG Landing & Sign In)
  static const Color netflixRed = Color(0xFFE50914);
  static const Color netflixRedDark = Color(0xFFB81D24);
  static const Color netflixRedHover = Color(0xFFC11119);

  // Netflix Landing Surface & FAQ Palettes
  static const Color faqTile = Color(0xFF2D2D2D);
  static const Color faqTileHover = Color(0xFF3D3D3D);
  static const Color netflixDarkInput = Color(0xD9161616);
  static const Color netflixInputBorder = Color(0xFF5E5E5E);

  // Complementary Rich Solid Accents (clean & restrained)
  static const Color accentCrimson = Color(0xFFE50914); // For live/hot badge
  static const Color accentEmerald = Color(0xFF46D369); // Netflix Match % Green
  static const Color accentGold = Color(0xFFF59E0B); // For awards / rating stars
  static const Color success = accentEmerald;
  static const Color error = netflixRed;

  // Typography Palette
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA3A3A3);
  static const Color textMuted = Color(0xFF737373);

  // Glassmorphic / Translucent Overlays
  static const Color glassBackground = Color(0xF2121212);
  static const Color glassBorder = Color(0x26FFFFFF);

  // Refined Cinematic Gradients (Solid, Deep & Atmospheric)
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFFE50914), Color(0xFFB81D24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient primaryGradient = brandGradient;

  static const LinearGradient heroOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.4, 0.75, 1.0],
    colors: [
      Colors.transparent,
      Color(0x3307070A),
      Color(0xD907070A),
      Color(0xFF07070A),
    ],
  );

  static const LinearGradient cardOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.4, 1.0],
    colors: [
      Colors.transparent,
      Color(0xF207070A),
    ],
  );

  static const LinearGradient glassCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x28FFFFFF),
      Color(0x0AFFFFFF),
    ],
  );

  // Netflix Landing "More reasons to join" Gradient (matches Image 2)
  static const LinearGradient reasonCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF191334),
      Color(0xFF110E23),
    ],
  );

  // Netflix Arc Separator Neon Glow
  static const LinearGradient arcGradient = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0xFFE50914),
      Color(0xFFE50914),
      Colors.transparent,
    ],
    stops: [0.0, 0.25, 0.75, 1.0],
  );

  // Radial Ambient Light for Hero / Cards
  static RadialGradient ambientGlow(Color color, {double opacity = 0.25}) {
    return RadialGradient(
      colors: [
        color.withOpacity(opacity),
        Colors.transparent,
      ],
      stops: const [0.0, 1.0],
    );
  }
}
