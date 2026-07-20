import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Base size-adaptive icon painter that provides shared utilities
/// for creating consistent 3D glass-style medical condition icons.
///
/// All icons share:
///   - Upper-left lighting (highlights on left/top)
///   - Dark glass body gradients
///   - Translucent wing/glass element overlays
///   - Soft inner shadow frame
abstract class ConditionIconPainter extends CustomPainter {
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  // ── Shared utilities ──────────────────────────────────────────

  @protected
  void drawInnerShadow(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final scale = size.width / 100;
    final shadow = Paint()
      ..shader = ui.Gradient.radial(
        Offset(cx, cy),
        50 * scale,
        [Colors.transparent, Colors.black.withValues(alpha: 0.08)],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
        topLeft: const Radius.circular(14),
        topRight: const Radius.circular(14),
        bottomLeft: const Radius.circular(14),
        bottomRight: const Radius.circular(14),
      ),
      shadow,
    );
  }

  @protected
  ui.Gradient glassHighlight(
    Offset from,
    Offset to, {
    double opacity = 0.3,
  }) {
    return ui.Gradient.linear(
      from,
      to,
      [Colors.white.withValues(alpha: opacity), Colors.transparent],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 1. MOSQUITO — Malaria
// ═══════════════════════════════════════════════════════════════
class MosquitoIconPainter extends ConditionIconPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 100;

    // Body (abdomen) — elongated oval
    final body = Paint()
      ..shader = ui.Gradient.linear(
        Offset(cx - 20 * s, cy - 10 * s),
        Offset(cx + 15 * s, cy + 15 * s),
        [const Color(0xFF6B4A3A), const Color(0xFF3D2218)],
      );
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 8 * s), width: 18 * s, height: 32 * s), body);

    // Glass highlight on body
    final hl = Paint()
      ..shader = glassHighlight(Offset(cx - 12 * s, cy - 5 * s), Offset(cx + 5 * s, cy + 10 * s), opacity: 0.35);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 3 * s, cy + 2 * s), width: 10 * s, height: 20 * s), hl);

    // Thorax
    final thorax = Paint()
      ..shader = ui.Gradient.linear(Offset(cx - 12 * s, cy - 25 * s), Offset(cx + 10 * s, cy - 10 * s), [
        const Color(0xFF4A2C1E),
        const Color(0xFF2A1510),
      ]);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 12 * s), width: 16 * s, height: 14 * s), thorax);

    // Head
    final head = Paint()
      ..shader = ui.Gradient.radial(Offset(cx - 3 * s, cy - 23 * s), 8 * s, [
        const Color(0xFF5C3D2E),
        const Color(0xFF2A1510),
      ]);
    canvas.drawCircle(Offset(cx, cy - 24 * s), 7 * s, head);

    // Proboscis (needle)
    final needle = Paint()
      ..shader = ui.Gradient.linear(Offset(cx, cy - 34 * s), Offset(cx, cy - 50 * s), [
        const Color(0xFF8B6B5E),
        const Color(0xFF5C3D2E),
        Colors.white.withValues(alpha: 0.5),
      ])
      ..strokeWidth = 2.0 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - 30 * s), Offset(cx, cy - 48 * s), needle);

    // Needle highlight
    final nh = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.0 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 1 * s, cy - 32 * s), Offset(cx - 1 * s, cy - 46 * s), nh);

    // Wings (translucent glass)
    final wing = Paint()
      ..shader = glassHighlight(Offset(cx - 30 * s, cy - 15 * s), Offset(cx + 20 * s, cy + 5 * s), opacity: 0.4);
    for (final sign in [-1.0, 1.0]) {
      final wPath = Path()
        ..moveTo(cx + sign * 6 * s, cy - 14 * s)
        ..quadraticBezierTo(cx + sign * 30 * s, cy - 38 * s, cx + sign * 24 * s, cy - 18 * s)
        ..quadraticBezierTo(cx + sign * 18 * s, cy - 8 * s, cx + sign * 6 * s, cy - 14 * s);
      canvas.drawPath(wPath, wing);
      final we = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8 * s
        ..color = Colors.white.withValues(alpha: 0.2);
      canvas.drawPath(wPath, we);
    }

    // Legs
    final leg = Paint()
      ..color = const Color(0xFF3D2218)
      ..strokeWidth = 1.2 * s
      ..strokeCap = StrokeCap.round;
    for (final sign in [-1.0, 1.0]) {
      canvas.drawLine(Offset(cx + sign * 8 * s, cy - 10 * s), Offset(cx + sign * 22 * s, cy + 5 * s), leg);
      canvas.drawLine(Offset(cx + sign * 8 * s, cy - 4 * s), Offset(cx + sign * 24 * s, cy + 12 * s), leg);
      canvas.drawLine(Offset(cx + sign * 8 * s, cy + 2 * s), Offset(cx + sign * 22 * s, cy + 18 * s), leg);
    }

    // Eye highlights
    final eye = Paint()..color = Colors.white.withValues(alpha: 0.35);
    canvas.drawCircle(Offset(cx - 2 * s, cy - 26 * s), 1.5 * s, eye);
    canvas.drawCircle(Offset(cx + 2 * s, cy - 26 * s), 1.2 * s, eye);

    drawInnerShadow(canvas, size);
  }
}

