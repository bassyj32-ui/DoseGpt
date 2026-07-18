import 'package:flutter/material.dart';
import 'app_theme.dart';

/// DoseGPT Card
///
/// Headspace-inspired: soft, tactile, elevated, generous corners.
/// The card feels like a premium physical object — rounded, slightly
/// lifted, with a subtle press animation and smooth image fade-in.
class DoseCard extends StatefulWidget {
  final String label;
  final String imagePath;
  final List<Color> fallbackGradient;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const DoseCard({
    super.key,
    required this.label,
    required this.imagePath,
    required this.fallbackGradient,
    this.onTap,
    this.width = 156,
    this.height = 156,
  });

  @override
  State<DoseCard> createState() => _DoseCardState();
}

class _DoseCardState extends State<DoseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            boxShadow: AppTheme.shadowCard,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Cover image with fade-in
              _CardImage(
                imagePath: widget.imagePath,
                fallbackGradient: widget.fallbackGradient,
                label: widget.label,
                size: widget.width,
              ),

              // Condition color wash — unified tint like Spotify album art
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.fallbackGradient[0].withValues(alpha: 0.35),
                        widget.fallbackGradient[1].withValues(alpha: 0.25),
                      ],
                    ),
                  ),
                ),
              ),

              // Gradient overlay — steeper fade for text legibility
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.45, 0.6, 0.75, 1.0],
                    ),
                  ),
                ),
              ),

              // Label
              Positioned(
                left: AppTheme.space12,
                right: AppTheme.space12,
                bottom: AppTheme.space12,
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: -0.1,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
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
      ),
    );
  }
}

/// Card image with fade-in opacity animation.
class _CardImage extends StatefulWidget {
  final String imagePath;
  final List<Color> fallbackGradient;
  final String label;
  final double size;

  const _CardImage({
    required this.imagePath,
    required this.fallbackGradient,
    required this.label,
    required this.size,
  });

  @override
  State<_CardImage> createState() => _CardImageState();
}

class _CardImageState extends State<_CardImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeCtrl,
      curve: Curves.easeOutCubic,
    );
    _fadeCtrl.forward();
  }

  @override
  void didUpdateWidget(covariant _CardImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _fadeCtrl.reset();
      _fadeCtrl.forward();
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Image.asset(
        widget.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.fallbackGradient,
              ),
            ),
            child: Center(
              child: Text(
                widget.label.isNotEmpty ? widget.label[0].toUpperCase() : '',
                style: TextStyle(
                  fontSize: widget.size * 0.3,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
