import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../data/mock_data.dart';
import '../../services/api_service.dart';
import '../../state/app_state.dart';
import '../main_navigation_screen.dart';
import 'otp_verification_screen.dart';
import 'profile_setup_screen.dart';

/// Ultra-Modern, Signature NetLiv Login Screen matching netlivtv.com/login.
/// Features infinite 4-column animated moving poster collage in background,
/// frosted glassmorphic login card with backdrop blur, +91 country badge, and glowing CTA.
class LoginScreen extends StatefulWidget {
  final String? initialPhoneNumber;
  const LoginScreen({super.key, this.initialPhoneNumber});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  bool _isHelpExpanded = false;
  bool _isSubmitting = false;
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'हिन्दी', 'ਪੰਜਾਬੀ', 'भोजपुरी', 'Español'];

  @override
  void initState() {
    super.initState();
    if (widget.initialPhoneNumber != null && widget.initialPhoneNumber!.isNotEmpty) {
      _inputController.text = widget.initialPhoneNumber!;
    }
    _inputController.addListener(() => setState(() {}));
    _inputFocusNode.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      if (appState.isLoggedIn && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => appState.isProfileComplete
                ? const MainNavigationScreen()
                : const ProfileSetupScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  /// Skips straight to the app as a guest, without going through OTP login.
  void _skipToHome() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
    );
  }

  Future<void> _requestOtpAndProceed() async {
    final phone = _inputController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF222222),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: const [
              Icon(Icons.error_outline_rounded, color: AppColors.netflixRed, size: 20),
              SizedBox(width: 10),
              Text('Please enter a valid 10-digit mobile number', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final debugOtp = await context.read<AppState>().requestOtp(phone);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) =>
              OtpVerificationScreen(mobileNumber: phone, debugOtp: debugOtp),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: child,
            );
          },
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF222222),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Text(e.message, style: const TextStyle(color: Colors.white)),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF222222),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: const Text("Couldn't reach the server. Please try again.", style: TextStyle(color: Colors.white)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<AppState>().catalog;
    final posterUrls = catalog.isNotEmpty
        ? catalog.map((m) => m.posterUrl).where((u) => u.isNotEmpty).toList()
        : MockData.allItems.map((m) => m.posterUrl).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF050507),
      body: Stack(
        children: [
          // 1. NetLiv Signature Infinite Moving Multi-Column Collage (Background)
          Positioned.fill(
            child: Opacity(
              opacity: 0.68,
              child: _NetLivAnimatedCollage(posterUrls: posterUrls),
            ),
          ),

          // 2. NetLiv Dark Vignette & Radiant Crimson Spotlight
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.40, 0.75, 1.0],
                  colors: [
                    const Color(0xFF050507).withOpacity(0.45),
                    const Color(0xFF050507).withOpacity(0.72),
                    const Color(0xFF050507).withOpacity(0.92),
                    const Color(0xFF050507),
                  ],
                ),
              ),
            ),
          ),

          // Radial subtle glow in center
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.1),
                  radius: 0.85,
                  colors: [
                    const Color(0xFFFF2F5F).withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Foreground Content with Glassmorphic Card
          SafeArea(
            child: Column(
              children: [
                // Top Header: Logo & Back Button & Skip Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (Navigator.of(context).canPop()) ...[
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: const Icon(Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white, size: 15),
                              ),
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).pop();
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                          Image.asset(
                            'assets/images/logo.png',
                            height: 36,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      // Skip to Guest shortcut (Modern glass pill)
                      InkWell(
                        onTap: _skipToHome,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6.5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.60),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Skip to Browse',
                                style: GoogleFonts.inter(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right_rounded,
                                  color: Colors.white.withOpacity(0.9), size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Center Scrollable Glassmorphic Card
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // Frosted Glassmorphism Panel (matching .netliv-login-panel)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF111118).withOpacity(0.76),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.14),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.6),
                                    blurRadius: 36,
                                    offset: const Offset(0, 16),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFFFF2F5F).withOpacity(0.08),
                                    blurRadius: 30,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Headline
                                  Text(
                                    'Enter your info to sign in',
                                    style: GoogleFonts.inter(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -0.4,
                                      height: 1.18,
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(duration: 450.ms)
                                      .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
                                  const SizedBox(height: 8),

                                  // Subtitle
                                  Text(
                                    'Or get started with a new account.',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: const Color(0xFFB0B0B8),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(duration: 450.ms, delay: 100.ms),

                                  const SizedBox(height: 26),

                                  // Modern Glassmorphic Phone Input Field
                                  Container(
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1B1B26).withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _inputFocusNode.hasFocus
                                            ? AppColors.netflixRed
                                            : Colors.white.withOpacity(0.14),
                                        width: _inputFocusNode.hasFocus ? 1.5 : 1,
                                      ),
                                      boxShadow: _inputFocusNode.hasFocus
                                          ? [
                                              BoxShadow(
                                                color: AppColors.netflixRed.withOpacity(0.3),
                                                blurRadius: 14,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    child: Row(
                                      children: [
                                        // Country Code Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text('🇮🇳', style: TextStyle(fontSize: 15)),
                                              const SizedBox(width: 5),
                                              Text(
                                                '+91',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          width: 1,
                                          height: 22,
                                          color: Colors.white.withOpacity(0.14),
                                        ),
                                        const SizedBox(width: 12),

                                        // Input Text Field
                                        Expanded(
                                          child: TextField(
                                            controller: _inputController,
                                            focusNode: _inputFocusNode,
                                            keyboardType: TextInputType.phone,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                              LengthLimitingTextInputFormatter(10),
                                            ],
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.2,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Mobile number',
                                              hintStyle: GoogleFonts.inter(
                                                color: const Color(0xFF757582),
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal,
                                                letterSpacing: 0,
                                              ),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                              isDense: true,
                                            ),
                                          ),
                                        ),

                                        // Clear Icon Button
                                        if (_inputController.text.isNotEmpty)
                                          IconButton(
                                            icon: const Icon(Icons.cancel_rounded,
                                                color: Color(0xFF757582), size: 18),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () {
                                              _inputController.clear();
                                              setState(() {});
                                            },
                                          ),
                                      ],
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(duration: 450.ms, delay: 180.ms)
                                      .slideY(begin: 0.12, end: 0),

                                  const SizedBox(height: 18),

                                  // Red Glowing "Continue" CTA Button
                                  Container(
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFE50914),
                                          Color(0xFFC11119),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFE50914).withOpacity(0.42),
                                          blurRadius: 16,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isSubmitting ? null : _requestOtpAndProceed,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        shadowColor: Colors.transparent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: _isSubmitting
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Continue',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                const Icon(Icons.arrow_forward_rounded,
                                                    color: Colors.white, size: 18),
                                              ],
                                            ),
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(duration: 450.ms, delay: 260.ms)
                                      .slideY(begin: 0.12, end: 0)
                                      .animate(onPlay: (c) => c.repeat(period: 3.seconds))
                                      .shimmer(duration: 1200.ms, color: Colors.white24),

                                  const SizedBox(height: 20),

                                  // "Get Help ∨" Expandable Section
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        _isHelpExpanded = !_isHelpExpanded;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Get Help',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          AnimatedRotation(
                                            turns: _isHelpExpanded ? 0.5 : 0.0,
                                            duration: const Duration(milliseconds: 200),
                                            child: const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: Colors.white70,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Expandable Help Content
                                  AnimatedCrossFade(
                                    duration: const Duration(milliseconds: 250),
                                    crossFadeState: _isHelpExpanded
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                    firstChild: const SizedBox.shrink(),
                                    secondChild: Container(
                                      margin: const EdgeInsets.only(top: 12),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF171722),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.1),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildHelpItem(
                                            'Forgot phone number or account details?',
                                            () => ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Contact support helpline below.')),
                                            ),
                                          ),
                                          const Divider(color: Color(0xFF282835), height: 16),
                                          _buildHelpItem(
                                            'Sign in with TV Pairing Code',
                                            () => ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('TV activation available in settings.')),
                                            ),
                                          ),
                                          const Divider(color: Color(0xFF282835), height: 16),
                                          _buildHelpItem(
                                            'Instant Demo Access (Explore as Guest)',
                                            _skipToHome,
                                            isHighlighted: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Google reCAPTCHA Notice
                                  Text(
                                    "This page is protected by Google reCAPTCHA to ensure you're not a bot. Learn more.",
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF6E6E78),
                                      height: 1.38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Authentic Footer
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, VoidCallback onTap, {bool isHighlighted = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              isHighlighted ? Icons.flash_on_rounded : Icons.help_outline_rounded,
              size: 15,
              color: isHighlighted ? AppColors.accentGold : const Color(0xFF999999),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w400,
                  color: isHighlighted ? AppColors.accentGold : const Color(0xFFCCCCCC),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 15, color: Color(0xFF666666)),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions? Call 000-800-919-1743 (Toll-Free)',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF888888),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // 2-Column Links Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFooterLink('FAQ'),
                    const SizedBox(height: 10),
                    _buildFooterLink('Terms of Use'),
                    const SizedBox(height: 10),
                    _buildFooterLink('Cookie Preferences'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFooterLink('Help Centre'),
                    const SizedBox(height: 10),
                    _buildFooterLink('Privacy'),
                    const SizedBox(height: 10),
                    _buildFooterLink('Corporate Information'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Language Selector
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF14141C),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF282835)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLanguage,
                dropdownColor: const Color(0xFF14141C),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
                items: _languages.map((lang) {
                  return DropdownMenuItem<String>(
                    value: lang,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.translate_rounded, color: Colors.white, size: 13),
                        const SizedBox(width: 6),
                        Text(lang, style: GoogleFonts.inter(color: Colors.white, fontSize: 12.5)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLanguage = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'NetLiv India',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF555560),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String label) {
    return InkWell(
      onTap: () {},
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12.5,
          color: const Color(0xFF757582),
          decoration: TextDecoration.underline,
          decorationColor: const Color(0xFF454550),
        ),
      ),
    );
  }
}