// ═══════════════════════════════════════════════════════════════
// 9. HEART — Hypertension
// ═══════════════════════════════════════════════════════════════
class HeartIconPainter extends ConditionIconPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 100;

    // Heart shape
    final heart = Paint()
      ..shader = ui.Gradient.linear(Offset(cx - 15 * s, cy - 10 * s), Offset(cx + 15 * s, cy + 15 * s), [
        Color(0xFFE63946).withValues(alpha: 0.85),
        Color(0xFFC1121F).withValues(alpha: 0.8),
        Color(0xFF780000).withValues(alpha: 0.7),
      ]);
    final heartPath = Path()
      ..moveTo(cx, cy + 18 * s)
      ..quadraticBezierTo(cx - 30 * s, cy, cx - 16 * s, cy - 14 * s)
      ..quadraticBezierTo(cx - 8 * s, cy - 24 * s, cx, cy - 16 * s)
      ..quadraticBezierTo(cx + 8 * s, cy - 24 * s, cx + 16 * s, cy - 14 * s)
      ..quadraticBezierTo(cx + 30 * s, cy, cx, cy + 18 * s)
      ..close();
    canvas.drawPath(heartPath, heart);

    // Heart highlight (left lobe)
    final hl = Paint()
      ..shader = glassHighlight(Offset(cx - 18 * s, cy - 16 * s), Offset(cx - 2 * s, cy + 4 * s), opacity: 0.3);
    final hlPath = Path()
      ..moveTo(cx - 4 * s, cy - 12 * s)
      ..quadraticBezierTo(cx - 12 * s, cy - 20 * s, cx - 16 * s, cy - 12 * s)
      ..quadraticBezierTo(cx - 20 * s, cy - 4 * s, cx - 4 * s, cy + 10 * s)
      ..quadraticBezierTo(cx - 2 * s, cy + 4 * s, cx - 4 * s, cy - 12 * s)
      ..close();
    canvas.drawPath(hlPath, hl);

    // BP measurement lines (systolic/diastolic indicators)
    final bpLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.5 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 10 * s, cy - 28 * s), Offset(cx + 10 * s, cy - 28 * s), bpLine);
    canvas.drawLine(Offset(cx - 8 * s, cy - 24 * s), Offset(cx + 8 * s, cy - 24 * s), bpLine);

    // Small pulse dots
    final pulse = Paint()..color = Colors.white.withValues(alpha: 0.3);
    canvas.drawCircle(Offset(cx, cy - 32 * s), 2 * s, pulse);

    drawInnerShadow(canvas, size);
  }
}

// ═══════════════════════════════════════════════════════════════
// 10. STOMACH — Dyspepsia / Gastritis
// ═══════════════════════════════════════════════════════════════
class StomachIconPainter extends ConditionIconPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 100;

    // Stomach shape (J-shaped pouch)
    final stomach = Paint()
      ..shader = ui.Gradient.linear(Offset(cx - 15 * s, cy - 15 * s), Offset(cx + 15 * s, cy + 15 * s), [
        Color(0xFFE8A090).withValues(alpha: 0.7),
        Color(0xFFC47A68).withValues(alpha: 0.6),
        Color(0xFFA85D4A).withValues(alpha: 0.5),
      ]);
    final stomachPath = Path()
      ..moveTo(cx - 4 * s, cy - 20 * s)
      ..quadraticBezierTo(cx - 16 * s, cy - 18 * s, cx - 16 * s, cy - 6 * s)
      ..quadraticBezierTo(cx - 16 * s, cy + 8 * s, cx - 8 * s, cy + 14 * s)
      ..quadraticBezierTo(cx, cy + 22 * s, cx + 12 * s, cy + 18 * s)
      ..quadraticBezierTo(cx + 22 * s, cy + 14 * s, cx + 20 * s, cy + 4 * s)
      ..quadraticBezierTo(cx + 18 * s, cy - 6 * s, cx + 8 * s, cy - 16 * s)
      ..quadraticBezierTo(cx + 4 * s, cy - 20 * s, cx - 4 * s, cy - 20 * s)
      ..close();
    canvas.drawPath(stomachPath, stomach);

    // Glass highlight
    final hl = Paint()
      ..shader = glassHighlight(Offset(cx - 14 * s, cy - 12 * s), Offset(cx + 4 * s, cy + 10 * s), opacity: 0.25);
    final hlPath = Path()
      ..moveTo(cx - 6 * s, cy - 16 * s)
      ..quadraticBezierTo(cx - 12 * s, cy - 14 * s, cx - 12 * s, cy - 6 * s)
      ..quadraticBezierTo(cx - 12 * s, cy + 4 * s, cx - 4 * s, cy + 12 * s)
      ..quadraticBezierTo(cx - 2 * s, cy + 6 * s, cx - 4 * s, cy - 4 * s)
      ..quadraticBezierTo(cx - 6 * s, cy - 10 * s, cx - 6 * s, cy - 16 * s)
      ..close();
    canvas.drawPath(hlPath, hl);

    // Esophagus (tube coming in)
    final eso = Paint()
      ..shader = ui.Gradient.linear(Offset(cx - 3 * s, cy - 28 * s), Offset(cx + 3 * s, cy - 20 * s), [
        Color(0xFFE8A090).withValues(alpha: 0.5),
        Color(0xFFC47A68).withValues(alpha: 0.4),
      ]);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 24 * s), width: 8 * s, height: 10 * s),
        const Radius.circular(4),
      ),
      eso,
    );

    // Inflammation marks (small red dots)
    final inflame = Paint()..color = Color(0xFFE63946).withValues(alpha: 0.3);
    canvas.drawCircle(Offset(cx - 6 * s, cy + 2 * s), 3 * s, inflame);
    canvas.drawCircle(Offset(cx + 4 * s, cy + 6 * s), 2.5 * s, inflame);

    drawInnerShadow(canvas, size);
  }
}

