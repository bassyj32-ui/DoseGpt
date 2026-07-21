import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Mapping from condition ID to Phosphor duotone icon data.
///
/// Each icon uses [PhosphorIconsDuotone] so that icons render with a
/// primary + secondary colour, giving a polished, premium medical-app
/// look while keeping the code minimal (one line per illness instead of
/// 30+ lines of CustomPainter paths).
class ConditionIcons {
  const ConditionIcons._();

  /// Returns the duotone icon data for the given [illnessId].
  ///
  /// Falls back to [PhosphorIconsDuotone.heartbeat] when no matching
  /// icon is found.
  static IconData iconFor(String illnessId) {
    switch (illnessId) {
      case 'malaria':
        return PhosphorIconsDuotone.bugBeetle;
      case 'pneumonia':
        return PhosphorIconsDuotone.stethoscope;
      case 'diarrhea':
        return PhosphorIconsDuotone.drop;
      case 'fever':
        return PhosphorIconsDuotone.thermometerHot;
      case 'uti':
        return PhosphorIconsDuotone.dropHalf;
      case 'tonsillitis':
        return PhosphorIconsDuotone.microscope;
      case 'otitis_media':
        return PhosphorIconsDuotone.ear;
      case 'asthma':
        return PhosphorIconsDuotone.syringe;
      case 'hypertension':
        return PhosphorIconsDuotone.heartbeat;
      case 'diabetes':
        return PhosphorIconsDuotone.dropHalf;
      case 'dyspepsia':
        return PhosphorIconsDuotone.pill;
      case 'typhoid':
        return PhosphorIconsDuotone.thermometerHot;
      case 'fluids':
        return PhosphorIconsDuotone.drop;
      case 'giardiasis':
        return PhosphorIconsDuotone.knife;
      case 'amebiasis':
        return PhosphorIconsDuotone.knife;
      case 'measles':
        return PhosphorIconsDuotone.thermometerHot;
      case 'chickenpox':
        return PhosphorIconsDuotone.scribbleLoop;
      case 'scabies':
        return PhosphorIconsDuotone.scribbleLoop;
      case 'eczema':
        return PhosphorIconsDuotone.scribbleLoop;
      case 'tinea':
        return PhosphorIconsDuotone.scribbleLoop;
      case 'cellulitis':
        return PhosphorIconsDuotone.scribbleLoop;
      case 'sinusitis':
        return PhosphorIconsDuotone.microscope;
      case 'hyperemesis':
        return PhosphorIconsDuotone.knife;
      case 'renal_stone':
        return PhosphorIconsDuotone.dropHalf;
      default:
        return PhosphorIconsDuotone.heartbeat;
    }
  }

  /// Returns the duotone icon data for a category by its [categoryId].
  ///
  /// Categories are body-system groups (e.g. "respiratory", "git", "cvs")
  /// that appear as navigation cards on the home screen.
  static IconData categoryIconFor(String categoryId) {
    switch (categoryId) {
      case 'respiratory':
        return PhosphorIconsDuotone.stethoscope;
      case 'git':
        return PhosphorIconsDuotone.knife;
      case 'infectious':
        return PhosphorIconsDuotone.bugBeetle;
      case 'ent':
        return PhosphorIconsDuotone.ear;
      case 'renal':
        return PhosphorIconsDuotone.dropHalf;
      case 'dermatology':
      case 'skin':
        return PhosphorIconsDuotone.scribbleLoop;
      case 'cardiovascular':
        return PhosphorIconsDuotone.heartbeat;
      case 'endocrine':
        return PhosphorIconsDuotone.drop;
      default:
        return PhosphorIconsDuotone.folder;
    }
  }
}
