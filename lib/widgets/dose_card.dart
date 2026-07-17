import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Spotify-style card for the condition grid.
/// Features bigger radius, rich gradient overlays, bold text.
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

              // Multi-layer gradient overlay for depth (like Spotify)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      stops: const [0.0, 0.4, 0.6, 0.8, 1.0],
                    ),
                  ),
                ),
              ),

              // Condition name
              Positioned(
                left: AppTheme.spacingMd,
                right: AppTheme.spacingMd,
                bottom: AppTheme.spacingMd,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.15,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
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
                    fontSize: constraints.maxWidth * 0.3,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.25),
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
