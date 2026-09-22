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
import '../auditions/audition_hub_screen.dart';
import '../auth/login_screen.dart';
import '../auth/profile_setup_screen.dart';
import '../main_navigation_screen.dart';

/// Unique, High-Converting NetLiv Landing Experience.
/// Integrates Dual-Portal (Cinema Streaming & Auditions Casting),
/// 3D Holographic VIP Pass (₹49), Interactive Mood Selector,
/// NetLiv Wall of Fame (Selected Stars Showcase), and Value Comparison.
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

  // Dual-Portal Mode: false = Cinema Stream, true = Auditions & Casting
  bool _isAuditionMode = false;

  // Active Mood Filter
  String _selectedMood = '🔥 All Trending';
  final List<String> _moods = [
    '🔥 All Trending',
    '💥 Action Thrillers',
    '😂 Comedy',
    '❤️ Romance',
    '😱 Crime & Mystery',
    '🎵 Musical & Shorts',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      appState.loadContent();
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
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
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
    if (_trendingScrollController.hasClients) {
      _trendingScrollController.animateTo(
        _trendingScrollController.offset + 260,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
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
            // 1. UNIQUE DUAL-PORTAL HERO SECTION
            // ==========================================
            _buildHeroSection(),

            // ==========================================
            // 2. CURVED ARC DIVIDER WITH AMBIENT GLOW
            // ==========================================
            const CurvedArcDivider(height: 48),

            // ==========================================
            // 3. 3D HOLOGRAPHIC VIP ALL-ACCESS PASS (₹49)
            // ==========================================
            _buildVipPassSection(),

            const SizedBox(height: 32),

            // ==========================================
            // 4. INTERACTIVE MOOD SELECTOR & TRENDING GRID
            // ==========================================
            _buildTrendingWithMoodsSection(),

            const SizedBox(height: 36),

            // ==========================================
            // 5. NETLIV WALL OF FAME (TALENT SHOWCASE)
            // ==========================================
            _buildWallOfFameSection(),

            const SizedBox(height: 36),

            // ==========================================
            // 6. VALUE COMPARISON MATRIX (NetLiv vs Others)
            // ==========================================
            _buildComparisonTableSection(),

            const SizedBox(height: 36),

            // ==========================================
            // 7. MORE REASONS TO JOIN
            // ==========================================
            _buildMoreReasonsToJoinSection(),

            const SizedBox(height: 40),

            // ==========================================
            // 8. MEMBERSHIP CONVERSION CALLOUT
            // ==========================================
            _buildMembershipCtaSection(),

            const SizedBox(height: 48),

            // ==========================================
            // 9. FOOTER SECTION
            // ==========================================
            _buildFooterSection(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. DUAL-PORTAL HERO SECTION (Cinema Stream VS Auditions & Casting)
  // ---------------------------------------------------------------------------
  Widget _buildHeroSection() {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // Background Moving Poster Wall
        Positioned.fill(
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: 0.40,
                  child: _AutoScrollingPosterWall(
                    posterUrls: context
                        .watch<AppState>()
                        .catalog
                        .map((m) => m.posterUrl)
                        .where((url) => url.isNotEmpty)
                        .toList(),
                  ),
                ),
                // Gradient Overlays
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.25, 0.65, 0.95, 1.0],
                      colors: [
                        Colors.black.withOpacity(0.85),
                        Colors.black.withOpacity(0.60),
                        Colors.black.withOpacity(0.78),
                        Colors.black.withOpacity(0.96),
                        Colors.black,
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.1,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Hero Content
        Padding(
          padding: EdgeInsets.fromLTRB(20, statusBarHeight + 12, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar: NetLiv Logo, Language, Sign In
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 34,
                    fit: BoxFit.contain,
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .shimmer(duration: 2500.ms, color: Colors.white12),

                  Row(
                    children: [
                      // Language Selector
                      Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF707070),
                            width: 0.9,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLanguage,
                            dropdownColor: const Color(0xFF1E1E1E),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white, size: 16),
                            items: _languages.map((lang) {
                              return DropdownMenuItem<String>(
                                value: lang,
                                child: Row(
                                  children: [
                                    const Icon(Icons.translate_rounded, color: Colors.white, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      lang,
                                      style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w500),
                                    ),
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
                      const SizedBox(width: 8),

                      // Sign In Button
                      Material(
                        color: const Color(0xFF262626),
                        borderRadius: BorderRadius.circular(6),
                        child: InkWell(
                          onTap: _navigateToLogin,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.8),
                            ),
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // DUAL-PORTAL SWITCHER PILL (Unique NetLiv Feature)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F1F).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPortalTab(
                      label: '🍿 Stream Cinema',
                      isSelected: !_isAuditionMode,
                      onTap: () => setState(() => _isAuditionMode = false),
                    ),
                    _buildPortalTab(
                      label: '🎭 Talent & Auditions',
                      isSelected: _isAuditionMode,
                      onTap: () => setState(() => _isAuditionMode = true),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Animated Dynamic Headline based on Mode
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isAuditionMode
                    ? Column(
                        key: const ValueKey('audition_hero'),
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE50914).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE50914), width: 1),
                            ),
                            child: Text(
                              '⭐ NETLIV ORIGINAL CASTING LIVE',
                              style: GoogleFonts.inter(color: const Color(0xFFFF4D4D), fontSize: 11, fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Get Discovered.\nAct in NetLiv Originals',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 29,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Open calls for Actors, Singers, Writers & Directors.\n100% Free with NetLiv VIP Pass!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 14.5, color: const Color(0xFFE0E0E0), height: 1.35),
                          ),
                        ],
                      )
                    : Column(
                        key: const ValueKey('cinema_hero'),
                        children: [
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
                          const SizedBox(height: 12),
                          Text(
                            'Starts at ₹49 / month. Cancel anytime.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFFFFD700)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ready to watch? Enter your mobile number to get started.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFCCCCCC)),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // Phone number input field
              _buildPhoneField(_topPhoneController),

              const SizedBox(height: 14),

              // CTA Button
              _buildGetStartedButton(_topPhoneController, isAudition: _isAuditionMode)
                  .animate(onPlay: (c) => c.repeat(period: 3.seconds))
                  .shimmer(duration: 1200.ms, color: Colors.white24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortalTab({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE50914) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [BoxShadow(color: const Color(0xFFE50914).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. 3D HOLOGRAPHIC VIP ALL-ACCESS PASS CARD (₹49)
  // ---------------------------------------------------------------------------
  Widget _buildVipPassSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF2A080A), Color(0xFF160608), Color(0xFF0F0F0F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.35), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE50914).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('👑', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NETLIV VIP ALL-ACCESS',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFD700),
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                        Text('1 Pass = Movies + Series + Auditions', style: GoogleFonts.inter(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF16A34A), width: 0.8),
                  ),
                  child: Text('₹49 / month', style: GoogleFonts.outfit(color: const Color(0xFF46D369), fontSize: 13, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 14),

            // Benefits Grid
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _buildVipBadge(Icons.movie_filter_rounded, '10,000+ Movies & Series'),
                _buildVipBadge(Icons.stars_rounded, '100% Free Auditions Entry'),
                _buildVipBadge(Icons.hd_rounded, '4K Ultra HD Streaming'),
                _buildVipBadge(Icons.block_rounded, 'Zero Ads Experience'),
                _buildVipBadge(Icons.download_rounded, 'Unlimited Offline Downloads'),
              ],
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => _getStarted(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Unlock All-Access VIP for ₹49 🚀', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVipBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFFFD700)),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. INTERACTIVE MOOD SELECTOR & TRENDING GRID
  // ---------------------------------------------------------------------------
  Widget _buildTrendingWithMoodsSection() {
    final appState = context.watch<AppState>();
    final catalogTrending = appState.catalog.where((m) => m.isTrending || (m.topTenRank != null && m.topTenRank! > 0)).toList();
    final allItems = catalogTrending.isNotEmpty
        ? catalogTrending
        : (appState.catalog.isNotEmpty ? appState.catalog : MockData.topTenToday);

    // Apply simple mood filter
    List<MediaItem> filteredItems = allItems;
    if (_selectedMood.contains('Action')) {
      filteredItems = allItems.where((m) => m.genres.any((g) => g.toLowerCase().contains('action') || g.toLowerCase().contains('thrill'))).toList();
    } else if (_selectedMood.contains('Comedy')) {
      filteredItems = allItems.where((m) => m.genres.any((g) => g.toLowerCase().contains('comedy'))).toList();
    } else if (_selectedMood.contains('Romance')) {
      filteredItems = allItems.where((m) => m.genres.any((g) => g.toLowerCase().contains('romance') || g.toLowerCase().contains('drama'))).toList();
    } else if (_selectedMood.contains('Crime')) {
      filteredItems = allItems.where((m) => m.genres.any((g) => g.toLowerCase().contains('crime') || g.toLowerCase().contains('mystery'))).toList();
    }
    if (filteredItems.isEmpty) filteredItems = allItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trending Now',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
              ),
              Text('Top 10 in India', style: GoogleFonts.inter(color: const Color(0xFFE50914), fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Mood Filter Pills
        SizedBox(
          height: 34,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _moods.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final mood = _moods[index];
              final isSelected = mood == _selectedMood;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedMood = mood);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE50914) : const Color(0xFF222222),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: isSelected ? const Color(0xFFE50914) : Colors.white12),
                  ),
                  child: Text(
                    mood,
                    style: GoogleFonts.inter(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Top 10 Carousel
        SizedBox(
          height: 195,
          child: Stack(
            children: [
              ListView.builder(
                controller: _trendingScrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return KeyedSubtree(
                    key: ValueKey('topten_${item.id}_$index'),
                    child: NetflixTopTenCard(
                      item: item,
                      rank: index + 1,
                      onTap: _getStarted,
                    ),
                  );
                },
              ),
              if (filteredItems.length > 2)
                Positioned(
                  right: 8,
                  top: 40,
                  bottom: 40,
                  child: GestureDetector(
                    onTap: _scrollTrendingRight,
                    child: Container(
                      width: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 26),
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
  // 5. NETLIV WALL OF FAME (TALENT & AUDITION SUCCESS STORIES)
  // ---------------------------------------------------------------------------
  Widget _buildWallOfFameSection() {
    final successTalent = [
      {'name': 'Aarav Sharma', 'role': 'Lead Actor', 'project': 'Mirzapur Nights (Series)', 'icon': '🎭'},
      {'name': 'Riya Kapoor', 'role': 'Playback Singer', 'project': 'Dil Se Dil Tak (Album)', 'icon': '🎵'},
      {'name': 'Kunal Joshi', 'role': 'Director', 'project': 'The Dark Highway (Short Film)', 'icon': '🎬'},
      {'name': 'Sneha Sen', 'role': 'Scriptwriter', 'project': 'Mumbai Express (Series)', 'icon': '✍️'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE50914).withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFE50914), borderRadius: BorderRadius.circular(6)),
                  child: const Text('WALL OF FAME', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 8),
                Text('Stars Discovered on NetLiv', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Real talent selected through NetLiv Auditions and cast directly in upcoming Originals.',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // Talent Grid
            for (var item in successTalent)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(item['icon']!, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name']!, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('${item['role']} • ${item['project']}', style: GoogleFonts.inter(color: const Color(0xFFFFD700), fontSize: 11)),
                        ],
                      ),
                    ),
                    const Icon(Icons.verified_rounded, color: Color(0xFF0284C7), size: 18),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuditionHubScreen()));
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE50914)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Submit Your Audition Monologue 🎬', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. VALUE COMPARISON MATRIX (NetLiv vs Other OTTs)
  // ---------------------------------------------------------------------------
  Widget _buildComparisonTableSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Why Choose NetLiv?', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Expanded(flex: 3, child: Text('Feature', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Center(child: Text('NetLiv VIP', style: GoogleFonts.inter(color: const Color(0xFFE50914), fontSize: 13, fontWeight: FontWeight.w900)))),
                    Expanded(flex: 2, child: Center(child: Text('Other OTTs', style: GoogleFonts.inter(color: Colors.white38, fontSize: 12)))),
                  ],
                ),
                const Divider(color: Colors.white12, height: 20),
                _buildComparisonRow('Monthly Price', '₹49 Only', '₹199 - ₹649', highlight: true),
                _buildComparisonRow('Movies & Web Series', '✅ 10,000+ Hrs', '✅ Included'),
                _buildComparisonRow('Live Auditions & Casting', '✅ 100% Free', '❌ No Auditions'),
                _buildComparisonRow('4K HDR Streaming', '✅ Included', '⚠️ Premium Plan Only'),
                _buildComparisonRow('Ad-Free Experience', '✅ 0 Ads', '❌ Ads on Base Plan'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String feature, String netliv, String others, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(feature, style: GoogleFonts.inter(color: Colors.white, fontSize: 11.5, fontWeight: highlight ? FontWeight.bold : FontWeight.w500))),
          Expanded(flex: 2, child: Center(child: Text(netliv, style: GoogleFonts.inter(color: const Color(0xFF46D369), fontSize: 11.5, fontWeight: FontWeight.w800)))),
          Expanded(flex: 2, child: Center(child: Text(others, style: GoogleFonts.inter(color: Colors.white54, fontSize: 11)))),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 7. MORE REASONS TO JOIN SECTION
  // ---------------------------------------------------------------------------
  Widget _buildMoreReasonsToJoinSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'More reasons to join',
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
          ),
          const SizedBox(height: 16),
          const ReasonToJoinCard(
            title: 'Enjoy on your TV',
            description: 'Watch on smart TVs, PlayStation, Xbox, Chromecast, Apple TV, Blu-ray players and more.',
            type: ReasonType.tv,
          ),
          const ReasonToJoinCard(
            title: 'Download your shows to watch offline',
            description: 'Save your favourites easily and always have something to watch.',
            type: ReasonType.download,
          ),
          const ReasonToJoinCard(
            title: 'Watch everywhere',
            description: 'Stream unlimited movies and TV shows on your phone, tablet, laptop, and TV.',
            type: ReasonType.everywhere,
          ),
          const ReasonToJoinCard(
            title: 'Create profiles for kids',
            description: 'Send kids on adventures with their favourite characters in a space made just for them — free with your membership.',
            type: ReasonType.kids,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 8. MEMBERSHIP CONVERSION CALLOUT
  // ---------------------------------------------------------------------------
  Widget _buildMembershipCtaSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Ready to watch or audition?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your mobile number to create or restart your membership.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 18),
            _buildPhoneField(_bottomPhoneController),
            const SizedBox(height: 14),
            _buildGetStartedButton(_bottomPhoneController),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 9. FOOTER SECTION
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions? Call 000-800-919-1743 (Toll-Free)',
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFAAAAAA), decoration: TextDecoration.underline),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 14,
            children: footerLinks.map((link) {
              return SizedBox(
                width: 140,
                child: Text(
                  link,
                  style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFFA0A0A0), decoration: TextDecoration.underline),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('NetLiv India', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF707070))),
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.netflixInputBorder, width: 1.1),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: InputDecoration(
          hintText: 'Mobile number',
          hintStyle: GoogleFonts.inter(color: const Color(0xFF8C8C8C), fontSize: 14.5),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Text('+91', style: GoogleFonts.inter(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildGetStartedButton(TextEditingController controller, {bool isAudition = false}) {
    return Material(
      color: AppColors.netflixRed,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => _getStarted(controller.text),
        borderRadius: BorderRadius.circular(8),
        splashColor: AppColors.netflixRedDark,
        child: Container(
          width: double.infinity,
          height: 48,
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isAudition ? 'Start Audition Now' : 'Get Started',
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dynamic Infinite Auto-Scrolling Tilted Poster Wall.
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

    final col1 = [for (int i = 0; i < posters.length; i += 3) posters[i]];
    final col2 = [for (int i = 1; i < posters.length; i += 3) posters[i]];
    final col3 = [for (int i = 2; i < posters.length; i += 3) posters[i]];

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
          angle: -0.09,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              const singleCycleHeight = 760.0;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildColumn(list1, -t * singleCycleHeight),
                  const SizedBox(width: 12),
                  _buildColumn(list2, (t - 1.0) * singleCycleHeight),
                  const SizedBox(width: 12),
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