/// NetLiv Multi-Column Vertical Animated Moving Collage matching netlivtv.com/login.
class _NetLivAnimatedCollage extends StatefulWidget {
  final List<String> posterUrls;
  const _NetLivAnimatedCollage({required this.posterUrls});

  @override
  State<_NetLivAnimatedCollage> createState() => _NetLivAnimatedCollageState();
}

class _NetLivAnimatedCollageState extends State<_NetLivAnimatedCollage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<String> _fallback = [
    'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=500&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=500&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1682687220063-4742bd7fd538?w=500&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=500&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=500&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=500&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1574375927938-d5a98e8ffe85?w=500&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1618336753974-aae8e04506aa?w=500&auto=format&fit=crop&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 35),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pool = widget.posterUrls.isNotEmpty ? widget.posterUrls : _fallback;
    final all = [...pool, ..._fallback];

    // 4 Columns for rich mobile layout
    final col1 = [for (int i = 0; i < all.length; i += 4) all[i]];
    final col2 = [for (int i = 1; i < all.length; i += 4) all[i]];
    final col3 = [for (int i = 2; i < all.length; i += 4) all[i]];
    final col4 = [for (int i = 3; i < all.length; i += 4) all[i]];

    final list1 = [...col1, ...col1, ...col1, ...col1];
    final list2 = [...col2, ...col2, ...col2, ...col2];
    final list3 = [...col3, ...col3, ...col3, ...col3];
    final list4 = [...col4, ...col4, ...col4, ...col4];

    return OverflowBox(
      maxWidth: 750,
      maxHeight: 1400,
      alignment: Alignment.center,
      child: Transform.scale(
        scale: 1.15,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            const cycle = 720.0;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Col 1 (Up)
                _buildColumn(list1, -t * cycle),
                const SizedBox(width: 8),
                // Col 2 (Down)
                _buildColumn(list2, (t - 1.0) * cycle),
                const SizedBox(width: 8),
                // Col 3 (Up)
                _buildColumn(list3, -((t + 0.5) % 1.0) * cycle),
                const SizedBox(width: 8),
                // Col 4 (Down)
                _buildColumn(list4, (((t + 0.5) % 1.0) - 1.0) * cycle),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildColumn(List<String> urls, double offsetY) {
    return Transform.translate(
      offset: Offset(0, offsetY),
      child: Column(
        children: urls.take(12).map((url) {
          return Container(
            width: 105,
            height: 155,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF17171F),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: const Color(0xFF1C1C26)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
