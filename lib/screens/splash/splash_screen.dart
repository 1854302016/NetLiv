import 'dart:async';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../landing/netflix_landing_screen.dart';

/// Cinematic 3D curved movie poster wall preview screen shown for ~4s on app launch.
/// Faithfully reproduces the user's reference design with 4 curved perspective columns,
/// high-contrast Indian OTT movie titles and artwork, vertical bottom motion blur streaks,
/// ambient crimson theater under-glow, central white/black 'k.' emblem, and glowing red serif 'Download Now'.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  Timer? _navTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Continuous smooth cinematic vertical drift animation
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    // Auto-navigate to NetflixLandingScreen after ~4.2 seconds
    _navTimer = Timer(const Duration(milliseconds: 4200), _navigateToApp);
  }

  void _navigateToApp() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _navTimer?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NetflixLandingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF070203), // Deep obsidian with warm crimson undertone
      body: GestureDetector(
        onTap: _navigateToApp,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ==============================================================
            // 1. 3D CURVED POSTER WALL (4 COLUMNS WITH PERSPECTIVE CURVATURE)
            // ==============================================================
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return _CurvedPosterWall(
                    progress: _animController.value,
                    screenSize: size,
                  );
                },
              ),
            ),

            // ==============================================================
            // 2. BOTTOM VERTICAL MOTION BLUR STREAKS & CRIMSON AMBIENT GLOW
            // ==============================================================
            // Vertical light speed trails (trails dissolve from bottom cards down into black)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: size.height * 0.32,
              child: CustomPaint(
                painter: _BottomLightStreaksPainter(),
              ),
            ),

            // Subtle bottom edge fade (only affects the bottom 20% to dissolve streaks)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: size.height * 0.22,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                    colors: [
                      Colors.transparent,
                      const Color(0xFF070203).withOpacity(0.65),
                      const Color(0xFF070203),
                    ],
                  ),
                ),
              ),
            ),

            // Radiant crimson theater glow at screen base
            Positioned(
              left: -50,
              right: -50,
              bottom: -40,
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, 0.8),
                    radius: 0.85,
                    colors: [
                      const Color(0xFFE50914).withOpacity(0.38),
                      const Color(0xFF990B13).withOpacity(0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Soft radial vignette behind center badge & title to ensure crystal-clear contrast
            Center(
              child: Container(
                width: 360,
                height: 270,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.black.withOpacity(0.88),
                      Colors.black.withOpacity(0.65),
                      Colors.black.withOpacity(0.20),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 0.75, 1.0],
                  ),
                ),
              ),
            ),

            // ==============================================================
            // 3. FOREGROUND CENTRAL APP EMBLEM (ONLY LOGO VISIBLE)
            // ==============================================================
            Center(
              child: _buildCenterLogoBadge(),
            ),

            // ==============================================================
            // 4. TOP SKIP BUTTON
            // ==============================================================
            Positioned(
              top: MediaQuery.of(context).padding.top + 14,
              right: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 0.9,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Skip',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: 10,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterLogoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white,
          width: 3.5,
        ),
        boxShadow: [
          // Crisp ambient dark shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.95),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          // Radiant crimson neon back-glow
          BoxShadow(
            color: const Color(0xFFE50914).withOpacity(0.70),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/logo.png',
        height: 56,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// 3D Curved amphitheater wall of movie posters
class _CurvedPosterWall extends StatelessWidget {
  final double progress;
  final Size screenSize;

  const _CurvedPosterWall({
    required this.progress,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    // 4 Columns matching the exact titles, colors, and art from user reference image:
    // media_1789484330774.png

    // Column 0: Far Left
    const col0Items = [
      _PosterMeta(
        title: 'Kiss My Luck',
        theme: _PosterTheme.romanticStars,
        imageUrl: 'https://images.unsplash.com/photo-1518199266791-5375a83190b7?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFFF4081),
      ),
      _PosterMeta(
        title: 'Second Spark in My Life',
        theme: _PosterTheme.familyWarmth,
        imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFFFD54F),
      ),
      _PosterMeta(
        title: 'Ludhiana to London',
        theme: _PosterTheme.destinationWedding,
        imageUrl: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFF06292),
      ),
      _PosterMeta(
        title: 'Brahmrakshas',
        theme: _PosterTheme.mythicHero,
        imageUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFFF6D00),
      ),
      _PosterMeta(
        title: 'Married to a Mystery',
        theme: _PosterTheme.suspenseRomance,
        imageUrl: 'https://images.unsplash.com/photo-1516589178581-6cd7833ae3b2?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFE91E63),
      ),
      _PosterMeta(
        title: 'Kiss My Luck',
        theme: _PosterTheme.romanticStars,
        imageUrl: 'https://images.unsplash.com/photo-1518199266791-5375a83190b7?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFFF4081),
      ),
      _PosterMeta(
        title: 'Second Spark in My Life',
        theme: _PosterTheme.familyWarmth,
        imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFFFD54F),
      ),
      _PosterMeta(
        title: 'Ludhiana to London',
        theme: _PosterTheme.destinationWedding,
        imageUrl: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFF06292),
      ),
    ];

    // Column 1: Center-Left
    const col1Items = [
      _PosterMeta(
        title: 'Phere at First Sight',
        theme: _PosterTheme.royalWedding,
        imageUrl: 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFFFB300),
      ),
      _PosterMeta(
        title: 'My Magical Man',
        theme: _PosterTheme.magicalFantasy,
        imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFF00E5FF),
      ),
      _PosterMeta(
        title: 'Kerala Police Diary',
        theme: _PosterTheme.copThriller,
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFFF9800),
      ),
      _PosterMeta(
        title: 'Toofani Bodyguard',
        theme: _PosterTheme.actionBodyguard,
        imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFB0BEC5),
      ),
      _PosterMeta(
        title: 'Phere at First Sight',
        theme: _PosterTheme.royalWedding,
        imageUrl: 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFFFB300),
      ),
      _PosterMeta(
        title: 'My Magical Man',
        theme: _PosterTheme.magicalFantasy,
        imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFF00E5FF),
      ),
      _PosterMeta(
        title: 'Kerala Police Diary',
        theme: _PosterTheme.copThriller,
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFFF9800),
      ),
      _PosterMeta(
        title: 'Toofani Bodyguard',
        theme: _PosterTheme.actionBodyguard,
        imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFB0BEC5),
      ),
    ];

    // Column 2: Center-Right
    const col2Items = [
      _PosterMeta(
        title: 'King in Disguise',
        theme: _PosterTheme.royalIntrigue,
        imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFFFD700),
      ),
      _PosterMeta(
        title: 'Fighter Cop',
        theme: _PosterTheme.militaryAction,
        imageUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFF81C784),
      ),
      _PosterMeta(
        title: 'Pilot Tama',
        theme: _PosterTheme.aviationDrama,
        imageUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFFF7043),
      ),
      _PosterMeta(
        title: 'Hidden Talent',
        theme: _PosterTheme.culinaryDrama,
        imageUrl: 'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFEEEEEE),
      ),
      _PosterMeta(
        title: 'King in Disguise',
        theme: _PosterTheme.royalIntrigue,
        imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFFFD700),
      ),
      _PosterMeta(
        title: 'Fighter Cop',
        theme: _PosterTheme.militaryAction,
        imageUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFF81C784),
      ),
      _PosterMeta(
        title: 'Pilot Tama',
        theme: _PosterTheme.aviationDrama,
        imageUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFFF7043),
      ),
      _PosterMeta(
        title: 'Hidden Talent',
        theme: _PosterTheme.culinaryDrama,
        imageUrl: 'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFEEEEEE),
      ),
    ];

    // Column 3: Far Right
    const col3Items = [
      _PosterMeta(
        title: 'War God: Ki Wapsi',
        theme: _PosterTheme.combatWar,
        imageUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFFF3D00),
      ),
      _PosterMeta(
        title: 'Billionaire on Plane',
        theme: _PosterTheme.luxuryCorporate,
        imageUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFFFCA28),
      ),
      _PosterMeta(
        title: 'Billionaire by Pregnancy',
        theme: _PosterTheme.glamRomance,
        imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFEC407A),
      ),
      _PosterMeta(
        title: 'Aakhri Udaan',
        theme: _PosterTheme.flightEmergency,
        imageUrl: 'https://images.unsplash.com/photo-1529070538774-1843cb3265df?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFF4FC3F7),
      ),
      _PosterMeta(
        title: 'The Haunted Honeymoon',
        theme: _PosterTheme.gothicHorror,
        imageUrl: 'https://images.unsplash.com/photo-1509114397022-ed747cca3f65?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFE53935),
      ),
      _PosterMeta(
        title: 'War God: Ki Wapsi',
        theme: _PosterTheme.combatWar,
        imageUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFFF3D00),
      ),
      _PosterMeta(
        title: 'Billionaire on Plane',
        theme: _PosterTheme.luxuryCorporate,
        imageUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFFFCA28),
      ),
      _PosterMeta(
        title: 'Billionaire by Pregnancy',
        theme: _PosterTheme.glamRomance,
        imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=500&auto=format&fit=crop&q=80',
        accentColor: Color(0xFFEC407A),
      ),
    ];

    // Precise column geometry ensuring zero horizontal overlap
    const colGap = 7.0;
    const bleed = 14.0;
    final totalSpan = screenSize.width + (2 * bleed);
    final colWidth = (totalSpan - (3 * colGap)) / 4;

    final col0Left = -bleed;
    final col1Left = col0Left + colWidth + colGap;
    final col2Left = col1Left + colWidth + colGap;
    final col3Left = col2Left + colWidth + colGap;

    const itemHeight = 168.0;
    const cardGap = 8.0;
    const totalStep = itemHeight + cardGap;
    const loopDistance = totalStep * 4; // seamless loop after 4 items

    // Staggered column offsets for authentic interlocking amphitheater look
    final offset0 = (progress * loopDistance) % loopDistance;
    final offset1 = ((progress + 0.35) * loopDistance) % loopDistance;
    final offset2 = ((progress + 0.15) * loopDistance) % loopDistance;
    final offset3 = ((progress + 0.50) * loopDistance) % loopDistance;

    return SizedBox(
      width: screenSize.width,
      height: screenSize.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Column 0: Far Left (Curving inwards to the right, bleeding slightly off-screen)
          Positioned(
            left: col0Left,
            top: -50,
            bottom: -50,
            width: colWidth,
            child: _buildCurvedColumn(
              items: col0Items,
              width: colWidth,
              itemHeight: itemHeight,
              cardGap: cardGap,
              rotationY: 0.18,
              scrollOffset: offset0,
            ),
          ),

          // Column 1: Center-Left (Curving subtly inwards)
          Positioned(
            left: col1Left,
            top: -50,
            bottom: -50,
            width: colWidth,
            child: _buildCurvedColumn(
              items: col1Items,
              width: colWidth,
              itemHeight: itemHeight,
              cardGap: cardGap,
              rotationY: 0.05,
              scrollOffset: offset1,
            ),
          ),

          // Column 2: Center-Right (Curving subtly inwards)
          Positioned(
            left: col2Left,
            top: -50,
            bottom: -50,
            width: colWidth,
            child: _buildCurvedColumn(
              items: col2Items,
              width: colWidth,
              itemHeight: itemHeight,
              cardGap: cardGap,
              rotationY: -0.05,
              scrollOffset: offset2,
            ),
          ),

          // Column 3: Far Right (Curving inwards to the left, bleeding slightly off-screen)
          Positioned(
            left: col3Left,
            top: -50,
            bottom: -50,
            width: colWidth,
            child: _buildCurvedColumn(
              items: col3Items,
              width: colWidth,
              itemHeight: itemHeight,
              cardGap: cardGap,
              rotationY: -0.18,
              scrollOffset: offset3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurvedColumn({
    required List<_PosterMeta> items,
    required double width,
    required double itemHeight,
    required double cardGap,
    required double rotationY,
    required double scrollOffset,
  }) {
    final totalStep = itemHeight + cardGap;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0010) // Cylindrical 3D perspective
        ..rotateY(rotationY),
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(items.length, (index) {
          final meta = items[index];
          final topPos = (index * totalStep) - scrollOffset;

          return Positioned(
            top: topPos,
            left: 0,
            right: 0,
            height: itemHeight,
            child: _MoviePosterCard(meta: meta),
          );
        }),
      ),
    );
  }
}

