import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_typography.dart';
import '../../state/app_state.dart';
import '../../widgets/shimmer_image.dart';
import '../details/content_details_screen.dart';

class GenreBrowseScreen extends StatelessWidget {
  final String genre;

  const GenreBrowseScreen({super.key, required this.genre});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<AppState>().catalog;
    final items = catalog
        .where((item) => item.genres.any((g) => g.toLowerCase() == genre.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(genre, style: AppTypography.titleLarge),
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                'No titles found in "$genre" yet',
                style: AppTypography.bodyMedium,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2 / 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ContentDetailsScreen(item: item),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ShimmerImage(
                      imageUrl: item.posterUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
