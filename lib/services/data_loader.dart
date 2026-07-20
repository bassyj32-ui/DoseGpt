import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/illness.dart';
import '../models/drug.dart';

class ClinicalData {
  final List<Illness> illnesses;
  final Map<String, Illness> illnessMap;
  final Map<String, Drug> drugMap;
  final Map<String, MetaInfo> meta;

  ClinicalData({
    required this.illnesses,
    required this.illnessMap,
    required this.drugMap,
    required this.meta,
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
  /// Load the pediatric dataset (illnesses.json + drugs.json + meta.json)
  static Future<ClinicalData> loadPediatric() async {
    return loadFrom(
      illnessesPath: 'lib/data/illnesses.json',
      drugsPath: 'lib/data/drugs.json',
      metaPath: 'lib/data/meta.json',
    );
  }

  /// Load the adult dataset (adult_illnesses.json + adult_drugs.json + meta.json)
  static Future<ClinicalData> loadAdult() async {
    return loadFrom(
      illnessesPath: 'lib/data/adult_illnesses.json',
      drugsPath: 'lib/data/adult_drugs.json',
      metaPath: 'lib/data/meta.json',
    );
  }

  static Future<ClinicalData> loadFrom({
    required String illnessesPath,
    required String drugsPath,
    required String metaPath,
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

    final illnesses = (illnessesJson['illnesses'] as List)
        .map((e) => Illness.fromJson(e as Map<String, dynamic>))
        .toList();

    final drugs = (drugsJson['drugs'] as List)
        .map((e) => Drug.fromJson(e as Map<String, dynamic>))
        .toList();

    final meta = MetaInfo.fromJson(metaJson);

    final illnessMap = <String, Illness>{};
    for (final illness in illnesses) {
      illnessMap[illness.id] = illness;
    }

    final drugMap = <String, Drug>{};
    for (final drug in drugs) {
      drugMap[drug.id] = drug;
    }

    return ClinicalData(
      illnesses: illnesses,
      illnessMap: illnessMap,
      drugMap: drugMap,
      meta: {'meta': meta},
    );
  }
}
