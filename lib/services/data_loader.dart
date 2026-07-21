import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/illness.dart';
import '../models/drug.dart';
import '../models/category.dart';

class ClinicalData {
  final List<Illness> illnesses;
  final Map<String, Illness> illnessMap;
  final Map<String, Drug> drugMap;
  final Map<String, MetaInfo> meta;
  final List<Category> categories;
  final Map<String, Category> categoryMap;

  ClinicalData({
    required this.illnesses,
    required this.illnessMap,
    required this.drugMap,
    required this.meta,
    required this.categories,
    required this.categoryMap,
  });

  Drug? getDrug(String id) => drugMap[id];
  Illness? getIllness(String id) => illnessMap[id];
  List<Drug> getDrugsForIllness(String illnessId) {
    final illness = illnessMap[illnessId];
    if (illness == null) return [];
    return illness.drugIds
        .map((id) => drugMap[id])
        .whereType<Drug>()
        .toList();
  }

  Drug? getRecommendedDrug(String illnessId) {
    final illness = illnessMap[illnessId];
    if (illness == null) return null;
    final firstDrug = drugMap[illness.drugIds.first];
    return firstDrug;
  }

  /// Returns the category that contains the given [illnessId], or null.
  Category? categoryForIllness(String illnessId) {
    for (final category in categories) {
      if (category.illnessIds.contains(illnessId)) return category;
    }
    return null;
  }

  /// Returns all illnesses that belong to the given [categoryId],
  /// sorted by their display_order.
  List<Illness> getIllnessesForCategory(String categoryId) {
    final category = categoryMap[categoryId];
    if (category == null) return [];
    return category.illnessIds
        .map((id) => illnessMap[id])
        .whereType<Illness>()
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }
}

class MetaInfo {
  final String schemaVersion;
  final String datasetVersion;
  final String datasetStatus;
  final String datasetLastUpdated;
  final List<String> reviewedBy;
  final String notes;

  MetaInfo({
    required this.schemaVersion,
    required this.datasetVersion,
    required this.datasetStatus,
    required this.datasetLastUpdated,
    required this.reviewedBy,
    required this.notes,
  });

  factory MetaInfo.fromJson(Map<String, dynamic> json) {
    return MetaInfo(
      schemaVersion: json['schema_version'] as String,
      datasetVersion: json['dataset_version'] as String,
      datasetStatus: json['dataset_status'] as String,
      datasetLastUpdated: json['dataset_last_updated'] as String,
      reviewedBy: List<String>.from(json['reviewed_by'] as List? ?? []),
      notes: json['notes'] as String,
    );
  }
}

class DataLoader {
  /// Load the pediatric dataset (illnesses.json + drugs.json + meta.json + pediatric_categories.json)
  static Future<ClinicalData> loadPediatric() async {
    return loadFrom(
      illnessesPath: 'lib/data/illnesses.json',
      drugsPath: 'lib/data/drugs.json',
      metaPath: 'lib/data/meta.json',
      categoriesPath: 'lib/data/pediatric_categories.json',
    );
  }

  /// Load the adult dataset (adult_illnesses.json + adult_drugs.json + meta.json + adult_categories.json)
  static Future<ClinicalData> loadAdult() async {
    return loadFrom(
      illnessesPath: 'lib/data/adult_illnesses.json',
      drugsPath: 'lib/data/adult_drugs.json',
      metaPath: 'lib/data/meta.json',
      categoriesPath: 'lib/data/adult_categories.json',
    );
  }

  static Future<ClinicalData> loadFrom({
    required String illnessesPath,
    required String drugsPath,
    required String metaPath,
    required String categoriesPath,
  }) async {
    final illnessesJson = jsonDecode(
      await rootBundle.loadString(illnessesPath),
    ) as Map<String, dynamic>;

    final drugsJson = jsonDecode(
      await rootBundle.loadString(drugsPath),
    ) as Map<String, dynamic>;

    final metaJson = jsonDecode(
      await rootBundle.loadString(metaPath),
    ) as Map<String, dynamic>;

    final categoriesJson = jsonDecode(
      await rootBundle.loadString(categoriesPath),
    ) as Map<String, dynamic>;

    final illnesses = (illnessesJson['illnesses'] as List)
        .map((e) => Illness.fromJson(e as Map<String, dynamic>))
        .toList();

    final drugs = (drugsJson['drugs'] as List)
        .map((e) => Drug.fromJson(e as Map<String, dynamic>))
        .toList();

    final meta = MetaInfo.fromJson(metaJson);

    final categories = (categoriesJson['categories'] as List)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();

    final illnessMap = <String, Illness>{};
    for (final illness in illnesses) {
      illnessMap[illness.id] = illness;
    }

    final drugMap = <String, Drug>{};
    for (final drug in drugs) {
      drugMap[drug.id] = drug;
    }

    final categoryMap = <String, Category>{};
    for (final category in categories) {
      categoryMap[category.id] = category;
    }

    return ClinicalData(
      illnesses: illnesses,
      illnessMap: illnessMap,
      drugMap: drugMap,
      meta: {'meta': meta},
      categories: categories,
      categoryMap: categoryMap,
    );
  }
}
