import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../state/app_state.dart';
import '../widgets/animated_bottom_nav.dart';
import '../widgets/app_lock_gate.dart';
import 'shorts/shorts_screen.dart';
import 'home/home_screen.dart';
import 'my_list/my_list_screen.dart';
import 'profile/profile_screen.dart';
import 'search/search_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentIndex = appState.currentTabIndex;

    final screens = const [
      HomeScreen(),
      SearchScreen(),
      ShortsScreen(),
      MyListScreen(),
      ProfileScreen(),
    ];

    return AppLockGate(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Screen views
            IndexedStack(
              index: currentIndex,
              children: screens,
            ),

            // Floating Animated Bottom Navigation Dock
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedBottomNav(
                currentIndex: currentIndex,
                onTap: (index) => appState.setTabIndex(index),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