// ═══════════════════════════════════════════════════════════════
// 11. TYPHOID — Typhoid Fever (thermometer + bacteria)
// ═══════════════════════════════════════════════════════════════
class TyphoidIconPainter extends ConditionIconPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 100;

    // Thermometer tube (fever indicator)
    final tube = Paint()
      ..shader = ui.Gradient.linear(Offset(cx - 8 * s, cy - 28 * s), Offset(cx + 8 * s, cy + 18 * s), [
        Colors.white.withValues(alpha: 0.1),
        const Color(0xFFE8E8E8).withValues(alpha: 0.15),
        Colors.white.withValues(alpha: 0.05),
      ])
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - 30 * s), Offset(cx, cy + 14 * s), tube);

    // Mercury column (high fever)
    final merc = Paint()
      ..shader = ui.Gradient.linear(Offset(cx - 3 * s, cy + 8 * s), Offset(cx + 3 * s, cy - 18 * s), [
        const Color(0xFFE63946),
        const Color(0xFFD62828),
        const Color(0xFFB71C1C),
      ])
      ..strokeWidth = 4 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy + 12 * s), Offset(cx, cy - 4 * s), merc);

    // Mercury bulb
    final bulb = Paint()
      ..shader = ui.Gradient.radial(Offset(cx - 2 * s, cy + 18 * s), 10 * s, [
        const Color(0xFFE63946),
        const Color(0xFFB71C1C),
      ]);
    canvas.drawCircle(Offset(cx, cy + 16 * s), 6 * s, bulb);

    // Bacteria/rod shapes (Salmonella typhi)
    final bacteria = Paint()
      ..shader = ui.Gradient.linear(Offset(cx + 10 * s, cy - 18 * s), Offset(cx + 24 * s, cy - 8 * s), [
        Color(0xFF6B4A3A).withValues(alpha: 0.6),
        Color(0xFF3D2218).withValues(alpha: 0.5),
      ]);
    // Rod 1
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 18 * s, cy - 12 * s), width: 14 * s, height: 5 * s),
        const Radius.circular(2.5),
      ),
      bacteria,
    );
    // Rod 2
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 14 * s, cy - 4 * s), width: 10 * s, height: 4 * s),
        const Radius.circular(2),
      ),
      bacteria,
    );
    // Rod 3
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 20 * s, cy + 2 * s), width: 12 * s, height: 4 * s),
        const Radius.circular(2),
      ),
      bacteria,
    );

    // Flagella (tiny tails on bacteria)
    final flag = Paint()
      ..color = Color(0xFF6B4A3A).withValues(alpha: 0.3)
      ..strokeWidth = 0.8 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx + 25 * s, cy - 12 * s), Offset(cx + 28 * s, cy - 14 * s), flag);
    canvas.drawLine(Offset(cx + 24 * s, cy - 4 * s), Offset(cx + 26 * s, cy - 6 * s), flag);
    canvas.drawLine(Offset(cx + 26 * s, cy + 2 * s), Offset(cx + 28 * s, cy,), flag);

    // Temperature markings
    final mark = Paint()
      ..color = const Color(0xFF8A9B93).withValues(alpha: 0.5)
      ..strokeWidth = 1.2 * s
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final my = cy - 22 * s + i * 8 * s;
      canvas.drawLine(Offset(cx - 6 * s, my), Offset(cx - 3 * s, my), mark);
    }

    drawInnerShadow(canvas, size);
  }
}