/// The individual movie poster card with red rim border and custom typography
class _MoviePosterCard extends StatelessWidget {
  final _PosterMeta meta;

  const _MoviePosterCard({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // Signature glowing red/crimson rim border from reference image
        border: Border.all(
          color: const Color(0xFFE50914).withOpacity(0.48),
          width: 1.2,
        ),
        boxShadow: [
          // Red rim back-glow
          BoxShadow(
            color: const Color(0xFFE50914).withOpacity(0.20),
            blurRadius: 6,
            spreadRadius: 0.5,
          ),
          // Deep drop shadow for 3D card separation
          BoxShadow(
            color: Colors.black.withOpacity(0.85),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. High-contrast thematic photo
            CachedNetworkImage(
              imageUrl: meta.imageUrl,
              fit: BoxFit.cover,
              memCacheWidth: 320,
              memCacheHeight: 480,
              placeholder: (context, url) => _buildPosterFallback(),
              errorWidget: (context, url, error) => _buildPosterFallback(),
            ),

            // 2. Cinematic color grade overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.40, 0.70, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.transparent,
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.92),
                  ],
                ),
              ),
            ),

            // 3. Subtle colored top vignette
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 24,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      meta.accentColor.withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 4. Bespoke movie title badge / graphic styled per theme
            Positioned(
              left: 4,
              right: 4,
              bottom: 6,
              child: _buildTitleGraphic(meta),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            meta.accentColor.withOpacity(0.28),
            const Color(0xFF14080B),
            const Color(0xFF070203),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 25,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    meta.accentColor.withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 30,
            child: _buildThemeIcon(meta.theme),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeIcon(_PosterTheme theme) {
    switch (theme) {
      case _PosterTheme.romanticStars:
        return Icon(Icons.auto_awesome, color: meta.accentColor.withOpacity(0.85), size: 34);
      case _PosterTheme.royalWedding:
        return const Icon(Icons.favorite_border_rounded, color: Color(0xFFFFD700), size: 34);
      case _PosterTheme.familyWarmth:
        return const Icon(Icons.groups_rounded, color: Color(0xFFFFD54F), size: 34);
      case _PosterTheme.magicalFantasy:
        return const Icon(Icons.flash_on_rounded, color: Color(0xFF00E5FF), size: 36);
      case _PosterTheme.royalIntrigue:
        return const Icon(Icons.military_tech_rounded, color: Color(0xFFFFD700), size: 34);
      case _PosterTheme.combatWar:
        return const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF3D00), size: 36);
      case _PosterTheme.destinationWedding:
        return const Icon(Icons.flight_takeoff_rounded, color: Color(0xFFF06292), size: 34);
      case _PosterTheme.militaryAction:
        return const Icon(Icons.shield_rounded, color: Color(0xFFA5D6A7), size: 34);
      case _PosterTheme.luxuryCorporate:
        return const Icon(Icons.flight_rounded, color: Color(0xFFFFCA28), size: 34);
      case _PosterTheme.mythicHero:
        return const Icon(Icons.temple_hindu_rounded, color: Color(0xFFFFAB40), size: 34);
      case _PosterTheme.copThriller:
        return const Icon(Icons.local_police_rounded, color: Color(0xFFFFB74D), size: 34);
      case _PosterTheme.actionBodyguard:
        return const Icon(Icons.security_rounded, color: Color(0xFFCFD8DC), size: 34);
      case _PosterTheme.glamRomance:
        return const Icon(Icons.diamond_outlined, color: Color(0xFFEC407A), size: 34);
      case _PosterTheme.flightEmergency:
        return const Icon(Icons.airplanemode_active_rounded, color: Color(0xFF81D4FA), size: 34);
      case _PosterTheme.suspenseRomance:
        return const Icon(Icons.masks_rounded, color: Color(0xFFFF5252), size: 34);
      case _PosterTheme.aviationDrama:
        return Icon(Icons.connecting_airports_rounded, color: Colors.white.withOpacity(0.85), size: 34);
      case _PosterTheme.culinaryDrama:
        return const Icon(Icons.restaurant_rounded, color: Color(0xFFEEEEEE), size: 34);
      case _PosterTheme.gothicHorror:
        return const Icon(Icons.nightlight_round, color: Color(0xFFFF1744), size: 34);
    }
  }

  Widget _buildTitleGraphic(_PosterMeta meta) {
    switch (meta.theme) {
      case _PosterTheme.romanticStars:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, size: 8, color: meta.accentColor),
                const SizedBox(width: 2),
                Text(
                  'KISS MY',
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.star, size: 8, color: meta.accentColor),
              ],
            ),
            Text(
              'Luck',
              style: GoogleFonts.greatVibes(
                fontSize: 18,
                color: meta.accentColor,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: meta.accentColor.withOpacity(0.8), blurRadius: 8),
                ],
              ),
            ),
          ],
        );

      case _PosterTheme.royalWedding:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PHERE',
              style: GoogleFonts.cinzel(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFFD700),
                letterSpacing: 1.5,
                shadows: [
                  Shadow(color: Colors.black.withOpacity(0.9), blurRadius: 4),
                ],
              ),
            ),
            Text(
              'FIRST SIGHT',
              style: GoogleFonts.montserrat(
                fontSize: 7,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        );

      case _PosterTheme.familyWarmth:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD54F).withOpacity(0.92),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'SECOND SPARK\nIN MY LIFE',
            textAlign: TextAlign.center,
            style: GoogleFonts.bebasNeue(
              fontSize: 10,
              letterSpacing: 0.8,
              color: Colors.black,
              height: 1.05,
            ),
          ),
        );

      case _PosterTheme.magicalFantasy:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'MY',
              style: GoogleFonts.orbitron(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: const Color(0xFF00E5FF),
              ),
            ),
            Text(
              'MAGICAL MAN',
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzelDecorative(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  const Shadow(color: Color(0xFF00E5FF), blurRadius: 8),
                ],
              ),
            ),
          ],
        );

      case _PosterTheme.royalIntrigue:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium_rounded, size: 10, color: Color(0xFFFFD700)),
            Text(
              'KING IN DISGUISE',
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFFD700),
                letterSpacing: 0.6,
                shadows: [
                  Shadow(color: Colors.black.withOpacity(0.9), blurRadius: 4),
                ],
              ),
            ),
          ],
        );

      case _PosterTheme.combatWar:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFB71C1C).withOpacity(0.85),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'WAR GOD',
                style: GoogleFonts.bebasNeue(
                  fontSize: 13,
                  letterSpacing: 1.5,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              Text(
                'KI WAPSI',
                style: GoogleFonts.oswald(
                  fontSize: 7,
                  letterSpacing: 1.0,
                  color: const Color(0xFFFFCCBC),
                ),
              ),
            ],
          ),
        );

      case _PosterTheme.destinationWedding:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'LUDHIANA TO LONDON',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        );

      case _PosterTheme.militaryAction:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'FIGHTER COP',
              textAlign: TextAlign.center,
              style: GoogleFonts.blackOpsOne(
                fontSize: 10,
                color: const Color(0xFFA5D6A7),
                letterSpacing: 0.5,
              ),
            ),
          ],
        );

      case _PosterTheme.luxuryCorporate:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          color: Colors.black.withOpacity(0.75),
          child: Text(
            'BILLIONAIRE\nON PLANE',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFFFD54F),
              letterSpacing: 0.8,
              height: 1.1,
            ),
          ),
        );

      case _PosterTheme.mythicHero:
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'BRAHMRAKSHAS',
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFFFAB40),
              letterSpacing: 0.6,
              shadows: [
                const Shadow(color: Color(0xFFFF3D00), blurRadius: 10),
              ],
            ),
          ),
        );

      case _PosterTheme.copThriller:
        return Text(
          'KERALA POLICE DIARY',
          textAlign: TextAlign.center,
          style: GoogleFonts.bebasNeue(
            fontSize: 11,
            letterSpacing: 0.8,
            color: const Color(0xFFFFE082),
          ),
        );

      case _PosterTheme.actionBodyguard:
        return Text(
          'TOOFANI BODYGUARD',
          textAlign: TextAlign.center,
          style: GoogleFonts.orbitron(
            fontSize: 8,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.5,
            shadows: [
              const Shadow(color: Color(0xFFE50914), blurRadius: 6),
            ],
          ),
        );

      case _PosterTheme.glamRomance:
        return Text(
          'Billionaire by Pregnancy',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: const Color(0xFFFF80AB),
          ),
        );

      case _PosterTheme.flightEmergency:
        return Text(
          'AAKHRI UDAAN',
          textAlign: TextAlign.center,
          style: GoogleFonts.teko(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF81D4FA),
            letterSpacing: 1.0,
          ),
        );

      case _PosterTheme.suspenseRomance:
        return Text(
          'MARRIED TO A MYSTERY',
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzel(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFFF5252),
            letterSpacing: 0.5,
          ),
        );

      case _PosterTheme.aviationDrama:
        return Text(
          'PILOT TAMA',
          textAlign: TextAlign.center,
          style: GoogleFonts.bebasNeue(
            fontSize: 12,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        );

      case _PosterTheme.culinaryDrama:
        return Text(
          'HIDDEN TALENT',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        );

      case _PosterTheme.gothicHorror:
        return Text(
          'THE HAUNTED HONEYMOON',
          textAlign: TextAlign.center,
          style: GoogleFonts.creepster(
            fontSize: 11,
            color: const Color(0xFFFF1744),
            letterSpacing: 0.8,
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.9), blurRadius: 6),
            ],
          ),
        );
    }
  }
}

