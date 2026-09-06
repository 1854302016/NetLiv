import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../data/mock_data.dart';
import '../../models/media_item.dart';
import '../../state/app_state.dart';
import '../../widgets/banner_carousel.dart';
import '../../widgets/content_row.dart';
import '../../widgets/custom_app_bar.dart';

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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final selectedCategory = appState.selectedHomeCategory;

    // Filter items according to selected top category
    List<MediaItem> banners = MockData.heroBanners;
    List<MediaItem> topTen = MockData.topTenToday;
    List<MediaItem> originals = MockData.netlivOriginals;
    List<MediaItem> action = MockData.actionThrillers;

    if (selectedCategory == 'TV Shows') {
      banners = banners.where((i) => i.type == MediaType.series).toList();
      topTen = topTen.where((i) => i.type == MediaType.series).toList();
      originals = originals.where((i) => i.type == MediaType.series).toList();
    } else if (selectedCategory == 'Movies') {
      banners = banners.where((i) => i.type == MediaType.movie).toList();
      topTen = topTen.where((i) => i.type == MediaType.movie).toList();
      action = action.where((i) => i.type == MediaType.movie).toList();
    } else if (selectedCategory == 'Originals') {
      banners = banners.where((i) => i.isOriginal).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // RefreshIndicator with Netflix Red accent
          RefreshIndicator(
            color: AppColors.netflixRed,
            backgroundColor: AppColors.surfaceElevated,
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 600));
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Banner Carousel
                  BannerCarousel(items: banners.isNotEmpty ? banners : MockData.heroBanners),

                  const SizedBox(height: 10),

                  // Continue Watching (if user is Alex)
                  ContentRow(
                    title: 'Continue Watching for ${appState.activeProfile.name}',
                    items: MockData.continueWatching,
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

                  // NetLiv Originals
                  ContentRow(
                    title: 'NetLiv Originals',
                    items: originals,
                    heroPrefix: 'orig',
                  ),

                  // Trending Now
                  ContentRow(
                    title: 'Trending Now',
                    items: MockData.heroBanners,
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
                    items: MockData.heroBanners.reversed.toList(),
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