// ═══════════════════════════════════════════════════════════════
// 2. LUNGS — Pneumonia
// ═══════════════════════════════════════════════════════════════
class LungsIconPainter extends ConditionIconPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 100;

    // Trachea (windpipe)
    final trachea = Paint()
      ..shader = ui.Gradient.linear(Offset(cx - 5 * s, cy - 30 * s), Offset(cx + 5 * s, cy - 10 * s), [
        Color(0xFFD48C7A).withValues(alpha: 0.8),
        Color(0xFFB86B58).withValues(alpha: 0.7),
      ])
      ..strokeWidth = 5 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - 32 * s), Offset(cx, cy - 10 * s), trachea);

    // Trachea inner highlight
    final th = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 2 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 1.5 * s, cy - 30 * s), Offset(cx - 1.5 * s, cy - 12 * s), th);

    // Left lung
    final leftLung = Paint()
      ..shader = ui.Gradient.radial(Offset(cx - 18 * s, cy + 5 * s), 30 * s, [
        Color(0xFFE8A090).withValues(alpha: 0.7),
        Color(0xFFC47A68).withValues(alpha: 0.6),
        Color(0xFFA85D4A).withValues(alpha: 0.5),
      ]);
    final llPath = Path()
      ..moveTo(cx - 2 * s, cy - 8 * s)
      ..quadraticBezierTo(cx - 25 * s, cy - 22 * s, cx - 28 * s, cy - 4 * s)
      ..quadraticBezierTo(cx - 32 * s, cy + 10 * s, cx - 22 * s, cy + 18 * s)
      ..quadraticBezierTo(cx - 12 * s, cy + 26 * s, cx - 2 * s, cy + 12 * s)
      ..close();
    canvas.drawPath(llPath, leftLung);

    // Left lung highlight
    final llh = Paint()
      ..shader = glassHighlight(Offset(cx - 28 * s, cy - 15 * s), Offset(cx - 10 * s, cy + 10 * s), opacity: 0.25);
    canvas.drawPath(llPath, llh);

    // Right lung
    final rightLung = Paint()
      ..shader = ui.Gradient.radial(Offset(cx + 18 * s, cy + 5 * s), 30 * s, [
        Color(0xFFE8A090).withValues(alpha: 0.7),
        Color(0xFFC47A68).withValues(alpha: 0.6),
        Color(0xFFA85D4A).withValues(alpha: 0.5),
      ]);
    final rlPath = Path()
      ..moveTo(cx + 2 * s, cy - 8 * s)
      ..quadraticBezierTo(cx + 25 * s, cy - 22 * s, cx + 28 * s, cy - 4 * s)
      ..quadraticBezierTo(cx + 32 * s, cy + 10 * s, cx + 22 * s, cy + 18 * s)
      ..quadraticBezierTo(cx + 12 * s, cy + 26 * s, cx + 2 * s, cy + 12 * s)
      ..close();
    canvas.drawPath(rlPath, rightLung);

    // Right lung highlight
    final rlh = Paint()
      ..shader = glassHighlight(Offset(cx + 10 * s, cy - 15 * s), Offset(cx + 28 * s, cy + 10 * s), opacity: 0.25);
    canvas.drawPath(rlPath, rlh);

    // Bronchi branching lines
    final bronchi = Paint()
      ..color = Color(0xFFD48C7A).withValues(alpha: 0.4)
      ..strokeWidth = 1.5 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - 10 * s), Offset(cx - 10 * s, cy), bronchi);
    canvas.drawLine(Offset(cx, cy - 10 * s), Offset(cx + 10 * s, cy), bronchi);

    drawInnerShadow(canvas, size);
  }
}

// ═══════════════════════════════════════════════════════════════
// 3. WATER DROPLET — Diarrhea
// ═══════════════════════════════════════════════════════════════
class DropletIconPainter extends ConditionIconPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 100;

    // Droplet shape — teardrop
    final drop = Paint()
      ..shader = ui.Gradient.linear(Offset(cx - 15 * s, cy - 15 * s), Offset(cx + 12 * s, cy + 15 * s), [
        Color(0xFF5BC0DE).withValues(alpha: 0.85),
        Color(0xFF2E8AB8).withValues(alpha: 0.8),
        Color(0xFF1A5E7A).withValues(alpha: 0.7),
      ]);
    final dropPath = Path()
      ..moveTo(cx, cy - 28 * s)
      ..quadraticBezierTo(cx + 20 * s, cy - 5 * s, cx + 16 * s, cy + 12 * s)
      ..quadraticBezierTo(cx + 12 * s, cy + 26 * s, cx, cy + 26 * s)
      ..quadraticBezierTo(cx - 12 * s, cy + 26 * s, cx - 16 * s, cy + 12 * s)
      ..quadraticBezierTo(cx - 20 * s, cy - 5 * s, cx, cy - 28 * s)
      ..close();
    canvas.drawPath(dropPath, drop);

    // Glass highlight — left side curve
    final hl = Paint()
      ..shader = glassHighlight(Offset(cx - 15 * s, cy - 5 * s), Offset(cx + 5 * s, cy + 15 * s), opacity: 0.4);
    final hlPath = Path()
      ..moveTo(cx - 3 * s, cy - 22 * s)
      ..quadraticBezierTo(cx - 12 * s, cy - 2 * s, cx - 8 * s, cy + 12 * s)
      ..quadraticBezierTo(cx - 5 * s, cy + 20 * s, cx, cy + 20 * s)
      ..quadraticBezierTo(cx - 8 * s, cy + 18 * s, cx - 12 * s, cy + 8 * s)
      ..quadraticBezierTo(cx - 16 * s, cy - 4 * s, cx - 3 * s, cy - 22 * s)
      ..close();
    canvas.drawPath(hlPath, hl);

    // Small specular sparkle near top
    final sparkle = Paint()..color = Colors.white.withValues(alpha: 0.5);
    canvas.drawCircle(Offset(cx - 4 * s, cy - 14 * s), 2.5 * s, sparkle);

    drawInnerShadow(canvas, size);
  }
}

