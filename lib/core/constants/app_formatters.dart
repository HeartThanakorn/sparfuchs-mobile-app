import 'package:intl/intl.dart';

class AppFormatters {
  static final currency = NumberFormat.currency(
    locale: 'en_US',
    symbol: '€',
    decimalDigits: 2,
  );

  static final date = DateFormat('dd.MM.yyyy', 'en_US');
  static final dateTime = DateFormat('dd.MM.yyyy • HH:mm', 'en_US');
}
