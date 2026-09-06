import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../widgets/netliv_logo.dart';
import '../landing/netflix_landing_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _navTimer = Timer(const Duration(milliseconds: 3200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 650),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const NetflixLandingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient Studio Backlight Beam
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final val = _pulseController.value;
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.0, -0.05),
                    radius: 0.75 + (val * 0.25),
                    colors: [
                      AppColors.primary.withOpacity(0.16 + (val * 0.08)),
                      AppColors.surfaceElevated.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),

          // Horizontal Cinematic Lens Flare Beam
          Center(
            child: Container(
              height: 1.5,
              width: size.width * 0.85,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.primaryLight.withOpacity(0.8),
                    Colors.white,
                    AppColors.primaryLight.withOpacity(0.8),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.8),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scaleX(
                  begin: 0.0,
                  end: 1.0,
                  duration: 850.ms,
                  curve: Curves.easeOutQuart,
                )
                .fadeOut(delay: 1100.ms, duration: 600.ms),
          ),

          // Central NetLiv Monogram and Typography
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo with entrance animation
                const NetLivLogo(fontSize: 44)
                    .animate()
                    .scale(
                      begin: const Offset(0.82, 0.82),
                      end: const Offset(1.0, 1.0),
                      duration: 900.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 600.ms)
                    .shimmer(
                      delay: 950.ms,
                      duration: 1100.ms,
                      color: Colors.white38,
                    ),

                const SizedBox(height: 20),

                // Solid Rich Amethyst Line with Subtle Glow
                Container(
                  height: 2.5,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.7),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 400.ms)
                    .scaleX(begin: 0.0, end: 1.0, delay: 600.ms, duration: 600.ms),

                const SizedBox(height: 18),

                // Subtitle: "STUDIO CINEMA STREAMING"
                Text(
                  'STUDIO CINEMA STREAMING',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4.5,
                    color: AppColors.textMuted,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1000.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0.0, duration: 600.ms),
              ],
            ),
          ),

          // Bottom Loading & Version Info
          Positioned(
            bottom: 44,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryLight.withOpacity(0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'ULTRA HD CINEMA SYSTEM',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted.withOpacity(0.8),
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 1300.ms, duration: 500.ms),
          ),
        ],
      ),
    );
  }
}