// ═══════════════════════════════════════════════════════════════
// 4. THERMOMETER — Fever / Pain
// ═══════════════════════════════════════════════════════════════
class ThermometerIconPainter extends ConditionIconPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 100;

    // Glass tube (outer)
    final tube = Paint()
      ..shader = ui.Gradient.linear(Offset(cx - 8 * s, cy - 30 * s), Offset(cx + 8 * s, cy + 20 * s), [
        Colors.white.withValues(alpha: 0.1),
        const Color(0xFFE8E8E8).withValues(alpha: 0.15),
        Colors.white.withValues(alpha: 0.05),
      ])
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - 32 * s), Offset(cx, cy + 18 * s), tube);

    // Mercury column (red)
    final merc = Paint()
      ..shader = ui.Gradient.linear(Offset(cx - 3 * s, cy + 10 * s), Offset(cx + 3 * s, cy - 20 * s), [
        const Color(0xFFE63946),
        const Color(0xFFD62828),
        const Color(0xFFB71C1C),
      ])
      ..strokeWidth = 4 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy + 14 * s), Offset(cx, cy - 6 * s), merc);

    // Mercury bulb (bottom)
    final bulb = Paint()
      ..shader = ui.Gradient.radial(Offset(cx - 2 * s, cy + 20 * s), 10 * s, [
        const Color(0xFFE63946),
        const Color(0xFFB71C1C),
      ]);
    canvas.drawCircle(Offset(cx, cy + 18 * s), 7 * s, bulb);

    // Glass highlight on bulb
    final bulbHl = Paint()
      ..shader = glassHighlight(Offset(cx - 5 * s, cy + 14 * s), Offset(cx + 2 * s, cy + 22 * s), opacity: 0.35);
    canvas.drawCircle(Offset(cx - 2 * s, cy + 16 * s), 4 * s, bulbHl);

    // Temperature markings
    final mark = Paint()
      ..color = const Color(0xFF8A9B93).withValues(alpha: 0.5)
      ..strokeWidth = 1.2 * s
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 5; i++) {
      final my = cy - 24 * s + i * 8 * s;
      canvas.drawLine(Offset(cx - 7 * s, my), Offset(cx - 4 * s, my), mark);
    }

    // Glass tube inner highlight
    final tubeHl = Paint()
      ..shader = glassHighlight(Offset(cx - 11 * s, cy - 20 * s), Offset(cx, cy + 10 * s), opacity: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 3 * s, cy - 30 * s), Offset(cx - 3 * s, cy + 16 * s), tubeHl);

    // Heat waves (small wavy lines near top)
    final heat = Paint()
      ..color = const Color(0xFFE63946).withValues(alpha: 0.3)
      ..strokeWidth = 1.2 * s
      ..style = PaintingStyle.stroke;
    final hPath = Path()
      ..moveTo(cx + 12 * s, cy - 26 * s)
      ..relativeQuadraticBezierTo(4 * s, -3 * s, 2 * s, -6 * s)
      ..moveTo(cx + 16 * s, cy - 22 * s)
      ..relativeQuadraticBezierTo(4 * s, -3 * s, 2 * s, -6 * s);
    canvas.drawPath(hPath, heat);

    drawInnerShadow(canvas, size);
  }
}

