import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Spotify-style image card for the 2-column condition grid.
/// Shows a real medical image (or gradient fallback) with condition name overlay.
class DoseCard extends StatelessWidget {
  final String label;
  final String imagePath;
  final List<Color> fallbackGradient;
  final VoidCallback? onTap;

  const DoseCard({
    super.key,
    required this.label,
    required this.imagePath,
    required this.fallbackGradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          boxShadow: AppTheme.cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image or gradient fallback
              _buildCardImage(),

              // Dark gradient overlay at bottom for text
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 56,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xB0000000),
                      ],
                    ),
                  ),
                ),
              ),

              // Condition name at bottom
              Positioned(
                left: AppTheme.spacingSm,
                right: AppTheme.spacingSm,
                bottom: AppTheme.spacingSm,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          errorBuilder: (context, error, stackTrace) {
            // Fallback gradient if image fails to load
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: fallbackGradient,
                ),
              ),
              child: Center(
                child: Text(
                  label.isNotEmpty ? label[0].toUpperCase() : '',
                  style: TextStyle(
                    fontSize: constraints.maxWidth * 0.35,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
