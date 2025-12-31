// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SparFuchs AI';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get receipts => 'Receipts';

  @override
  String get archive => 'Archive';

  @override
  String get settings => 'Settings';

  @override
  String get scan => 'Scan Receipt';

  @override
  String get scanHint => 'Point camera at receipt';

  @override
  String get totalSpending => 'Total Spending';

  @override
  String get thisMonth => 'This Month';

  @override
  String get thisWeek => 'This Week';

  @override
  String get today => 'Today';

  @override
  String get receipt => 'Receipt';

  @override
  String receiptsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receipts',
      one: '1 receipt',
      zero: 'No receipts',
    );
    return '$_temp0';
  }

  @override
  String get merchant => 'Merchant';

  @override
  String get date => 'Date';

  @override
  String get total => 'Total';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get tax => 'Tax';

  @override
  String get pfand => 'Deposit (Pfand)';

  @override
  String get items => 'Items';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get discounts => 'Discounts';

  @override
  String get savings => 'Savings';

  @override
  String youSaved(String amount) {
    return 'You saved $amount';
  }

  @override
  String get categories => 'Categories';

  @override
  String get groceries => 'Groceries';

  @override
  String get produce => 'Produce';

  @override
  String get dairy => 'Dairy';

  @override
  String get meat => 'Meat';

  @override
  String get bakery => 'Bakery';

  @override
  String get frozen => 'Frozen';

  @override
  String get beverages => 'Beverages';

  @override
  String get household => 'Household';

  @override
  String get electronics => 'Electronics';

  @override
  String get fashion => 'Fashion';

  @override
  String get household_sharing => 'Household Sharing';

  @override
  String get createHousehold => 'Create Household';

  @override
  String get joinHousehold => 'Join Household';

  @override
  String get leaveHousehold => 'Leave Household';

  @override
  String get inviteCode => 'Invite Code';

  @override
  String get members => 'Members';

  @override
  String get warranty => 'Warranty';

  @override
  String get returnDeadline => 'Return Deadline';

  @override
  String get warrantyExpiry => 'Warranty Expires';

  @override
  String daysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String get markAsReturned => 'Mark as Returned';

  @override
  String get recipes => 'Recipes';

  @override
  String get recipeSuggestions => 'Recipe Suggestions';

  @override
  String get basedOnPurchase => 'Based on your purchase';

  @override
  String uses(String ingredients) {
    return 'Uses: $ingredients';
  }

  @override
  String prepTime(int minutes) {
    return '$minutes min';
  }

  @override
  String servings(int count) {
    return '$count servings';
  }

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sortBy => 'Sort by';

  @override
  String get dateNewest => 'Date (newest)';

  @override
  String get dateOldest => 'Date (oldest)';

  @override
  String get amountHighest => 'Amount (highest)';

  @override
  String get amountLowest => 'Amount (lowest)';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get undo => 'Undo';

  @override
  String get showLater => 'Show later';

  @override
  String get error => 'Error';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get loading => 'Loading...';

  @override
  String get noResults => 'No results found';
}