// ═══════════════════════════════════════════════════════════════
// 5. KIDNEY — UTI
// ═══════════════════════════════════════════════════════════════
class KidneyIconPainter extends ConditionIconPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 100;

    // Kidney bean shape (left)
    final kidneyL = Paint()
      ..shader = ui.Gradient.linear(Offset(cx - 22 * s, cy - 5 * s), Offset(cx + 5 * s, cy + 10 * s), [
        Color(0xFFC47A68).withValues(alpha: 0.7),
        Color(0xFFA85D4A).withValues(alpha: 0.6),
        Color(0xFF8B4535).withValues(alpha: 0.5),
      ]);
    final klPath = Path()
      ..moveTo(cx - 10 * s, cy + 2 * s)
      ..quadraticBezierTo(cx - 8 * s, cy - 20 * s, cx - 22 * s, cy - 14 * s)
      ..quadraticBezierTo(cx - 34 * s, cy - 8 * s, cx - 26 * s, cy + 8 * s)
      ..quadraticBezierTo(cx - 20 * s, cy + 20 * s, cx - 8 * s, cy + 14 * s)
      ..quadraticBezierTo(cx - 6 * s, cy + 10 * s, cx - 10 * s, cy + 2 * s)
      ..close();
    canvas.drawPath(klPath, kidneyL);

    // Left kidney highlight
    final klh = Paint()
      ..shader = glassHighlight(Offset(cx - 28 * s, cy - 14 * s), Offset(cx - 10 * s, cy + 8 * s), opacity: 0.25);
    canvas.drawPath(klPath, klh);

    // Kidney bean shape (right)
    final kidneyR = Paint()
      ..shader = ui.Gradient.linear(Offset(cx + 5 * s, cy - 5 * s), Offset(cx + 22 * s, cy + 10 * s), [
        Color(0xFFC47A68).withValues(alpha: 0.7),
        Color(0xFFA85D4A).withValues(alpha: 0.6),
        Color(0xFF8B4535).withValues(alpha: 0.5),
      ]);
    final krPath = Path()
      ..moveTo(cx + 10 * s, cy + 2 * s)
      ..quadraticBezierTo(cx + 8 * s, cy - 20 * s, cx + 22 * s, cy - 14 * s)
      ..quadraticBezierTo(cx + 34 * s, cy - 8 * s, cx + 26 * s, cy + 8 * s)
      ..quadraticBezierTo(cx + 20 * s, cy + 20 * s, cx + 8 * s, cy + 14 * s)
      ..quadraticBezierTo(cx + 6 * s, cy + 10 * s, cx + 10 * s, cy + 2 * s)
      ..close();
    canvas.drawPath(krPath, kidneyR);

    // Right kidney highlight
    final krh = Paint()
      ..shader = glassHighlight(Offset(cx + 10 * s, cy - 14 * s), Offset(cx + 28 * s, cy + 8 * s), opacity: 0.25);
    canvas.drawPath(krPath, krh);

    // Ureters (tubes going down)
    final ureter = Paint()
      ..color = Color(0xFFC47A68).withValues(alpha: 0.4)
      ..strokeWidth = 2 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 14 * s, cy + 14 * s), Offset(cx - 8 * s, cy + 26 * s), ureter);
    canvas.drawLine(Offset(cx + 14 * s, cy + 14 * s), Offset(cx + 8 * s, cy + 26 * s), ureter);

    // Ureter highlights
    final uh = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 0.8 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 15 * s, cy + 14 * s), Offset(cx - 9 * s, cy + 26 * s), uh);
    canvas.drawLine(Offset(cx + 13 * s, cy + 14 * s), Offset(cx + 7 * s, cy + 26 * s), uh);

    drawInnerShadow(canvas, size);
  }
}

