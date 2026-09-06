import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

enum ReasonType {
  tv,
  download,
  everywhere,
  kids,
}

/// "More reasons to join" feature card matching Image 2.
/// Deep gradient card with crisp typography and custom visual iconography.
class ReasonToJoinCard extends StatelessWidget {
  final String title;
  final String description;
  final ReasonType type;

  const ReasonToJoinCard({
    super.key,
    required this.title,
    required this.description,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: AppColors.reasonCardGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0x28818CF8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Text Content (Title & Description)
          Padding(
            padding: const EdgeInsets.only(right: 60, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFB4B0C7),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

          // Bottom Right Custom Graphic Illustration
          Positioned(
            right: 0,
            bottom: 0,
            child: _buildGraphic(type),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphic(ReasonType type) {
    switch (type) {
      case ReasonType.tv:
        return _buildTvGraphic();
      case ReasonType.download:
        return _buildDownloadGraphic();
      case ReasonType.everywhere:
        return _buildEverywhereGraphic();
      case ReasonType.kids:
        return _buildKidsGraphic();
    }
  }

  // 1. Stylized Monitor/TV with vibrant magenta screen
  Widget _buildTvGraphic() {
    return Container(
      width: 64,
      height: 52,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Stand base
          Positioned(
            bottom: 0,
            child: Container(
              width: 26,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE50914),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Stand neck
          Positioned(
            bottom: 3,
            child: Container(
              width: 5,
              height: 8,
              color: const Color(0xFFB81D24),
            ),
          ),
          // Monitor screen
          Positioned(
            top: 0,
            child: Container(
              width: 58,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF3E3E5E),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE50914).withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.9,
                      colors: [
                        Color(0xFFFF2E63),
                        Color(0xFF790C5A),
                        Color(0xFF220C30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Download Circular Gradient Badge
  Widget _buildDownloadGraphic() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.2, -0.3),
          radius: 0.85,
          colors: [
            Color(0xFFFF72A3),
            Color(0xFFE50914),
            Color(0xFF880E4F),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE50914).withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(
        Icons.arrow_downward_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  // 3. Telescope / Wand with stars
  Widget _buildEverywhereGraphic() {
    return SizedBox(
      width: 58,
      height: 54,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Sparkle 1
          const Positioned(
            top: 2,
            left: 8,
            child: Icon(
              Icons.star_rounded,
              color: Color(0xFFFF5252),
              size: 14,
            ),
          ),
          // Sparkle 2
          const Positioned(
            top: 14,
            left: 0,
            child: Icon(
              Icons.auto_awesome,
              color: Color(0xFFFF80AB),
              size: 11,
            ),
          ),
          // Telescope / Device Beam
          Transform.rotate(
            angle: -0.55,
            child: Container(
              width: 44,
              height: 22,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF4081),
                    Color(0xFFC2185B),
                    Color(0xFF880E4F),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF4081).withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.devices_other_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Cute Kids Profile Faces
  Widget _buildKidsGraphic() {
    return SizedBox(
      width: 58,
      height: 46,
      child: Stack(
        children: [
          // Yellow face
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF9A825),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.sentiment_very_satisfied_rounded,
                  color: Color(0xFF422100),
                  size: 22,
                ),
              ),
            ),
          ),
          // Red/Pink face overlapping
          Positioned(
            right: 2,
            bottom: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFE50914),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE50914).withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.mood_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
