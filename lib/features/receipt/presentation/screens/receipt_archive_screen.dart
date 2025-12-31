import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/features/receipt/data/providers/receipt_providers.dart';

/// Receipt Archive Screen with real Firestore data
class ReceiptArchiveScreen extends ConsumerStatefulWidget {
  const ReceiptArchiveScreen({super.key});

  @override
  ConsumerState<ReceiptArchiveScreen> createState() =>
      _ReceiptArchiveScreenState();
}

class _ReceiptArchiveScreenState extends ConsumerState<ReceiptArchiveScreen> {
  static final _dateFormat = DateFormat('dd.MM.yyyy', 'de_DE');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final receiptsAsync = ref.watch(receiptsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Archive'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: receiptsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error.toString()),
        data: (receipts) => receipts.isEmpty
            ? _buildEmptyState()
            : _buildReceiptList(receipts),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: const Color(AppColors.errorRed),
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(AppColors.neutralGray),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: const Color(AppColors.neutralGray).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Noch keine Belege',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(AppColors.neutralGray),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scanne deinen ersten Kassenbon!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(AppColors.neutralGray),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptList(List<Receipt> receipts) {
    final groupedReceipts = _groupReceiptsByDate(receipts);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: groupedReceipts.length,
      itemBuilder: (context, index) {
        final entry = groupedReceipts.entries.elementAt(index);
        return _ReceiptDateGroup(
          dateLabel: entry.key,
          receipts: entry.value,
          currencyFormat: _currencyFormat,
          onReceiptTap: _onReceiptTap,
          onBookmarkTap: _onBookmarkTap,
        );
      },
    );
  }

  Map<String, List<Receipt>> _groupReceiptsByDate(List<Receipt> receipts) {
    final grouped = <String, List<Receipt>>{};

    for (final receipt in receipts) {
      final dateStr = receipt.receiptData.transaction.date;
      final date = DateTime.tryParse(dateStr);
      String label;

      if (date != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final receiptDate = DateTime(date.year, date.month, date.day);

        if (receiptDate == today) {
          label = 'Heute';
        } else if (receiptDate == today.subtract(const Duration(days: 1))) {
          label = 'Gestern';
        } else {
          label = _dateFormat.format(date);
        }
      } else {
        label = dateStr;
      }

      grouped.putIfAbsent(label, () => []).add(receipt);
    }

    return grouped;
  }

  void _onReceiptTap(Receipt receipt) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Öffne Beleg: ${receipt.receiptData.merchant.name}')),
    );
  }

  void _onBookmarkTap(Receipt receipt) async {
    final repository = ref.read(receiptRepositoryProvider);
    await repository.toggleBookmark(receipt.receiptId, !receipt.isBookmarked);
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Nur Lesezeichen'),
              trailing: Switch(value: false, onChanged: (_) {}),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Zeitraum wählen'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptDateGroup extends StatelessWidget {
  final String dateLabel;
  final List<Receipt> receipts;
  final NumberFormat currencyFormat;
  final void Function(Receipt) onReceiptTap;
  final void Function(Receipt) onBookmarkTap;

  const _ReceiptDateGroup({
    required this.dateLabel,
    required this.receipts,
    required this.currencyFormat,
    required this.onReceiptTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            dateLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(AppColors.neutralGray),
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...receipts.map((receipt) => _ReceiptTile(
              receipt: receipt,
              currencyFormat: currencyFormat,
              onTap: () => onReceiptTap(receipt),
              onBookmarkTap: () => onBookmarkTap(receipt),
            )),
      ],
    );
  }
}

class _ReceiptTile extends StatelessWidget {
  final Receipt receipt;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  const _ReceiptTile({
    required this.receipt,
    required this.currencyFormat,
    required this.onTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    final merchant = receipt.receiptData.merchant;
    final transaction = receipt.receiptData.transaction;
    final totals = receipt.receiptData.totals;

    String timeStr = transaction.time;
    final timeParts = timeStr.split(':');
    if (timeParts.length >= 2) {
      timeStr = '${timeParts[0]}:${timeParts[1]}';
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
              _MerchantAvatar(merchantName: merchant.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchant.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14,
                            color: const Color(AppColors.neutralGray)),
                        const SizedBox(width: 4),
                        Text(timeStr,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(AppColors.neutralGray),
                                )),
                        const SizedBox(width: 12),
                        Icon(Icons.credit_card, size: 14,
                            color: const Color(AppColors.neutralGray)),
                        const SizedBox(width: 4),
                        Text(transaction.paymentMethod,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(AppColors.neutralGray),
                                )),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(totals.grandTotal),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(AppColors.darkNavy),
                        ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onBookmarkTap,
                    child: Icon(
                      receipt.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      size: 20,
                      color: receipt.isBookmarked
                          ? const Color(AppColors.warningOrange)
                          : const Color(AppColors.neutralGray),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MerchantAvatar extends StatelessWidget {
  final String merchantName;

  const _MerchantAvatar({required this.merchantName});

  Color _getColorForMerchant(String name) {
    final colors = [
      const Color(AppColors.primaryTeal),
      const Color(0xFF3498DB),
      const Color(0xFF9B59B6),
      const Color(AppColors.warningOrange),
      const Color(AppColors.successGreen),
    ];
    return colors[name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForMerchant(merchantName);
    final initial = merchantName.isNotEmpty ? merchantName[0].toUpperCase() : '?';

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          initial,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
