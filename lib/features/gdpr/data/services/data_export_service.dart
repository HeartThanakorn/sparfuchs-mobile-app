import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service for GDPR-compliant data export
class DataExportService {
  final FirebaseFirestore _firestore;

  DataExportService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Exports all user data as a JSON file
  /// 
  /// Returns the path to the exported file
  Future<String> exportUserData(String userId) async {
    try {
      debugPrint('DataExportService: Starting export for $userId');

      // Collect all user data
      final exportData = await _collectUserData(userId);

      // Add metadata
      final fullExport = {
        'exportDate': DateTime.now().toIso8601String(),
        'userId': userId,
        'version': '1.0',
        'data': exportData,
      };

      // Convert to JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(fullExport);

      // Save to file
      final filePath = await _saveToFile(jsonString, userId);

      debugPrint('DataExportService: Export completed - $filePath');
      return filePath;
    } catch (e) {
      debugPrint('DataExportService.exportUserData error: $e');
      rethrow;
    }
  }

  /// Collects all user data from Firestore
  Future<Map<String, dynamic>> _collectUserData(String userId) async {
    final data = <String, dynamic>{};

    // 1. Export receipts
    data['receipts'] = await _exportCollection(
      'receipts',
      where: 'userId',
      isEqualTo: userId,
    );

    // 2. Export households (where user is member)
    data['households'] = await _exportHouseholds(userId);

    // 3. Export warranty items
    data['warrantyItems'] = await _exportCollection(
      'warranty_items',
      where: 'userId',
      isEqualTo: userId,
    );

    // 4. Export user profile (if exists)
    data['profile'] = await _exportDocument('users', userId);

    // 5. Export user settings (if exists)
    data['settings'] = await _exportDocument('user_settings', userId);

    return data;
  }

  /// Exports all documents from a collection matching criteria
  Future<List<Map<String, dynamic>>> _exportCollection(
    String collection, {
    required String where,
    required String isEqualTo,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .where(where, isEqualTo: isEqualTo)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['_id'] = doc.id;
        return _convertTimestamps(data);
      }).toList();
    } catch (e) {
      debugPrint('DataExportService: Error exporting $collection - $e');
      return [];
    }
  }

  /// Exports households where user is a member
  Future<List<Map<String, dynamic>>> _exportHouseholds(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('households')
          .where('memberIds', arrayContains: userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['_id'] = doc.id;
        return _convertTimestamps(data);
      }).toList();
    } catch (e) {
      debugPrint('DataExportService: Error exporting households - $e');
      return [];
    }
  }

  /// Exports a single document
  Future<Map<String, dynamic>?> _exportDocument(
    String collection,
    String docId,
  ) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      data['_id'] = doc.id;
      return _convertTimestamps(data);
    } catch (e) {
      debugPrint('DataExportService: Error exporting $collection/$docId - $e');
      return null;
    }
  }

  /// Converts Firestore Timestamps to ISO strings for JSON compatibility
  Map<String, dynamic> _convertTimestamps(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is Timestamp) {
        return MapEntry(key, value.toDate().toIso8601String());
      } else if (value is Map<String, dynamic>) {
        return MapEntry(key, _convertTimestamps(value));
      } else if (value is List) {
        return MapEntry(
          key,
          value.map((item) {
            if (item is Map<String, dynamic>) {
              return _convertTimestamps(item);
            } else if (item is Timestamp) {
              return item.toDate().toIso8601String();
            }
            return item;
          }).toList(),
        );
      }
      return MapEntry(key, value);
    });
  }

  /// Saves JSON string to a file
  Future<String> _saveToFile(String jsonString, String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'sparfuchs_export_$timestamp.json';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsString(jsonString);

    return filePath;
  }

  /// Exports and shares the data file
  Future<void> exportAndShare(String userId) async {
    final filePath = await exportUserData(userId);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath)],
        subject: 'SparFuchs AI - Meine Daten',
        text: 'GDPR Datenexport von SparFuchs AI',
      ),
    );
  }

  /// Gets the size of exportable data (for preview)
  Future<Map<String, int>> getExportSummary(String userId) async {
    final summary = <String, int>{};

    // Count receipts
    final receiptsSnapshot = await _firestore
        .collection('receipts')
        .where('userId', isEqualTo: userId)
        .count()
        .get();
    summary['receipts'] = receiptsSnapshot.count ?? 0;

    // Count warranty items
    final warrantySnapshot = await _firestore
        .collection('warranty_items')
        .where('userId', isEqualTo: userId)
        .count()
        .get();
    summary['warrantyItems'] = warrantySnapshot.count ?? 0;

    // Count households
    final householdsSnapshot = await _firestore
        .collection('households')
        .where('memberIds', arrayContains: userId)
        .count()
        .get();
    summary['households'] = householdsSnapshot.count ?? 0;

    return summary;
  }
}
