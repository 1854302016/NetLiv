import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

/// Optimized image component that caches images and displays a sleek shimmer skeleton
/// during loading with an elegant cinema placeholder fallback on failure.
class ShimmerImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? overlay;

  const ShimmerImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    final int cacheW = (width != null && width!.isFinite && width! > 0)
        ? (width! * 2).round()
        : 720;
    final int cacheH = (height != null && height!.isFinite && height! > 0)
        ? (height! * 2).round()
        : 1080;

    final imageWidget = ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          CachedNetworkImage(
            imageUrl: imageUrl,
            width: width,
            height: height,
            fit: fit,
            memCacheWidth: cacheW,
            memCacheHeight: cacheH,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: AppColors.surfaceElevated,
              highlightColor: AppColors.surfaceHighlight,
              child: Container(
                width: width,
                height: height,
                color: AppColors.surfaceElevated,
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: width,
              height: height,
              color: AppColors.surfaceElevated,
              child: Center(
                child: Icon(
                  Icons.movie_filter_outlined,
                  color: AppColors.textMuted.withOpacity(0.5),
                  size: (width != null && height != null && width!.isFinite && height!.isFinite)
                      ? (width! < height! ? width! * 0.3 : height! * 0.3)
                      : 32,
                ),
              ),
            ),
          ),
          ?overlay,
        ],
      ),
    );

    return imageWidget;
  }
}
