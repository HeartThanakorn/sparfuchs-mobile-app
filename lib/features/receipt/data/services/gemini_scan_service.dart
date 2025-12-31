import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:sparfuchs_ai/core/models/receipt.dart';

/// Service for scanning receipts using Gemini 2.5 Flash API
class GeminiScanService {
  static const String _apiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-05-20:generateContent';

  final String _apiKey;
  final http.Client _httpClient;

  GeminiScanService({
    required String apiKey,
    http.Client? httpClient,
  })  : _apiKey = apiKey,
        _httpClient = httpClient ?? http.Client();

  /// Scans a receipt image and returns parsed ReceiptData
  Future<ReceiptData> scanReceipt(File imageFile) async {
    final stopwatch = Stopwatch()..start();

    try {
      debugPrint('GeminiScanService: Starting receipt scan');

      // 1. Read and encode image
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // 2. Determine MIME type
      final mimeType = _getMimeType(imageFile.path);

      // 3. Call Gemini API
      final response = await _callGeminiApi(base64Image, mimeType);

      // 4. Parse response
      final receiptData = _parseResponse(response, stopwatch.elapsedMilliseconds);

      debugPrint('GeminiScanService: Scan completed in ${stopwatch.elapsedMilliseconds}ms');
      return receiptData;
    } catch (e) {
      debugPrint('GeminiScanService.scanReceipt error: $e');
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  /// Calls the Gemini API with the image
  Future<Map<String, dynamic>> _callGeminiApi(
    String base64Image,
    String mimeType,
  ) async {
    final uri = Uri.parse('$_apiEndpoint?key=$_apiKey');

    final requestBody = {
      'contents': [
        {
          'parts': [
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              }
            },
            {'text': _systemPrompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.1,
        'topK': 32,
        'topP': 1,
        'maxOutputTokens': 4096,
        'responseMimeType': 'application/json',
      }
    };

    final response = await _httpClient.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw GeminiApiException(
        'API call failed: ${response.statusCode}',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
    return jsonResponse;
  }

  /// Parses the Gemini API response into ReceiptData
  ReceiptData _parseResponse(Map<String, dynamic> response, int processingTimeMs) {
    try {
      // Extract text content from Gemini response structure
      final candidates = response['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw GeminiParseException('No candidates in response');
      }

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw GeminiParseException('No parts in response');
      }

      final textPart = parts[0]['text'] as String?;
      if (textPart == null) {
        throw GeminiParseException('No text in response');
      }

      // Parse the JSON from the text
      final receiptJson = jsonDecode(textPart) as Map<String, dynamic>;
      final receiptDataJson = receiptJson['receipt_data'] as Map<String, dynamic>?;

      if (receiptDataJson == null) {
        throw GeminiParseException('No receipt_data in response');
      }

      // Add processing time to ai_metadata
      if (receiptDataJson['ai_metadata'] != null) {
        (receiptDataJson['ai_metadata'] as Map<String, dynamic>)['processing_time_ms'] =
            processingTimeMs;
        (receiptDataJson['ai_metadata'] as Map<String, dynamic>)['model_used'] =
            'gemini-2.5-flash';
      }

      return ReceiptData.fromJson(receiptDataJson);
    } catch (e) {
      debugPrint('GeminiScanService._parseResponse error: $e');
      if (e is GeminiParseException) rethrow;
      throw GeminiParseException('Failed to parse receipt: $e');
    }
  }

  /// Gets MIME type from file extension
  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }

  /// The Golden Prompt for German receipt parsing
  static const String _systemPrompt = '''
You are a specialized German receipt parser for the SparFuchs AI expense tracking app. Your task is to extract structured data from receipt images with high accuracy.

## OUTPUT FORMAT
Return ONLY valid JSON matching this exact schema (no markdown, no explanations):

{
  "receipt_data": {
    "merchant": {
      "name": "<Store name: Lidl, Aldi, Rewe, DM, Edeka, Penny, Netto, Kaufland, etc.>",
      "branch_id": "<Store ID if visible, e.g., 'DE-12345'>",
      "address": "<Full address if visible>",
      "raw_text": "<Exact merchant text as printed>"
    },
    "transaction": {
      "date": "<YYYY-MM-DD format>",
      "time": "<HH:MM:SS 24h format>",
      "currency": "EUR",
      "payment_method": "<CASH or CARD>"
    },
    "items": [
      {
        "description": "<Product name - CORRECTED for OCR errors>",
        "category": "<Groceries|Beverages|Snacks|Household|Electronics|Fashion|Deposit|Other>",
        "quantity": <number>,
        "unit_price": <number with 2 decimals>,
        "total_price": <number with 2 decimals>,
        "discount": <negative number if discounted, null otherwise>,
        "is_discounted": <true/false>,
        "type": "<'pfand_bottle' for deposits, null otherwise>",
        "tags": ["<relevant tags>"]
      }
    ],
    "totals": {
      "subtotal": <number>,
      "pfand_total": <number - sum of all Pfand items>,
      "tax_amount": <number>,
      "grand_total": <number>
    },
    "taxes": [
      {"rate": 7.0, "amount": <food tax amount>},
      {"rate": 19.0, "amount": <non-food tax amount>}
    ],
    "ai_metadata": {
      "confidence_score": <0.0-1.0 based on image quality and parsing certainty>,
      "model_used": "gemini-2.5-flash",
      "processing_time_ms": null
    }
  }
}

## GERMAN RECEIPT PARSING RULES

### 1. PFAND (Deposit) Detection - CRITICAL
Identify ALL Pfand/deposit items. Common patterns:
- "Pfand", "PFAND", "Pfd", "Leergut"
- "Einweg", "Einwegpfand", "EW-Pfand" (€0.25)
- "Mehrweg", "Mehrwegpfand", "MW-Pfand" (€0.08-€0.15)
- Items with exactly €0.25, €0.15, or €0.08 unit price near beverages
- Set type: "pfand_bottle" and category: "Deposit" for ALL deposit items

### 2. OCR Error Corrections - MANDATORY
Fix common German receipt OCR errors:
- "Mwich" → "Milch"
- "8rot", "Br0t" → "Brot"
- "Kase", "K4se" → "Käse"
- Numbers confused with letters: 0↔O, 1↔l, 5↔S, 8↔B

### 3. German Abbreviations - EXPAND
- "Stk" / "St." → "Stück"
- "Pck" / "Pkg" → "Packung"
- "Fl." → "Flasche"
- "Bio" → Keep as "Bio"
- "TK" → "Tiefkühl"

### 4. Tax Rate Classification
- 7% (ermäßigt): Food, beverages, books
- 19% (normal): Non-food items, electronics

### 5. Discount Detection
- Look for: "Rabatt", "Aktion", "Angebot", "Reduziert", "-", "Ersparnis"
- Set is_discounted: true and capture discount as negative number

### 6. Payment Method Detection
- "BAR", "Bargeld" → "CASH"
- "EC", "Karte", "VISA", "Mastercard", "girocard" → "CARD"

### 7. Confidence Score Guidelines
- 1.0: Crystal clear image, all fields parsed confidently
- 0.8-0.9: Good quality, minor uncertainties
- 0.6-0.8: Some blurry areas, guessing required
- <0.6: Poor quality, significant guessing

## VALIDATION RULES
1. grand_total MUST equal subtotal + pfand_total (approximately)
2. Each item's total_price MUST equal quantity × unit_price (minus discount)
3. All prices MUST be positive (except discount which is negative)
4. If parsing fails for critical fields, set confidence_score below 0.5
''';
}

/// Exception for Gemini API errors
class GeminiApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  GeminiApiException(this.message, {this.statusCode, this.body});

  @override
  String toString() => 'GeminiApiException: $message (status: $statusCode)';
}

/// Exception for parsing errors
class GeminiParseException implements Exception {
  final String message;

  GeminiParseException(this.message);

  @override
  String toString() => 'GeminiParseException: $message';
}
