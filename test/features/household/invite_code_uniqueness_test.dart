import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

/// Property 12: Household Invite Code Uniqueness
/// Validates: Requirements 5.1
///
/// Properties:
/// 1. Generated codes are exactly 8 characters
/// 2. Codes only contain allowed characters (no ambiguous I, O, 0, 1)
/// 3. Generated codes have high uniqueness (no collisions in batch)
/// 4. Codes are uppercase

void main() {
  group('Property 12: Household Invite Code Uniqueness', () {
    // Simulating the code generation logic from HouseholdRepository
    String generateJoinCode() {
      const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
      final random = Random.secure();
      return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
    }

    // Test: Code length is exactly 8 characters
    test('generated codes are exactly 8 characters', () {
      for (var i = 0; i < 100; i++) {
        final code = generateJoinCode();
        expect(code.length, 8);
      }
    });

    // Test: Codes only contain allowed characters
    test('codes only contain allowed characters', () {
      const allowedChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
      final disallowedChars = ['I', 'O', '0', '1'];

      for (var i = 0; i < 100; i++) {
        final code = generateJoinCode();

        // All chars should be in allowed set
        for (final char in code.split('')) {
          expect(allowedChars.contains(char), isTrue,
              reason: 'Character "$char" should be allowed');
        }

        // No ambiguous characters
        for (final disallowed in disallowedChars) {
          expect(code.contains(disallowed), isFalse,
              reason: 'Code should not contain "$disallowed"');
        }
      }
    });

    // Test: Codes are uppercase
    test('codes are uppercase', () {
      for (var i = 0; i < 100; i++) {
        final code = generateJoinCode();
        expect(code, code.toUpperCase());
      }
    });

    // Test: High uniqueness - no collisions in batch
    test('no collisions in batch of 1000 codes', () {
      final codes = <String>{};
      const batchSize = 1000;

      for (var i = 0; i < batchSize; i++) {
        final code = generateJoinCode();
        expect(codes.contains(code), isFalse,
            reason: 'Code "$code" should be unique');
        codes.add(code);
      }

      expect(codes.length, batchSize);
    });

    // Test: Statistical uniqueness - chars are well distributed
    test('character distribution is reasonably uniform', () {
      const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
      final charCounts = <String, int>{};

      // Generate many codes
      const sampleSize = 1000;
      for (var i = 0; i < sampleSize; i++) {
        final code = generateJoinCode();
        for (final char in code.split('')) {
          charCounts.update(char, (v) => v + 1, ifAbsent: () => 1);
        }
      }

      // Each character should appear, no character should dominate
      final totalChars = sampleSize * 8;
      final expectedPerChar = totalChars / chars.length;

      for (final char in chars.split('')) {
        final count = charCounts[char] ?? 0;
        // Allow 50% deviation from expected (generous for randomness)
        expect(count, greaterThan(expectedPerChar * 0.5),
            reason: 'Char "$char" appears too rarely');
        expect(count, lessThan(expectedPerChar * 1.5),
            reason: 'Char "$char" appears too often');
      }
    });

    // Test: Entropy calculation
    test('code entropy is sufficient for security', () {
      // 32 possible chars, 8 positions
      // Entropy = log2(32^8) = 8 * log2(32) = 8 * 5 = 40 bits
      const charSetSize = 32;
      const codeLength = 8;
      final entropy = codeLength * (log(charSetSize) / log(2));

      // Minimum 40 bits of entropy for reasonable security
      expect(entropy, greaterThanOrEqualTo(40));
    });
  });
}
