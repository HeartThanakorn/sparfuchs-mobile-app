import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';

/// Search delegate for finding receipts by merchant, item, or date
class ReceiptSearchDelegate extends SearchDelegate<Receipt?> {
  final List<Receipt> receipts;
  final void Function(Receipt) onReceiptSelected;

  /// Date range filter
  DateTimeRange? _dateRange;

  /// German formatters
  static final _dateFormat = DateFormat('dd.MM.yyyy', 'en_US');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '€',
    decimalDigits: 2,
  );

  ReceiptSearchDelegate({
    required this.receipts,
    required this.onReceiptSelected,
  }) : super(
          searchFieldLabel: 'Search merchant or product...',
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: const Color(AppColors.neutralGray)),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      // Date range filter
      IconButton(
        icon: Icon(
          Icons.date_range,
          color: _dateRange != null
              ? const Color(AppColors.primaryTeal)
              : const Color(AppColors.neutralGray),
        ),
        onPressed: () => _showDateRangePicker(context),
        tooltip: 'Filter by date',
      ),
      // Clear query
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          tooltip: 'Löschen',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _filterReceipts(query);
    return _buildResultsList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty && _dateRange == null) {
      return _buildRecentSearches(context);
    }
    final suggestions = _filterReceipts(query);
    return _buildResultsList(context, suggestions);
  }

  /// Filter receipts by query and date range
  List<Receipt> _filterReceipts(String query) {
    final lowerQuery = query.toLowerCase().trim();

    return receipts.where((receipt) {
      // Date range filter
      if (_dateRange != null) {
        final dateStr = receipt.receiptData.transaction.date;
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          if (date.isBefore(_dateRange!.start) ||
              date.isAfter(_dateRange!.end)) {
            return false;
          }
        }
      }

      // If no text query, match all (after date filter)
      if (lowerQuery.isEmpty) return true;

      // Check merchant name
      final merchantName =
          receipt.receiptData.merchant.name.toLowerCase();
      if (merchantName.contains(lowerQuery)) return true;

      // Check item descriptions
      for (final item in receipt.receiptData.items) {
        if (item.description.toLowerCase().contains(lowerQuery)) {
          return true;
        }
      }

      return false;
    }).toList()
      ..sort((a, b) {
        // Sort by date descending
        return b.receiptData.transaction.date
            .compareTo(a.receiptData.transaction.date);
      });
  }

  Widget _buildRecentSearches(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suchvorschläge',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          // Quick filters
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickFilterChip(
                label: 'REWE',
                onTap: () {
                  query = 'REWE';
                  showResults(context);
                },
              ),
              _QuickFilterChip(
                label: 'Aldi',
                onTap: () {
                  query = 'Aldi';
                  showResults(context);
                },
              ),
              _QuickFilterChip(
                label: 'Lidl',
                onTap: () {
                  query = 'Lidl';
                  showResults(context);
                },
              ),
              _QuickFilterChip(
                label: 'Edeka',
                onTap: () {
                  query = 'Edeka';
                  showResults(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Date filter info
          if (_dateRange != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.date_range,
                    color: Color(AppColors.primaryTeal)),
                title: Text(
                  '${_dateFormat.format(_dateRange!.start)} - ${_dateFormat.format(_dateRange!.end)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _dateRange = null;
                    showSuggestions(context);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, List<Receipt> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: const Color(AppColors.neutralGray).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Keine Ergebnisse gefunden',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(AppColors.neutralGray),
                  ),
            ),
            if (query.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Versuche einen anderen Suchbegriff',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(AppColors.neutralGray),
                      ),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final receipt = results[index];
        return _SearchResultTile(
          receipt: receipt,
          query: query,
          currencyFormat: _currencyFormat,
          dateFormat: _dateFormat,
          onTap: () {
            close(context, receipt);
            onReceiptSelected(receipt);
          },
        );
      },
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final now = DateTime.now();
    final initialRange = _dateRange ??
        DateTimeRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        );

    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: initialRange,
      locale: const Locale('de', 'DE'),
      helpText: 'Select date range',
      cancelText: 'Cancel',
      confirmText: 'Confirm',
      saveText: 'Save',
    );

    if (result != null) {
      _dateRange = result;
      // ignore: use_build_context_synchronously
      showSuggestions(context);
    }
  }
}

/// Quick filter chip for common searches
class _QuickFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickFilterChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: const Color(AppColors.lightMint),
      labelStyle: const TextStyle(
        color: Color(AppColors.darkNavy),
      ),
    );
  }
}

/// Search result tile with highlighted match
class _SearchResultTile extends StatelessWidget {
  final Receipt receipt;
  final String query;
  final NumberFormat currencyFormat;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.receipt,
    required this.query,
    required this.currencyFormat,
    required this.dateFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final merchant = receipt.receiptData.merchant;
    final transaction = receipt.receiptData.transaction;
    final totals = receipt.receiptData.totals;

    // Parse date for display
    final date = DateTime.tryParse(transaction.date);
    final dateStr = date != null ? dateFormat.format(date) : transaction.date;

    // Find matching item if query matches an item
    String? matchingItem;
    if (query.isNotEmpty) {
      for (final item in receipt.receiptData.items) {
        if (item.description.toLowerCase().contains(query.toLowerCase())) {
          matchingItem = item.description;
          break;
        }
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Merchant avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(AppColors.primaryTeal).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    merchant.name.isNotEmpty
                        ? merchant.name[0].toUpperCase()
                        : '?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(AppColors.primaryTeal),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HighlightedText(
                      text: merchant.name,
                      query: query,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          dateStr,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(AppColors.neutralGray),
                              ),
                        ),
                        if (matchingItem != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '• $matchingItem',
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: const Color(AppColors.primaryTeal),
                                        fontStyle: FontStyle.italic,
                                      ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              Text(
                currencyFormat.format(totals.grandTotal),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(AppColors.darkNavy),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Text with highlighted query matches
class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;

  const _HighlightedText({
    required this.text,
    required this.query,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index < 0) {
      return Text(text, style: style);
    }

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + query.length),
            style: TextStyle(
              backgroundColor:
                  const Color(AppColors.primaryTeal).withValues(alpha: 0.2),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: text.substring(index + query.length)),
        ],
      ),
    );
  }
}
