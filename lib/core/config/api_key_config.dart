import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Secure API key configuration
/// 
/// Uses different sources based on build mode:
/// - Debug: flutter_dotenv (.env file)
/// - Release: --dart-define compile-time constants
/// 
/// Usage:
/// ```dart
/// await ApiKeyConfig.initialize();
/// final apiKey = ApiKeyConfig.geminiApiKey;
/// ```
class ApiKeyConfig {
  static bool _initialized = false;

  /// Initialize the API key configuration
  /// Call this in main() before runApp()
  static Future<void> initialize() async {
    if (_initialized) return;

    // Load environment variables (debug & release)
    try {
      await dotenv.load(fileName: '.env');
      debugPrint('ApiKeyConfig: Loaded .env file');
    } catch (e) {
      debugPrint('ApiKeyConfig: .env file not found/loaded ($e)');
    }

    _initialized = true;
    debugPrint('ApiKeyConfig: Initialized (debug=$kDebugMode)');
  }

  /// Get Gemini API key
  /// Priority: 
  /// 1. --dart-define (compile-time)
  /// 2. .env file (debug only)
  static String get geminiApiKey {
    // First try dart-define (works in both debug and release)
    const dartDefineKey = String.fromEnvironment('GEMINI_API_KEY');
    if (dartDefineKey.isNotEmpty) {
      return dartDefineKey;
    }

    // Try .env file (fallback for both debug and release if bundled)
    final envKey = dotenv.env['GEMINI_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }

    // No key found
    throw ApiKeyNotConfiguredException(
      'GEMINI_API_KEY is not configured. '
      'Set it in .env file (debug) or use --dart-define (release)',
    );
  }

  /// Check if Gemini API key is available
  static bool get hasGeminiApiKey {
    try {
      geminiApiKey;
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Exception thrown when API key is not configured
class ApiKeyNotConfiguredException implements Exception {
  final String message;
  ApiKeyNotConfiguredException(this.message);

  @override
  String toString() => 'ApiKeyNotConfiguredException: $message';
}
