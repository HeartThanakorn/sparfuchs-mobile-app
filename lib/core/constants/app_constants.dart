/// App-wide constants for SparFuchs AI
library;

/// Color constants following the design system
class AppColors {
  AppColors._();

  /// Primary Teal - Primary actions, headers, brand
  static const int primaryTeal = 0xFF4ECDC4;

  /// Dark Navy - Text, icons, navigation
  static const int darkNavy = 0xFF2C3E50;

  /// Light Mint - Backgrounds, cards
  static const int lightMint = 0xFFE8F8F5;

  /// Success Green - Savings, positive changes
  static const int successGreen = 0xFF27AE60;

  /// Warning Orange - Alerts, review needed
  static const int warningOrange = 0xFFF39C12;

  /// Error Red - Errors, price increases
  static const int errorRed = 0xFFE74C3C;

  /// Neutral Gray - Secondary text, borders
  static const int neutralGray = 0xFF95A5A6;

  /// White - Card backgrounds
  static const int white = 0xFFFFFFFF;
}

/// API endpoints
class ApiEndpoints {
  ApiEndpoints._();

  /// n8n webhook base URL (to be configured)
  static const String n8nBaseUrl = 'https://your-vps.hostinger.com';

  /// Receipt scanning endpoint
  static const String scanReceipt = '/webhook/scan-receipt';

  /// Recipe suggestions endpoint
  static const String suggestRecipes = '/webhook/suggest-recipes';

  /// Health check endpoint
  static const String health = '/webhook/health';
}

/// Firestore collection names
class FirestoreCollections {
  FirestoreCollections._();

  static const String users = 'users';
  static const String households = 'households';
  static const String receipts = 'receipts';
  static const String products = 'products';
  static const String warrantyItems = 'warranty_items';
}

/// Receipt categories
class ReceiptCategories {
  ReceiptCategories._();

  static const String groceries = 'Groceries';
  static const String beverages = 'Beverages';
  static const String snacks = 'Snacks';
  static const String household = 'Household';
  static const String electronics = 'Electronics';
  static const String fashion = 'Fashion';
  static const String deposit = 'Deposit';
  static const String other = 'Other';

  static const List<String> all = [
    groceries,
    beverages,
    snacks,
    household,
    electronics,
    fashion,
    deposit,
    other,
  ];
}

/// Tax rates in Germany
class TaxRates {
  TaxRates._();

  /// Reduced rate for food, beverages, books
  static const double reduced = 7.0;

  /// Standard rate for non-food items
  static const double standard = 19.0;
}

/// Confidence score thresholds
class ConfidenceThresholds {
  ConfidenceThresholds._();

  /// Below this score, show "Review Needed" banner
  static const double reviewNeeded = 0.8;

  /// Below this score, parsing is considered failed
  static const double parsingFailed = 0.5;
}

/// Warranty and return periods
class WarrantyPeriods {
  WarrantyPeriods._();

  /// Return window in days (German consumer law)
  static const int returnWindowDays = 14;

  /// Warranty period in years (German consumer law)
  static const int warrantyYears = 2;

  /// Days before deadline to send reminder
  static const int reminderDaysBefore = 3;
}

/// Inflation tracker thresholds
class InflationThresholds {
  InflationThresholds._();

  /// Price increase percentage to trigger warning
  static const double warningPercent = 10.0;

  /// Period in months for price comparison
  static const int comparisonMonths = 6;
}
