import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:uuid/uuid.dart';

/// Service for scanning receipts via n8n AI backend
class ReceiptScanService {
  final http.Client _httpClient;
  final String _baseUrl;

  /// Request timeout duration
  static const Duration _timeout = Duration(seconds: 60);

  ReceiptScanService({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiEndpoints.n8nBaseUrl;

  /// Scans a receipt image using AI
  ///
  /// [imageUrl] - Firebase Storage download URL of the uploaded image
  /// [userId] - User ID for tracking and data association
  ///
  /// Returns a fully parsed [Receipt] object
  /// Throws [ReceiptScanException] on any error
  Future<Receipt> scanReceipt({
    required String imageUrl,
    required String userId,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiEndpoints.scanReceipt}');

      debugPrint('ReceiptScanService.scanReceipt: POST to $uri');

      // Build request body
      final requestBody = jsonEncode({
        'image_url': imageUrl,
        'user_id': userId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Make POST request with timeout
      final response = await _httpClient
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: requestBody,
          )
          .timeout(_timeout);

      debugPrint('ReceiptScanService.scanReceipt: Response ${response.statusCode}');

      // Handle response codes
      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseResponse(response.body, imageUrl, userId);
      } else if (response.statusCode == 400) {
        throw ReceiptScanException(
          'Ungültiges Bild oder Anfrage',
          code: 'BAD_REQUEST',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 422) {
        throw ReceiptScanException(
          'Kassenbon konnte nicht erkannt werden',
          code: 'UNPROCESSABLE',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode >= 500) {
        throw ReceiptScanException(
          'Server-Fehler, bitte später erneut versuchen',
          code: 'SERVER_ERROR',
          statusCode: response.statusCode,
        );
      } else {
        throw ReceiptScanException(
          'Unerwarteter Fehler: ${response.statusCode}',
          code: 'UNKNOWN',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw ReceiptScanException(
        'Zeitüberschreitung - Server antwortet nicht',
        code: 'TIMEOUT',
      );
    } on SocketException catch (e) {
      throw ReceiptScanException(
        'Keine Internetverbindung',
        code: 'NETWORK_ERROR',
        originalError: e,
      );
    } on FormatException catch (e) {
      throw ReceiptScanException(
        'Ungültige Serverantwort',
        code: 'PARSE_ERROR',
        originalError: e,
      );
    } on ReceiptScanException {
      rethrow;
    } catch (e) {
      throw ReceiptScanException(
        'Unbekannter Fehler: $e',
        code: 'UNKNOWN',
        originalError: e,
      );
    }
  }

  /// Parses the n8n response into a Receipt object
  Receipt _parseResponse(String body, String imageUrl, String userId) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;

      // Extract receipt_data from response
      final receiptDataJson = json['receipt_data'] as Map<String, dynamic>?;
      if (receiptDataJson == null) {
        throw ReceiptScanException(
          'Keine Belegdaten in Serverantwort',
          code: 'MISSING_DATA',
        );
      }

      // Parse ReceiptData
      final receiptData = ReceiptData.fromJson(receiptDataJson);

      // Check confidence score
      if (receiptData.aiMetadata.confidenceScore < ConfidenceThresholds.parsingFailed) {
        throw ReceiptScanException(
          'Beleg konnte nicht zuverlässig erkannt werden',
          code: 'LOW_CONFIDENCE',
        );
      }

      // Build complete Receipt object
      final now = DateTime.now();
      final receipt = Receipt(
        receiptId: const Uuid().v4(),
        userId: userId,
        householdId: null, // Set later if household feature is used
        imageUrl: imageUrl,
        isBookmarked: false,
        receiptData: receiptData,
        createdAt: now,
        updatedAt: now,
      );

      debugPrint('ReceiptScanService: Parsed receipt with ${receiptData.items.length} items');
      return receipt;
    } on FormatException catch (e) {
      throw ReceiptScanException(
        'Ungültiges JSON in Serverantwort',
        code: 'INVALID_JSON',
        originalError: e,
      );
    } on TypeError catch (e) {
      throw ReceiptScanException(
        'Unerwartetes Datenformat',
        code: 'TYPE_ERROR',
        originalError: e,
      );
    }
  }

  /// Checks if the n8n backend is available
  Future<bool> healthCheck() async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiEndpoints.health}');
      final response = await _httpClient.get(uri).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ReceiptScanService.healthCheck failed: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
  }
}

/// Exception class for receipt scanning errors
class ReceiptScanException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final Object? originalError;

  ReceiptScanException(
    this.message, {
    this.code,
    this.statusCode,
    this.originalError,
  });

  /// Whether this error is recoverable (user can retry)
  bool get isRetryable =>
      code == 'TIMEOUT' || code == 'NETWORK_ERROR' || code == 'SERVER_ERROR';

  /// Whether the image might be the problem (user should retake)
  bool get shouldRetakePhoto =>
      code == 'UNPROCESSABLE' || code == 'LOW_CONFIDENCE';

  @override
  String toString() => 'ReceiptScanException: $message (code: $code)';
}
