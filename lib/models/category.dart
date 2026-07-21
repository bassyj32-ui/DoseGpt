/// A body-system category that groups related illnesses together.
///
/// Categories are used on the Home Screen to organise illnesses into
/// clinically meaningful groups (e.g. "Respiratory / Chest", "Gastrointestinal").
/// Categories that have a `displayOrder` <= the configured `maxDefaultCards`
/// will appear as top-level condition cards, while the rest are shown as
/// category cards that navigate to a sub-screen.
class Category {
  final String id;
  final String nameEn;
  final String icon;
  final int displayOrder;
  final List<String> illnessIds;

  Category({
    required this.id,
    required this.nameEn,
    required this.icon,
    required this.displayOrder,
    required this.illnessIds,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      displayOrder: json['display_order'] as int,
      illnessIds: List<String>.from(json['illness_ids'] as List? ?? []),
    );
  }

  /// The illnesses in this category all share the same icon identifier;
  /// a convenience getter that lets you use the category's icon for the
  /// group header.
  String get categoryIcon => icon;
}
