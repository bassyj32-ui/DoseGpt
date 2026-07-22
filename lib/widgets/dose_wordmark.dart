import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Full DOSE Logo App Icon & Wordmark Component
///
/// Features pixel-perfect CustomPainter rendering:
/// - 'D': Block modern sans-serif vector letter
/// - 'O': Capsule split into top (neon emerald) and bottom (mint white) with a precise 1px gap
/// - 'S': Custom curved sleek vector letter
/// - 'E': Solid white block letter with a distinct neon emerald middle bar
/// - Glassmorphic dark emerald gradient tile with ambient radial glow
class DoseLogoTile extends StatelessWidget {
  final double size;

  const DoseLogoTile({
    super.key,
    this.size = 300.0,
  });

  // Core Brand Colors
  static const Color _neonEmerald = Color(0xFF00FF87);
  static const Color _mintWhite = Color(0xFFE6F9F0);
  static const Color _pureWhite = Color(0xFFFFFFFF);
  static const Color _bgDark = Color(0xFF0A120D);

  @override
  Widget build(BuildContext context) {
    final bool isSmall = size < 80;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22), // Standard squircle ratio
        gradient: const RadialGradient(
          center: Alignment(0.8, 0.9),
          radius: 1.2,
          colors: [
            Color(0xFF0F4D2A), // Soft ambient emerald glow
            _bgDark,
            Color(0xFF050906),
          ],
          stops: [0.0, 0.65, 1.0],
        ),
        boxShadow: isSmall
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 25,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
        border: Border.all(
          color: Colors.white.withValues(alpha: isSmall ? 0.08 : 0.12),
          width: isSmall ? 0.8 : 1.5,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: size * 0.75,
          height: size * 0.22,
          child: CustomPaint(
            painter: _DoseLogoPainter(),
          ),
        ),
      ),
    );
  }
}

class _DoseLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double h = size.height;
    final double w = size.width;
    
    // Grid and stroke parameters
    final double strokeWidth = h * 0.18;
    final double letterGap = w * 0.04;
    final double letterWidth = (w - (letterGap * 3)) / 4;

    final Paint whitePaint = Paint()
      ..color = DoseLogoTile._pureWhite
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Paint neonPaint = Paint()
      ..color = DoseLogoTile._neonEmerald
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Paint mintPaint = Paint()
      ..color = DoseLogoTile._mintWhite
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // ── 1. DRAW LETTER 'D' ──────────────────────────────────────────────
    double dLeft = 0;
    Path dPath = Path();
    dPath.moveTo(dLeft, 0);
    dPath.lineTo(dLeft + letterWidth * 0.5, 0);
    dPath.arcTo(
      Rect.fromLTWH(dLeft, 0, letterWidth, h),
      -math.pi / 2,
      math.pi,
      false,
    );
    dPath.lineTo(dLeft, h);
    dPath.close();

    Path dInner = Path();
    dInner.moveTo(dLeft + strokeWidth, strokeWidth);
    dInner.lineTo(dLeft + letterWidth * 0.4, strokeWidth);
    dInner.arcTo(
      Rect.fromLTWH(
        dLeft + strokeWidth,
        strokeWidth,
        letterWidth - (strokeWidth * 2),
        h - (strokeWidth * 2),
      ),
      -math.pi / 2,
      math.pi,
      false,
    );
    dInner.lineTo(dLeft + strokeWidth, h - strokeWidth);
    dInner.close();

    canvas.drawPath(
      Path.combine(PathOperation.difference, dPath, dInner),
      whitePaint,
    );

    // ── 2. DRAW LETTER 'O' (CAPSULE SPLIT) ──────────────────────────────
    double oLeft = letterWidth + letterGap;
    double gapSize = h * 0.05; // 1px visual gap scaled dynamically
    
    Rect oOuterRect = Rect.fromLTWH(oLeft, 0, letterWidth, h);
    RRect oOuterRRect = RRect.fromRectAndRadius(oOuterRect, Radius.circular(letterWidth * 0.45));

    Rect oInnerRect = Rect.fromLTWH(
      oLeft + strokeWidth,
      strokeWidth,
      letterWidth - (strokeWidth * 2),
      h - (strokeWidth * 2),
    );
    RRect oInnerRRect = RRect.fromRectAndRadius(oInnerRect, Radius.circular((letterWidth - strokeWidth * 2) * 0.45));

    Path oFullRing = Path.combine(
      PathOperation.difference,
      Path()..addRRect(oOuterRRect),
      Path()..addRRect(oInnerRRect),
    );

    // Top Split Clip Box
    Path topHalfClip = Path()
      ..addRect(Rect.fromLTWH(oLeft, 0, letterWidth, (h / 2) - (gapSize / 2)));
    
    // Bottom Split Clip Box
    Path bottomHalfClip = Path()
      ..addRect(Rect.fromLTWH(oLeft, (h / 2) + (gapSize / 2), letterWidth, h / 2));

    canvas.drawPath(
      Path.combine(PathOperation.intersect, oFullRing, topHalfClip),
      neonPaint,
    );

    canvas.drawPath(
      Path.combine(PathOperation.intersect, oFullRing, bottomHalfClip),
      mintPaint,
    );

    // ── 3. DRAW LETTER 'S' ──────────────────────────────────────────────
    double sLeft = (letterWidth * 2) + (letterGap * 2);
    
    Path sPath = Path();
    double cornerRadius = strokeWidth * 0.8;
    
    // Top bar
    sPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(sLeft, 0, letterWidth, strokeWidth),
      Radius.circular(cornerRadius),
    ));
    // Spine Top
    sPath.addRect(Rect.fromLTWH(sLeft, 0, strokeWidth, h * 0.5));
    // Middle bar
    sPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(sLeft, (h / 2) - (strokeWidth / 2), letterWidth, strokeWidth),
      Radius.circular(cornerRadius),
    ));
    // Spine Bottom
    sPath.addRect(Rect.fromLTWH(sLeft + letterWidth - strokeWidth, h * 0.5, strokeWidth, h * 0.5));
    // Bottom bar
    sPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(sLeft, h - strokeWidth, letterWidth, strokeWidth),
      Radius.circular(cornerRadius),
    ));

    canvas.drawPath(sPath, whitePaint);

    // ── 4. DRAW LETTER 'E' ──────────────────────────────────────────────
    double eLeft = (letterWidth * 3) + (letterGap * 3);

    // Vertical Stem (White)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(eLeft, 0, strokeWidth, h),
        Radius.circular(strokeWidth * 0.3),
      ),
      whitePaint,
    );

    // Top Bar (White)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(eLeft, 0, letterWidth, strokeWidth),
        Radius.circular(strokeWidth * 0.3),
      ),
      whitePaint,
    );

    // Bottom Bar (White)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(eLeft, h - strokeWidth, letterWidth, strokeWidth),
        Radius.circular(strokeWidth * 0.3),
      ),
      whitePaint,
    );

    // Middle Bar (Neon Emerald)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          eLeft + strokeWidth * 0.5, 
          (h / 2) - (strokeWidth / 2), 
          letterWidth - (strokeWidth * 0.5), 
          strokeWidth,
        ),
        Radius.circular(strokeWidth * 0.4),
      ),
      neonPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
