import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/home_feed.dart';
import '../../models/media_item.dart';
import '../../state/app_state.dart';
import '../../widgets/banner_carousel.dart';
import '../../widgets/content_row.dart';
import '../../widgets/custom_app_bar.dart';
import '../auth/subscription_plan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadContent();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<MediaItem> _itemsForGenre(HomeFeed feed, String needle) {
    final row = feed.rowsByGenre.firstWhere(
      (r) => r.genre.toLowerCase().contains(needle.toLowerCase()),
      orElse: () => const GenreRow(genre: '', items: []),
    );
    return row.items;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final selectedCategory = appState.selectedHomeCategory;
    final homeFeed = appState.homeFeed;

    if (homeFeed == null && appState.isContentLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.netflixRed)),
      );
    }

    if (homeFeed == null && appState.contentError != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appState.contentError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => appState.loadContent(force: true),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.netflixRed),
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Filter items according to the selected top category / genre.
    bool matchesCategory(MediaItem item) {
      final genres = item.genres.map((g) => g.toLowerCase()).toList();
      switch (selectedCategory) {
        case 'All':
        case 'All Genres':
          return true;
        case 'TV Shows':
        case 'Web Series':
          return item.type == MediaType.series;
        case 'Movies':
          return item.type == MediaType.movie;
        case 'Originals':
          return item.isOriginal;
        case 'Action Blockbusters':
          return genres.any((g) => g.contains('action'));
        case 'Cyberpunk & Futuristic':
          return genres.any((g) =>
              g.contains('cyberpunk') || g.contains('sci-fi') || g.contains('space'));
        case 'Crime & Dark Thrillers':
          return genres.any((g) =>
              g.contains('thriller') || g.contains('crime') || g.contains('heist'));
        case 'Critically Acclaimed Cinema':
          return item.matchScore >= 90;
        case 'Documentary Series':
          return genres.any((g) => g.contains('documentary'));
        default:
          return true;
      }
    }

    final feed = homeFeed!;
    List<MediaItem> banners = feed.banners.where(matchesCategory).toList();
    List<MediaItem> topTen = feed.topTen.where(matchesCategory).toList();
    List<MediaItem> originals = feed.originals.where(matchesCategory).toList();
    List<MediaItem> action = _itemsForGenre(feed, 'action').where(matchesCategory).toList();
    List<MediaItem> trending = feed.trending.where(matchesCategory).toList();
    List<MediaItem> scifi = _itemsForGenre(feed, 'sci-fi').where(matchesCategory).toList();
    List<MediaItem> continueWatching = appState.continueWatching;

    // Fall back to the unfiltered catalog when a category empties a row out,
    // so the home page never looks broken for a niche selection.
    if (banners.isEmpty) banners = feed.banners;
    if (trending.isEmpty) trending = feed.banners;

    // Kids Profile / Parental maturity filtering — applied last so no
    // fallback above can ever reintroduce content a Kids profile shouldn't see.
    bool allowed(MediaItem item) => appState.isContentAllowed(item.ageRating);
    banners = banners.where(allowed).toList();
    topTen = topTen.where(allowed).toList();
    originals = originals.where(allowed).toList();
    action = action.where(allowed).toList();
    trending = trending.where(allowed).toList();
    scifi = scifi.where(allowed).toList();
    continueWatching = continueWatching.where(allowed).toList();

    // "Because you watched X" personalized row, seeded from Continue Watching
    final List<MediaItem> recommended = continueWatching.isNotEmpty
        ? appState.recommendationsFor(continueWatching.first).where(allowed).toList()
        : <MediaItem>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // RefreshIndicator with Netflix Red accent
          RefreshIndicator(
            color: AppColors.netflixRed,
            backgroundColor: AppColors.surfaceElevated,
            onRefresh: () => appState.loadContent(force: true),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Banner Carousel
                  BannerCarousel(items: banners),

                  // 5 Days Subscription Expiry Alert Banner
                  if (appState.isSubscriptionExpiringSoon)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4A1010), Color(0xFF200505)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.netflixRed.withOpacity(0.6), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.netflixRed.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.timer_outlined, color: AppColors.netflixRed, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Plan Expiring in ${appState.subscriptionDaysLeft} Days!',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Renew your ${appState.activePlanName ?? 'VIP'} plan now to keep watching without disruption.',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFCCCCCC),
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SubscriptionPlanScreen(isOnboarding: false),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.netflixRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Text(
                              'Renew',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Kids Mode Banner
                  if (appState.isKidsModeActive)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.child_care_rounded, color: AppColors.accentGold, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Kids Mode is on — showing family-friendly titles only.",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Continue Watching
                  if (continueWatching.isNotEmpty)
                    ContentRow(
                      title: 'Continue Watching for ${appState.activeProfile.name}',
                      items: continueWatching,
                      isLandscape: true,
                      heroPrefix: 'cw',
                    ),

                  // Top 10 in NetLiv Today
                  ContentRow(
                    title: 'Top 10 in NetLiv Today',
                    items: topTen,
                    isTopTen: true,
                    heroPrefix: 'top',
                  ),

                  // Because You Watched ... (personalized recommendations)
                  if (recommended.isNotEmpty)
                    ContentRow(
                      title: 'Because You Watched ${continueWatching.first.title}',
                      items: recommended,
                      heroPrefix: 'reco',
                    ),

                  // NetLiv Originals
                  ContentRow(
                    title: 'NetLiv Originals',
                    items: originals,
                    heroPrefix: 'orig',
                  ),

                  // Trending Now
                  ContentRow(
                    title: 'Trending Now',
                    items: trending,
                    heroPrefix: 'trend',
                  ),

                  // Action & Thrillers
                  ContentRow(
                    title: 'Action & Adrenaline Thrillers',
                    items: action,
                    heroPrefix: 'act',
                  ),

                  // Sci-Fi & Cyberpunk
                  ContentRow(
                    title: 'Futuristic & Sci-Fi Visions',
                    items: scifi,
                    heroPrefix: 'scifi',
                  ),
                ],
              ),
            ),
          ),

          // Collapsing Translucent Custom App Bar isolated with AnimatedBuilder
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                final double offset = _scrollController.hasClients
                    ? _scrollController.offset
                    : 0.0;
                return CustomAppBar(
                  scrollOffset: offset,
                  onSearchTap: () => appState.setTabIndex(1),
                  onProfileTap: () => appState.setTabIndex(4),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
