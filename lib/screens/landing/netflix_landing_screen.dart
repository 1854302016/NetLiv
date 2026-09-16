import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../data/mock_data.dart';
import '../../widgets/curved_arc_divider.dart';
import '../../widgets/netflix_top_ten_card.dart';
import '../../widgets/reason_to_join_card.dart';
import '../auth/login_screen.dart';
import '../main_navigation_screen.dart';

/// Full, authentic replica of the official Netflix Landing Homepage based on user reference images.
/// Includes Hero with mosaic posters & pricing, curved arc divider, outlined Top 10 carousel,
/// "More reasons to join" feature cards, interactive FAQ accordion, and authentic footer.
class NetflixLandingScreen extends StatefulWidget {
  const NetflixLandingScreen({super.key});

  @override
  State<NetflixLandingScreen> createState() => _NetflixLandingScreenState();
}

class _NetflixLandingScreenState extends State<NetflixLandingScreen> {
  final TextEditingController _topEmailController = TextEditingController();
  final TextEditingController _bottomEmailController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _trendingScrollController = ScrollController();

  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'हिन्दी', 'Español'];

  @override
  void dispose() {
    _topEmailController.dispose();
    _bottomEmailController.dispose();
    _scrollController.dispose();
    _trendingScrollController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  void _getStarted() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  void _scrollTrendingRight() {
    HapticFeedback.lightImpact();
    _trendingScrollController.animateTo(
      _trendingScrollController.offset + 260,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // 1. HERO SECTION WITH POSTER MOSAIC BACKDROP
            // ==========================================
            _buildHeroSection(),

            // ==========================================
            // 2. CURVED ARC DIVIDER (Image 1)
            // ==========================================
            const CurvedArcDivider(height: 52),

            // ==========================================
            // 3. TRENDING NOW SECTION (Image 1)
            // ==========================================
            _buildTrendingNowSection(),

            const SizedBox(height: 42),

            // ==========================================
            // 4. MORE REASONS TO JOIN
            // ==========================================
            _buildMoreReasonsToJoinSection(),

            const SizedBox(height: 40),

            // ==========================================
            // 5. MEMBERSHIP CONVERSION CALLOUT (Clean & Modern)
            // ==========================================
            _buildMembershipCtaSection(),

            const SizedBox(height: 48),

            // ==========================================
            // 6. AUTHENTIC NETFLIX FOOTER
            // ==========================================
            _buildFooterSection(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. HERO SECTION
  // ---------------------------------------------------------------------------
  Widget _buildHeroSection() {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // Background Poster Grid Mosaic
        Positioned.fill(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Grid of real cinema poster imagery
              Opacity(
                opacity: 0.38,
                child: Image.network(
                  'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=1200&auto=format&fit=crop&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: const Color(0xFF0F0F0F)),
                ),
              ),

              // Multi-stop Netflix dark gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.25, 0.65, 0.95, 1.0],
                    colors: [
                      Colors.black.withOpacity(0.85),
                      Colors.black.withOpacity(0.65),
                      Colors.black.withOpacity(0.75),
                      Colors.black.withOpacity(0.96),
                      Colors.black,
                    ],
                  ),
                ),
              ),

              // Radial dark vignette
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.1,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Hero Content
        Padding(
          padding: EdgeInsets.fromLTRB(20, statusBarHeight + 12, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar: NetLiv Wordmark, Language dropdown, Sign In button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // NetLiv official brand logo
                  Image.asset(
                    'assets/images/logo.png',
                    height: 38,
                    fit: BoxFit.contain,
                  ),

                  Row(
                    children: [
                      // Language Selector Dropdown
                      Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFF707070),
                            width: 0.9,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLanguage,
                            dropdownColor: const Color(0xFF1E1E1E),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                              size: 18,
                            ),
                            items: _languages.map((lang) {
                              return DropdownMenuItem<String>(
                                value: lang,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.translate_rounded,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      lang,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedLanguage = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Red "Sign In" Button (Image 1)
                      Material(
                        color: AppColors.netflixRed,
                        borderRadius: BorderRadius.circular(4),
                        child: InkWell(
                          onTap: _navigateToLogin,
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 46),

              // Headline: Unlimited movies, shows, and more
              Text(
                'Unlimited movies,\nshows, and more',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.16,
                  letterSpacing: -0.6,
                ),
              ),

              const SizedBox(height: 14),

              // Price line: Starts at ₹149. Cancel at any time.
              Text(
                'Starts at ₹149. Cancel at any time.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 18),

              // Membership call to action text
              Text(
                'Ready to watch? Enter your email to create or restart your membership.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFE2E2E2),
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 20),

              // Email input field
              _buildEmailField(_topEmailController),

              const SizedBox(height: 14),

              // Red "Get Started >" CTA Button (Image 1)
              _buildGetStartedButton(),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3. TRENDING NOW SECTION
  // ---------------------------------------------------------------------------
  Widget _buildTrendingNowSection() {
    final items = MockData.topTenToday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Trending Now',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal Carousel with Netflix Outlined Rank Cards
        SizedBox(
          height: 195,
          child: Stack(
            children: [
              ListView.builder(
                controller: _trendingScrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return NetflixTopTenCard(
                    item: items[index],
                    rank: index + 1,
                    onTap: _getStarted,
                  );
                },
              ),

              // Right Chevron scroll button (matching Image 1)
              Positioned(
                right: 8,
                top: 40,
                bottom: 40,
                child: GestureDetector(
                  onTap: _scrollTrendingRight,
                  child: Container(
                    width: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white24,
                        width: 0.8,
                      ),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. MORE REASONS TO JOIN SECTION
  // ---------------------------------------------------------------------------
  Widget _buildMoreReasonsToJoinSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'More reasons to join',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),

          // 1. Enjoy on your TV
          const ReasonToJoinCard(
            title: 'Enjoy on your TV',
            description:
                'Watch on smart TVs, PlayStation, Xbox, Chromecast, Apple TV, Blu-ray players and more.',
            type: ReasonType.tv,
          ),

          // 2. Download your shows to watch offline
          const ReasonToJoinCard(
            title: 'Download your shows to watch offline',
            description:
                'Save your favourites easily and always have something to watch.',
            type: ReasonType.download,
          ),

          // 3. Watch everywhere
          const ReasonToJoinCard(
            title: 'Watch everywhere',
            description:
                'Stream unlimited movies and TV shows on your phone, tablet, laptop, and TV.',
            type: ReasonType.everywhere,
          ),

          // 4. Create profiles for kids
          const ReasonToJoinCard(
            title: 'Create profiles for kids',
            description:
                'Send kids on adventures with their favourite characters in a space made just for them — free with your membership.',
            type: ReasonType.kids,
          ),

        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. MEMBERSHIP CONVERSION CALLOUT (Clean, Modern & High Converting)
  // ---------------------------------------------------------------------------
  Widget _buildMembershipCtaSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2E2E2E),
            width: 1.1,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF201316),
              Color(0xFF141414),
              Color(0xFF0D0D0D),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE50914).withOpacity(0.12),
              blurRadius: 36,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // NetLiv Badge Logo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE50914).withOpacity(0.85),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE50914).withOpacity(0.4),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 18),

            Text(
              'Start your membership today.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Ready to watch? Enter your email to create or restart your membership.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFD4D4D4),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),

            _buildEmailField(_bottomEmailController),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _getStarted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.netflixRed,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  shadowColor: const Color(0xFFE50914).withOpacity(0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Get Started',
                      style: GoogleFonts.inter(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Value proposition trust badges
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildTrustBadge('Cancel anytime'),
                _buildTrustBadge('Starts at ₹149/mo'),
                _buildTrustBadge('Watch on all devices'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustBadge(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFFE50914),
          size: 14,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFABABAB),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 6. AUTHENTIC FOOTER SECTION
  // ---------------------------------------------------------------------------
  Widget _buildFooterSection() {
    final footerLinks = [
      'FAQ',
      'Help Centre',
      'Account',
      'Media Centre',
      'Investor Relations',
      'Jobs',
      'Ways to Watch',
      'Terms of Use',
      'Privacy',
      'Cookie Preferences',
      'Corporate Information',
      'Contact Us',
      'Speed Test',
      'Legal Notices',
      'Only on NetLiv',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Color(0xFF222222), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Helpline Link
          InkWell(
            onTap: () {},
            child: Text(
              'Questions? Call 000-800-919-1743 (Toll-Free)',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFFAAAAAA),
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFFAAAAAA),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Multi-Column Links Grid
          Wrap(
            spacing: 24,
            runSpacing: 14,
            children: footerLinks.map((link) {
              return SizedBox(
                width: 140,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening $link...'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Text(
                    link,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: const Color(0xFFA0A0A0),
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFF707070),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // Language Selector Dropdown Button
          Container(
            height: 36,
            width: 128,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFF555555),
                width: 0.9,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLanguage,
                dropdownColor: const Color(0xFF1E1E1E),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                  size: 20,
                ),
                items: _languages.map((lang) {
                  return DropdownMenuItem<String>(
                    value: lang,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.translate_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lang,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedLanguage = val);
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Copyright
          Text(
            'NetLiv India',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF707070),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------
  Widget _buildEmailField(TextEditingController controller) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.netflixDarkInput,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.netflixInputBorder,
          width: 1.1,
        ),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 15,
        ),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Email address',
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF8C8C8C),
            fontSize: 14.5,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return Material(
      color: AppColors.netflixRed,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: _getStarted,
        borderRadius: BorderRadius.circular(4),
        splashColor: AppColors.netflixRedDark,
        child: Container(
          width: 175,
          height: 48,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Get Started',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
