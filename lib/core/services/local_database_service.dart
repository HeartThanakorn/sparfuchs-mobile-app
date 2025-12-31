import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Local database service using Hive for offline-first storage
class LocalDatabaseService {
  static const String _receiptsBoxName = 'receipts';
  static const String _productsBoxName = 'products';
  static const String _settingsBoxName = 'settings';

  static bool _initialized = false;

  /// Initialize Hive database
  static Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();
    
    // Open boxes
    await Hive.openBox<Map>(_receiptsBoxName);
    await Hive.openBox<Map>(_productsBoxName);
    await Hive.openBox<dynamic>(_settingsBoxName);

    _initialized = true;
    debugPrint('LocalDatabaseService: Initialized');
  }

  /// Get receipts box
  static Box<Map> get receiptsBox => Hive.box<Map>(_receiptsBoxName);

  /// Get products box  
  static Box<Map> get productsBox => Hive.box<Map>(_productsBoxName);

  /// Get settings box
  static Box<dynamic> get settingsBox => Hive.box<dynamic>(_settingsBoxName);

  /// Get local images directory
  static Future<Directory> getImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/receipt_images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  /// Close all boxes
  static Future<void> close() async {
    await Hive.close();
    _initialized = false;
  }
}
