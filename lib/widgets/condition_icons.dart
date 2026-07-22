<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
=======
import 'package:flutter/widgets.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
>>>>>>> ab7aec0 (UI/UX overhaul: Emerald palette, DoseLogoTile branding, Apple-style animations)

/// Mapping from condition/category ID to icons.
///
/// Top 6 pinned conditions use realistic emoji for instant recognition.
/// All other conditions and categories use Lucide line icons.
class ConditionIcons {
  const ConditionIcons._();

  /// Returns a realistic emoji for the top pinned conditions.
  ///
  /// Supports both pediatric and adult condition IDs.
  /// Returns null for non-pinned conditions (use [iconFor] instead).
  static String? emojiFor(String illnessId) {
    switch (illnessId) {
      // Pediatric top 6
      case 'malaria':
        return '🦟';
      case 'pneumonia':
        return '🫁';
      case 'diarrhea':
        return '💧';
      case 'fluids':
        return '💉';
      case 'tonsillitis':
        return '🩺';
      case 'asthma':
        return '🌬️';
      // Adult top 6
      case 'hypertension':
        return '🫀';
      case 'diabetes':
        return '💉';
      case 'uti':
        return '🫧';
      case 'dyspepsia':
        return '🤢';
      case 'hyperemesis':
        return '🤰';
      default:
        return null;
    }
  }

  /// Returns the Lucide icon for the given [illnessId].
  ///
  /// Falls back to [LucideIcons.heart] when no matching icon is found.
  static IconData iconFor(String illnessId) {
    switch (illnessId) {
      case 'malaria':
        return LucideIcons.bug;
      case 'pneumonia':
        return LucideIcons.stethoscope;
      case 'diarrhea':
        return LucideIcons.droplets;
      case 'fever':
        return LucideIcons.thermometer;
      case 'uti':
        return LucideIcons.ambulance;
      case 'tonsillitis':
        return LucideIcons.microscope;
      case 'otitis_media':
        return LucideIcons.ear;
      case 'asthma':
        return LucideIcons.wind;
      case 'hypertension':
        return LucideIcons.heart_pulse;
      case 'diabetes':
        return LucideIcons.syringe;
      case 'dyspepsia':
        return LucideIcons.pill;
      case 'typhoid':
        return LucideIcons.thermometer;
      case 'fluids':
        return LucideIcons.droplet;
      case 'giardiasis':
        return LucideIcons.bug;
      case 'amebiasis':
        return LucideIcons.bug;
      case 'measles':
        return LucideIcons.bug;
      case 'chickenpox':
        return LucideIcons.circle_alert;
      case 'scabies':
        return LucideIcons.scan;
      case 'eczema':
        return LucideIcons.scan_line;
      case 'tinea':
        return LucideIcons.bug;
      case 'cellulitis':
        return LucideIcons.skull;
      case 'sinusitis':
        return LucideIcons.microscope;
      case 'hyperemesis':
        return LucideIcons.pill;
      case 'renal_stone':
        return LucideIcons.ambulance;
      default:
        return LucideIcons.heart;
    }
  }

  /// Returns the Lucide icon for a body-system [categoryId].
  static IconData categoryIconFor(String categoryId) {
    switch (categoryId) {
      case 'respiratory':
        return LucideIcons.stethoscope;
      case 'git':
        return LucideIcons.pill;
      case 'infectious':
        return LucideIcons.bug;
      case 'ent':
        return LucideIcons.ear;
      case 'renal':
        return LucideIcons.ambulance;
      case 'dermatology':
      case 'skin':
        return LucideIcons.scan_line;
      case 'cardiovascular':
        return LucideIcons.heart_pulse;
      case 'endocrine':
        return LucideIcons.droplets;
      default:
        return LucideIcons.folder_open;
    }
  }
}
