import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Spotify-style card for horizontal scrolling rows.
/// Square card with cover image, rich gradient overlay, bold label,
/// and a subtle lift shadow.
class DoseCard extends StatelessWidget {
  final String label;
  final String imagePath;
  final List<Color> fallbackGradient;
  final VoidCallback? onTap;
  final double size;

  const DoseCard({
    super.key,
    required this.label,
    required this.imagePath,
    required this.fallbackGradient,
    this.onTap,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3D000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Cover image
            _buildImage(),

            // Gradient overlay for text legibility
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
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.0, 0.45, 0.6, 0.8, 1.0],
                  ),
                ),
              ),
            ),

            // Label
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.15,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 4,
                      offset: Offset(0, 1),
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
    );
  }

  Widget _buildImage() {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
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
                fontSize: size * 0.3,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
        );
      },
    );
  }
}