// ═══════════════════════════════════════════════════════════════
// 6. THROAT / TONSIL — Tonsillitis
// ═══════════════════════════════════════════════════════════════
class ThroatIconPainter extends ConditionIconPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 100;

    // Open mouth / throat cavity
    final mouth = Paint()
      ..shader = ui.Gradient.radial(Offset(cx, cy + 5 * s), 35 * s, [
        Color(0xFF6B2020).withValues(alpha: 0.6),
        Color(0xFF4A1515).withValues(alpha: 0.7),
        Color(0xFF2A0808).withValues(alpha: 0.8),
      ]);
    final mouthPath = Path()
      ..moveTo(cx - 24 * s, cy - 6 * s)
      ..quadraticBezierTo(cx - 20 * s, cy - 22 * s, cx, cy - 22 * s)
      ..quadraticBezierTo(cx + 20 * s, cy - 22 * s, cx + 24 * s, cy - 6 * s)
      ..quadraticBezierTo(cx + 28 * s, cy + 10 * s, cx + 16 * s, cy + 18 * s)
      ..quadraticBezierTo(cx, cy + 24 * s, cx - 16 * s, cy + 18 * s)
      ..quadraticBezierTo(cx - 28 * s, cy + 10 * s, cx - 24 * s, cy - 6 * s)
      ..close();
    canvas.drawPath(mouthPath, mouth);

    // Tongue
    final tongue = Paint()
      ..shader = ui.Gradient.linear(Offset(cx - 10 * s, cy + 8 * s), Offset(cx + 10 * s, cy + 18 * s), [
        Color(0xFFD46858).withValues(alpha: 0.6),
        Color(0xFFB84A3A).withValues(alpha: 0.5),
      ]);
    final tonguePath = Path()
      ..moveTo(cx - 10 * s, cy + 6 * s)
      ..quadraticBezierTo(cx - 14 * s, cy + 12 * s, cx - 8 * s, cy + 18 * s)
      ..quadraticBezierTo(cx, cy + 22 * s, cx + 8 * s, cy + 18 * s)
      ..quadraticBezierTo(cx + 14 * s, cy + 12 * s, cx + 10 * s, cy + 6 * s)
      ..close();
    canvas.drawPath(tonguePath, tongue);

    // Tongue highlight
    final th = Paint()
      ..shader = glassHighlight(Offset(cx - 8 * s, cy + 8 * s), Offset(cx + 4 * s, cy + 16 * s), opacity: 0.2);
    canvas.drawPath(tonguePath, th);

    // Uvula (small hanging thing)
    final uvula = Paint()
      ..shader = ui.Gradient.linear(Offset(cx - 2 * s, cy - 8 * s), Offset(cx + 2 * s, cy - 2 * s), [
        Color(0xFFD46858).withValues(alpha: 0.5),
        Color(0xFFB84A3A).withValues(alpha: 0.4),
      ]);
    canvas.drawCircle(Offset(cx, cy - 4 * s), 3.5 * s, uvula);

    // Inflamed tonsils (sides)
    final tonsil = Paint()
      ..shader = ui.Gradient.radial(Offset(cx - 18 * s, cy + 2 * s), 10 * s, [
        Color(0xFFE63946).withValues(alpha: 0.5),
        Color(0xFFB71C1C).withValues(alpha: 0.3),
      ]);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 18 * s, cy + 2 * s), width: 10 * s, height: 12 * s), tonsil);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 18 * s, cy + 2 * s), width: 10 * s, height: 12 * s), tonsil);

    // Subtle glass reflection on mouth
    final mouthHl = Paint()
      ..shader = glassHighlight(Offset(cx - 16 * s, cy - 16 * s), Offset(cx + 8 * s, cy - 4 * s), opacity: 0.1);
    final mhPath = Path()
      ..moveTo(cx - 14 * s, cy - 14 * s)
      ..quadraticBezierTo(cx, cy - 18 * s, cx + 14 * s, cy - 14 * s)
      ..quadraticBezierTo(cx + 10 * s, cy - 12 * s, cx, cy - 12 * s)
      ..quadraticBezierTo(cx - 10 * s, cy - 12 * s, cx - 14 * s, cy - 14 * s)
      ..close();
    canvas.drawPath(mhPath, mouthHl);

    drawInnerShadow(canvas, size);
  }
}

// ═══════════════════════════════════════════════════════════════
// 7. EAR — Ear Infection
// ═══════════════════════════════════════════════════════════════
class EarIconPainter extends ConditionIconPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 100;

    // Outer ear (pinna)
    final outer = Paint()
      ..shader = ui.Gradient.linear(Offset(cx - 20 * s, cy - 10 * s), Offset(cx + 15 * s, cy + 10 * s), [
        Color(0xFFE8B8A0).withValues(alpha: 0.6),
        Color(0xFFD49880).withValues(alpha: 0.5),
        Color(0xFFB87A60).withValues(alpha: 0.4),
      ]);
    final outerPath = Path()
      ..moveTo(cx + 16 * s, cy + 2 * s)
      ..quadraticBezierTo(cx + 20 * s, cy - 18 * s, cx, cy - 24 * s)
      ..quadraticBezierTo(cx - 20 * s, cy - 18 * s, cx - 18 * s, cy + 2 * s)
      ..quadraticBezierTo(cx - 16 * s, cy + 22 * s, cx, cy + 26 * s)
      ..quadraticBezierTo(cx + 16 * s, cy + 22 * s, cx + 16 * s, cy + 2 * s)
      ..close();
    canvas.drawPath(outerPath, outer);

    // Outer ear highlight
    final oh = Paint()
      ..shader = glassHighlight(Offset(cx - 14 * s, cy - 18 * s), Offset(cx + 6 * s, cy + 8 * s), opacity: 0.25);
    canvas.drawPath(outerPath, oh);

    // Inner ear (helix/concha)
    final inner = Paint()
      ..shader = ui.Gradient.radial(Offset(cx - 2 * s, cy + 2 * s), 18 * s, [
        Color(0xFFC47A68).withValues(alpha: 0.3),
        Color(0xFFA85D4A).withValues(alpha: 0.25),
        Colors.transparent,
      ]);
    final innerPath = Path()
      ..moveTo(cx - 6 * s, cy - 6 * s)
      ..quadraticBezierTo(cx - 12 * s, cy - 12 * s, cx - 4 * s, cy - 16 * s)
      ..quadraticBezierTo(cx + 6 * s, cy - 12 * s, cx + 8 * s, cy - 2 * s)
      ..quadraticBezierTo(cx + 10 * s, cy + 8 * s, cx + 4 * s, cy + 14 * s)
      ..quadraticBezierTo(cx - 4 * s, cy + 18 * s, cx - 8 * s, cy + 12 * s)
      ..quadraticBezierTo(cx - 12 * s, cy + 6 * s, cx - 6 * s, cy - 6 * s)
      ..close();
    canvas.drawPath(innerPath, inner);

    // Ear canal
    final canal = Paint()
      ..shader = ui.Gradient.radial(Offset(cx + 2 * s, cy + 2 * s), 8 * s, [
        Color(0xFF5C2A1A).withValues(alpha: 0.5),
        Color(0xFF3D1A10).withValues(alpha: 0.4),
      ]);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 2 * s, cy + 2 * s), width: 8 * s, height: 12 * s), canal);

    // Helix ridge
    final ridge = Paint()
      ..color = Color(0xFFE8B8A0).withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * s;
    final rPath = Path()
      ..moveTo(cx + 12 * s, cy - 10 * s)
      ..quadraticBezierTo(cx + 4 * s, cy - 18 * s, cx - 8 * s, cy - 14 * s);
    canvas.drawPath(rPath, ridge);

    // Inflammation glow (ear infection indicator)
    final inflame = Paint()
      ..shader = ui.Gradient.radial(Offset(cx + 2 * s, cy + 2 * s), 15 * s, [
        Color(0xFFE63946).withValues(alpha: 0.15),
        Colors.transparent,
      ]);
    canvas.drawCircle(Offset(cx + 2 * s, cy + 2 * s), 15 * s, inflame);

    drawInnerShadow(canvas, size);
  }
}

