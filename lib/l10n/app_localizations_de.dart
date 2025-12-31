// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'SparFuchs AI';

  @override
  String get dashboard => 'Übersicht';

  @override
  String get receipts => 'Kassenbons';

  @override
  String get archive => 'Archiv';

  @override
  String get settings => 'Einstellungen';

  @override
  String get scan => 'Kassenbon scannen';

  @override
  String get scanHint => 'Kamera auf den Kassenbon richten';

  @override
  String get totalSpending => 'Gesamtausgaben';

  @override
  String get thisMonth => 'Diesen Monat';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get today => 'Heute';

  @override
  String get receipt => 'Kassenbon';

  @override
  String receiptsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kassenbons',
      one: '1 Kassenbon',
      zero: 'Keine Kassenbons',
    );
    return '$_temp0';
  }

  @override
  String get merchant => 'Händler';

  @override
  String get date => 'Datum';

  @override
  String get total => 'Gesamt';

  @override
  String get subtotal => 'Zwischensumme';

  @override
  String get tax => 'MwSt.';

  @override
  String get pfand => 'Pfand';

  @override
  String get items => 'Artikel';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Artikel',
      one: '1 Artikel',
      zero: 'Keine Artikel',
    );
    return '$_temp0';
  }

  @override
  String get discounts => 'Rabatte';

  @override
  String get savings => 'Ersparnis';

  @override
  String youSaved(String amount) {
    return 'Du hast $amount gespart';
  }

  @override
  String get categories => 'Kategorien';

  @override
  String get groceries => 'Lebensmittel';

  @override
  String get produce => 'Obst & Gemüse';

  @override
  String get dairy => 'Milchprodukte';

  @override
  String get meat => 'Fleisch';

  @override
  String get bakery => 'Backwaren';

  @override
  String get frozen => 'Tiefkühl';

  @override
  String get beverages => 'Getränke';

  @override
  String get household => 'Haushalt';

  @override
  String get electronics => 'Elektronik';

  @override
  String get fashion => 'Mode';

  @override
  String get household_sharing => 'Haushalt teilen';

  @override
  String get createHousehold => 'Haushalt erstellen';

  @override
  String get joinHousehold => 'Haushalt beitreten';

  @override
  String get leaveHousehold => 'Haushalt verlassen';

  @override
  String get inviteCode => 'Einladungscode';

  @override
  String get members => 'Mitglieder';

  @override
  String get warranty => 'Garantie';

  @override
  String get returnDeadline => 'Rückgabefrist';

  @override
  String get warrantyExpiry => 'Garantie endet';

  @override
  String daysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tage',
      one: '1 Tag',
      zero: 'Heute',
    );
    return '$_temp0';
  }

  @override
  String get markAsReturned => 'Als zurückgegeben markieren';

  @override
  String get recipes => 'Rezepte';

  @override
  String get recipeSuggestions => 'Rezeptvorschläge';

  @override
  String get basedOnPurchase => 'Basierend auf deinem Einkauf';

  @override
  String uses(String ingredients) {
    return 'Verwendet: $ingredients';
  }

  @override
  String prepTime(int minutes) {
    return '$minutes Min';
  }

  @override
  String servings(int count) {
    return '$count Portionen';
  }

  @override
  String get search => 'Suchen';

  @override
  String get filter => 'Filter';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get dateNewest => 'Datum (neueste)';

  @override
  String get dateOldest => 'Datum (älteste)';

  @override
  String get amountHighest => 'Betrag (höchste)';

  @override
  String get amountLowest => 'Betrag (niedrigste)';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get undo => 'Rückgängig';

  @override
  String get showLater => 'Später anzeigen';

  @override
  String get error => 'Fehler';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get loading => 'Laden...';

  @override
  String get noResults => 'Keine Ergebnisse gefunden';
}
