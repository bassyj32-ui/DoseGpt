class Illness {
  final String id;
  final String nameEn;
  final String nameAm;
  final String icon;
  final int displayOrder;
  final bool urgentAccent;
  final List<String> drugIds;

  Illness({
    required this.id,
    required this.nameEn,
    required this.nameAm,
    required this.icon,
    required this.displayOrder,
    required this.urgentAccent,
    required this.drugIds,
  });

  factory Illness.fromJson(Map<String, dynamic> json) {
    return Illness(
      id: json['id'] as String,
      nameEn: json['name_en'] as String,
      nameAm: json['name_am'] as String? ?? '',
      icon: json['icon'] as String,
      displayOrder: json['display_order'] as int,
      urgentAccent: json['urgent_accent'] as bool,
      drugIds: List<String>.from(json['drug_ids'] as List),
    );
  }
}