// ═══════════════════════════════════════════════════════════════
// 8. INHALER — Asthma / Wheeze
// ═══════════════════════════════════════════════════════════════
class InhalerIconPainter extends ConditionIconPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = size.width / 100;

    // Canister body (main cylinder)
    final canister = Paint()
      ..shader = ui.Gradient.linear(Offset(cx - 15 * s, cy - 20 * s), Offset(cx + 15 * s, cy + 20 * s), [
        Color(0xFF4A90D9).withValues(alpha: 0.7),
        Color(0xFF2A6BB8).withValues(alpha: 0.8),
        Color(0xFF1A4A8A).withValues(alpha: 0.7),
      ]);
    final canPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 22 * s, height: 36 * s),
        const Radius.circular(8),
      ));
    canvas.drawPath(canPath, canister);

    // Glass highlight on canister (left side)
    final ch = Paint()
      ..shader = glassHighlight(Offset(cx - 14 * s, cy - 14 * s), Offset(cx - 2 * s, cy + 14 * s), opacity: 0.3);
    final chPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 5 * s, cy), width: 7 * s, height: 30 * s),
        const Radius.circular(4),
      ));
    canvas.drawPath(chPath, ch);

    // Mouthpiece (top)
    final mouthpiece = Paint()
      ..shader = ui.Gradient.linear(Offset(cx - 6 * s, cy - 22 * s), Offset(cx + 6 * s, cy - 16 * s), [
        Color(0xFFE8E8E8).withValues(alpha: 0.6),
        Color(0xFFC0C0C0).withValues(alpha: 0.5),
      ]);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 22 * s), width: 12 * s, height: 6 * s),
        const Radius.circular(3),
      ),
      mouthpiece,
    );

    // Nozzle opening
    final nozzle = Paint()
      ..color = Color(0xFF2A1A10).withValues(alpha: 0.5);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - 26 * s), width: 4 * s, height: 3 * s), nozzle);

    // Medicinal mist clouds
    final mist = Paint()
      ..shader = ui.Gradient.radial(Offset(cx, cy - 36 * s), 20 * s, [
        Colors.white.withValues(alpha: 0.3),
        Colors.white.withValues(alpha: 0.1),
        Colors.transparent,
      ]);
    canvas.drawCircle(Offset(cx, cy - 36 * s), 16 * s, mist);

    // Small mist particles
    final particle = Paint()..color = Colors.white.withValues(alpha: 0.25);
    canvas.drawCircle(Offset(cx - 6 * s, cy - 40 * s), 3 * s, particle);
    canvas.drawCircle(Offset(cx + 5 * s, cy - 42 * s), 2 * s, particle);
    canvas.drawCircle(Offset(cx, cy - 46 * s), 2.5 * s, particle);

    // Mist particle highlights
    final ph = Paint()..color = Colors.white.withValues(alpha: 0.15);
    canvas.drawCircle(Offset(cx - 8 * s, cy - 44 * s), 1.5 * s, ph);
    canvas.drawCircle(Offset(cx + 3 * s, cy - 38 * s), 1.8 * s, ph);

    // Bottom cap
    final cap = Paint()
      ..shader = ui.Gradient.linear(Offset(cx - 6 * s, cy + 18 * s), Offset(cx + 6 * s, cy + 22 * s), [
        Color(0xFFE8E8E8).withValues(alpha: 0.5),
        Color(0xFFC0C0C0).withValues(alpha: 0.4),
      ]);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 20 * s), width: 12 * s, height: 4 * s),
        const Radius.circular(2),
      ),
      cap,
    );

    drawInnerShadow(canvas, size);
  }
}