enum _PosterTheme {
  romanticStars,
  royalWedding,
  familyWarmth,
  magicalFantasy,
  royalIntrigue,
  combatWar,
  destinationWedding,
  militaryAction,
  luxuryCorporate,
  mythicHero,
  copThriller,
  actionBodyguard,
  glamRomance,
  flightEmergency,
  suspenseRomance,
  aviationDrama,
  culinaryDrama,
  gothicHorror,
}

class _PosterMeta {
  final String title;
  final _PosterTheme theme;
  final String imageUrl;
  final Color accentColor;

  const _PosterMeta({
    required this.title,
    required this.theme,
    required this.imageUrl,
    required this.accentColor,
  });
}

/// Custom painter for the vertical light streaks / speed-line motion trails
/// matching the signature cinematic bottom dissolve in reference image
class _BottomLightStreaksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Use deterministic seeded random for stable visual rendering
    final random = math.Random(1337);
    const streakCount = 42;

    for (int i = 0; i < streakCount; i++) {
      final x = (w / streakCount) * i + (random.nextDouble() * 8 - 4);
      final streakHeight = h * (0.45 + random.nextDouble() * 0.50);
      final opacity = 0.12 + random.nextDouble() * 0.28;
      final strokeWidth = 1.0 + random.nextDouble() * 2.4;

      final isCrimson = i % 2 == 0;
      final streakColor = isCrimson
          ? const Color(0xFFE50914).withOpacity(opacity)
          : (i % 3 == 0
              ? const Color(0xFFFF7043).withOpacity(opacity * 0.7)
              : Colors.white.withOpacity(opacity * 0.45));

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            streakColor,
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 1.0],
        ).createShader(Rect.fromLTWH(x, h - streakHeight, strokeWidth, streakHeight))
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(x, h - streakHeight),
        Offset(x, h),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
