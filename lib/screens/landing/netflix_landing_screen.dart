import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../data/mock_data.dart';
import '../../models/media_item.dart';
import '../../state/app_state.dart';
import '../../widgets/curved_arc_divider.dart';
import '../../widgets/netflix_top_ten_card.dart';
import '../../widgets/reason_to_join_card.dart';
import '../auth/login_screen.dart';

/// Full, authentic replica of the official Netflix Landing Homepage based on user reference images.
/// Includes Hero with mosaic posters & pricing, curved arc divider, outlined Top 10 carousel,
/// "More reasons to join" feature cards, interactive FAQ accordion, and authentic footer.
class NetflixLandingScreen extends StatefulWidget {
  const NetflixLandingScreen({super.key});

  @override
  State<NetflixLandingScreen> createState() => _NetflixLandingScreenState();
}

class _NetflixLandingScreenState extends State<NetflixLandingScreen> {
  final TextEditingController _topPhoneController = TextEditingController();
  final TextEditingController _bottomPhoneController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _trendingScrollController = ScrollController();

  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'हिन्दी', 'ਪੰਜਾਬੀ', 'भोजपुरी', 'Español'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadContent();
    });
  }

  @override
  void dispose() {
    _topPhoneController.dispose();
    _bottomPhoneController.dispose();
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

  void _getStarted([String? phone]) {
    HapticFeedback.mediumImpact();
    final input = (phone ?? _topPhoneController.text).trim();
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            LoginScreen(initialPhoneNumber: input.isNotEmpty ? input : null),
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
        // Background Infinite Auto-Scrolling Tilted Poster Wall
        Positioned.fill(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Moving Poster Marquee Wall (opposite scrolling columns)
              Opacity(
                opacity: 0.45,
                child: _AutoScrollingPosterWall(
                  posterUrls: context
                      .watch<AppState>()
                      .catalog
                      .map((m) => m.posterUrl)
                      .where((url) => url.isNotEmpty)
                      .toList(),
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
                      Colors.black.withOpacity(0.62),
                      Colors.black.withOpacity(0.78),
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
                      Colors.black.withOpacity(0.82),
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
                  // NetLiv official brand logo with breathing glow
                  Image.asset(
                    'assets/images/logo.png',
                    height: 38,
                    fit: BoxFit.contain,
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .shimmer(duration: 2500.ms, color: Colors.white12),

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
              )
                  .animate()
                  .fadeIn(duration: 650.ms, delay: 100.ms)
                  .slideY(begin: 0.18, end: 0, curve: Curves.easeOutCubic),

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
              )
                  .animate()
                  .fadeIn(duration: 650.ms, delay: 220.ms)
                  .slideY(begin: 0.18, end: 0, curve: Curves.easeOutCubic),

              const SizedBox(height: 18),

              // Membership call to action text
              Text(
                'Ready to watch? Enter your mobile number to get started.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFE2E2E2),
                  height: 1.35,
                ),
              )
                  .animate()
                  .fadeIn(duration: 650.ms, delay: 320.ms),

              const SizedBox(height: 20),

              // Mobile number input field
              _buildPhoneField(_topPhoneController)
                  .animate()
                  .fadeIn(duration: 650.ms, delay: 400.ms)
                  .scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1)),

              const SizedBox(height: 14),

              // Red "Get Started >" CTA Button with animated pulse & shimmer
              _buildGetStartedButton(_topPhoneController)
                  .animate()
                  .fadeIn(duration: 650.ms, delay: 480.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic)
                  .animate(onPlay: (c) => c.repeat(period: 3.seconds))
                  .shimmer(duration: 1200.ms, color: Colors.white30),
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
    final appState = context.watch<AppState>();
    final feedTopTen = appState.homeFeed?.topTen;
    final catalogTrending = appState.catalog.where((m) => m.isTrending || (m.topTenRank != null && m.topTenRank! > 0)).toList();
    final items = (feedTopTen != null && feedTopTen.isNotEmpty)
        ? feedTopTen
        : (catalogTrending.isNotEmpty
            ? catalogTrending
            : (appState.catalog.isNotEmpty
                ? appState.catalog.take(10).toList()
                : (appState.isContentLoading ? <MediaItem>[] : MockData.topTenToday)));

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
          child: items.isEmpty && appState.isContentLoading
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 155,
                      height: 185,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .shimmer(duration: 1200.ms, color: Colors.white10);
                  },
                )
              : Stack(
                  children: [
                    ListView.builder(
                      controller: _trendingScrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return KeyedSubtree(
                          key: ValueKey('topten_${item.id}_$index'),
                          child: NetflixTopTenCard(
                            item: item,
                            rank: index + 1,
                            onTap: _getStarted,
                          )
                              .animate(key: ValueKey('anim_${item.id}'))
                              .fadeIn(duration: 500.ms, delay: (index * 70).ms)
                              .slideX(begin: 0.25, end: 0, curve: Curves.easeOutCubic),
                        );
                      },
                    ),

                    // Right Chevron scroll button
                    if (items.length > 2)
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
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 100.ms)
              .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),

          // 2. Download your shows to watch offline
          const ReasonToJoinCard(
            title: 'Download your shows to watch offline',
            description:
                'Save your favourites easily and always have something to watch.',
            type: ReasonType.download,
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 180.ms)
              .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),

          // 3. Watch everywhere
          const ReasonToJoinCard(
            title: 'Watch everywhere',
            description:
                'Stream unlimited movies and TV shows on your phone, tablet, laptop, and TV.',
            type: ReasonType.everywhere,
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 260.ms)
              .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),

          // 4. Create profiles for kids
          const ReasonToJoinCard(
            title: 'Create profiles for kids',
            description:
                'Send kids on adventures with their favourite characters in a space made just for them — free with your membership.',
            type: ReasonType.kids,
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 340.ms)
              .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic),
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
              'Ready to watch? Enter your mobile number to get started.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFD4D4D4),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),

            _buildPhoneField(_bottomPhoneController),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _getStarted(_bottomPhoneController.text),
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
            )
                .animate(onPlay: (c) => c.repeat(period: 3.seconds))
                .shimmer(duration: 1200.ms, color: Colors.white30),
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
  Widget _buildPhoneField(TextEditingController controller) {
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
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: InputDecoration(
          hintText: 'Mobile number',
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF8C8C8C),
            fontSize: 14.5,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Text(
              '+91',
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildGetStartedButton([TextEditingController? controller]) {
    return Material(
      color: AppColors.netflixRed,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () => _getStarted(controller?.text),
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

/// Dynamic Infinite Auto-Scrolling Tilted Poster Wall (Multi-column opposite flow).
class _AutoScrollingPosterWall extends StatefulWidget {
  final List<String> posterUrls;
  const _AutoScrollingPosterWall({required this.posterUrls});

  @override
  State<_AutoScrollingPosterWall> createState() => _AutoScrollingPosterWallState();
}

class _AutoScrollingPosterWallState extends State<_AutoScrollingPosterWall>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<String> _fallbackPosters = [
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
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rawList = widget.posterUrls.isNotEmpty ? widget.posterUrls : _fallbackPosters;
    final posters = [...rawList, ..._fallbackPosters];

    // Distribute posters into 3 columns
    final col1 = [for (int i = 0; i < posters.length; i += 3) posters[i]];
    final col2 = [for (int i = 1; i < posters.length; i += 3) posters[i]];
    final col3 = [for (int i = 2; i < posters.length; i += 3) posters[i]];

    // Duplicate each list 4x for smooth infinite vertical repetition
    final list1 = [...col1, ...col1, ...col1, ...col1];
    final list2 = [...col2, ...col2, ...col2, ...col2];
    final list3 = [...col3, ...col3, ...col3, ...col3];

    return OverflowBox(
      maxWidth: 600,
      maxHeight: 1200,
      alignment: Alignment.center,
      child: Transform.scale(
        scale: 1.28,
        child: Transform.rotate(
          angle: -0.09, // ~ -5 degrees tilt matching official Netflix design
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              const singleCycleHeight = 760.0;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Column 1 (Flows UP)
                  _buildColumn(list1, -t * singleCycleHeight),
                  const SizedBox(width: 12),
                  // Column 2 (Flows DOWN)
                  _buildColumn(list2, (t - 1.0) * singleCycleHeight),
                  const SizedBox(width: 12),
                  // Column 3 (Flows UP)
                  _buildColumn(list3, -((t + 0.5) % 1.0) * singleCycleHeight),
                ],
              );
            },
          ),
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
            width: 130,
            height: 185,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF222222)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
