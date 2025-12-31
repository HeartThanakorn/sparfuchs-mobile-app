import 'package:intl/intl.dart';


/// Helper class for German-specific formatting
class GermanFormat {
  /// German date format: DD.MM.YYYY
  static final DateFormat date = DateFormat('dd.MM.yyyy', 'de_DE');

  /// German date with time: DD.MM.YYYY HH:mm
  static final DateFormat dateTime = DateFormat('dd.MM.yyyy HH:mm', 'de_DE');

  /// Short date: DD.MM.
  static final DateFormat shortDate = DateFormat('dd.MM.', 'de_DE');

  /// Month and year: MMMM yyyy
  static final DateFormat monthYear = DateFormat('MMMM yyyy', 'de_DE');

  /// Day name: Montag, Dienstag, etc.
  static final DateFormat dayName = DateFormat('EEEE', 'de_DE');

  /// German currency format: 1.234,56 €
  static final NumberFormat currency = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  );

  /// German number format: 1.234,56
  static final NumberFormat number = NumberFormat.decimalPattern('de_DE');

  /// German percentage: 19,00 %
  static final NumberFormat percent = NumberFormat.percentPattern('de_DE');

  /// Format a price value
  static String formatPrice(double value) => currency.format(value);

  /// Format a date value
  static String formatDate(DateTime value) => date.format(value);

  /// Format a date with time
  static String formatDateTime(DateTime value) => dateTime.format(value);

  /// Format relative date (Heute, Gestern, or date)
  static String formatRelativeDate(DateTime value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final inputDate = DateTime(value.year, value.month, value.day);

    if (inputDate == today) {
      return 'Heute';
    } else if (inputDate == today.subtract(const Duration(days: 1))) {
      return 'Gestern';
    } else {
      return date.format(value);
    }
  }
}

/// Extension for easy formatting on DateTime
extension DateTimeFormatExtension on DateTime {
  String get germanDate => GermanFormat.formatDate(this);
  String get germanDateTime => GermanFormat.formatDateTime(this);
  String get germanRelative => GermanFormat.formatRelativeDate(this);
}

/// Extension for easy formatting on double (prices)
extension PriceFormatExtension on double {
  String get germanPrice => GermanFormat.formatPrice(this);
}
