import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';

/// Screen for verifying and reviewing a scanned receipt
class VerificationScreen extends StatelessWidget {
  final Receipt receipt;

  const VerificationScreen({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beleg prüfen'),
        actions: [
          // Bookmark toggle
          IconButton(
            icon: Icon(
              receipt.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            ),
            onPressed: () {
              // TODO: Toggle bookmark
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conditional Review Needed Banner
            if (receipt.receiptData.aiMetadata.needsReview)
              const _ReviewNeededBanner(),

            const SizedBox(height: 16),

            // Purchase Info Card
            _PurchaseInfoCard(receipt: receipt),

            const SizedBox(height: 24),

            // Items Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Artikel (${receipt.receiptData.items.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Edit items
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Bearbeiten'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Items List
            _ItemsList(items: receipt.receiptData.items),

            const SizedBox(height: 24),

            // Summary Card
            _SummaryCard(totals: receipt.receiptData.totals),

            const SizedBox(height: 32),

            // Action Buttons
            _ActionButtons(receipt: receipt),
          ],
        ),
      ),
    );
  }
}

/// Banner shown when AI confidence is below threshold
class _ReviewNeededBanner extends StatelessWidget {
  const _ReviewNeededBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(AppColors.warningOrange).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(AppColors.warningOrange),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(AppColors.warningOrange),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Überprüfung empfohlen',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(AppColors.warningOrange),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Die automatische Erkennung war unsicher. Bitte prüfen Sie die Daten.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(AppColors.darkNavy),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card showing merchant info, date/time, and grand total
class _PurchaseInfoCard extends StatelessWidget {
  final Receipt receipt;

  const _PurchaseInfoCard({required this.receipt});

  @override
  Widget build(BuildContext context) {
    final merchant = receipt.receiptData.merchant;
    final transaction = receipt.receiptData.transaction;
    final totals = receipt.receiptData.totals;

    // Format date as DD.MM.YYYY (German format)
    final dateFormatted = _formatDate(transaction.date);
    final timeFormatted = transaction.time.substring(0, 5); // HH:MM

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Merchant Row
            Row(
              children: [
                // Merchant Logo Placeholder
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(AppColors.lightMint),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.store,
                    color: Color(AppColors.primaryTeal),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        merchant.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (merchant.address != null)
                        Text(
                          merchant.address!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(AppColors.neutralGray),
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Date & Time Row
            Row(
              children: [
                _InfoChip(
                  icon: Icons.calendar_today,
                  label: dateFormatted,
                ),
                const SizedBox(width: 12),
                _InfoChip(
                  icon: Icons.access_time,
                  label: timeFormatted,
                ),
                const Spacer(),
                // Payment Method
                _InfoChip(
                  icon: transaction.paymentMethod == 'CARD'
                      ? Icons.credit_card
                      : Icons.payments,
                  label: transaction.paymentMethod == 'CARD' ? 'Karte' : 'Bar',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Grand Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gesamtsumme',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: const Color(AppColors.neutralGray),
                      ),
                ),
                Text(
                  '${totals.grandTotal.toStringAsFixed(2)} €',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(AppColors.primaryTeal),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

/// Small info chip with icon and label
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(AppColors.lightMint),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(AppColors.darkNavy)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(AppColors.darkNavy),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

/// List of line items
class _ItemsList extends StatelessWidget {
  final List<LineItem> items;

  const _ItemsList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return _ItemTile(item: item);
      },
    );
  }
}

/// Single item tile
class _ItemTile extends StatelessWidget {
  final LineItem item;

  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isPfand = item.isPfand;
    final isDiscounted = item.isDiscounted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isPfand
                  ? const Color(AppColors.successGreen).withValues(alpha: 0.15)
                  : const Color(AppColors.lightMint),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPfand ? Icons.recycling : _getCategoryIcon(item.category),
              color: isPfand
                  ? const Color(AppColors.successGreen)
                  : const Color(AppColors.primaryTeal),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Description & Category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      item.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(AppColors.neutralGray),
                          ),
                    ),
                    if (isDiscounted) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(AppColors.errorRed)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${item.discount?.toStringAsFixed(2)} €',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: const Color(AppColors.errorRed),
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Quantity & Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.totalPrice.toStringAsFixed(2)} €',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (item.quantity > 1)
                Text(
                  '${item.quantity} × ${item.unitPrice.toStringAsFixed(2)} €',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(AppColors.neutralGray),
                      ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'groceries':
        return Icons.shopping_basket;
      case 'beverages':
        return Icons.local_drink;
      case 'snacks':
        return Icons.cookie;
      case 'household':
        return Icons.home;
      case 'electronics':
        return Icons.devices;
      case 'deposit':
        return Icons.recycling;
      default:
        return Icons.category;
    }
  }
}

/// Summary card with subtotal, Pfand, tax, and grand total
class _SummaryCard extends StatelessWidget {
  final Totals totals;

  const _SummaryCard({required this.totals});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SummaryRow(label: 'Zwischensumme', value: totals.subtotal),
            if (totals.pfandTotal > 0)
              _SummaryRow(
                label: 'Pfand',
                value: totals.pfandTotal,
                valueColor: const Color(AppColors.successGreen),
              ),
            _SummaryRow(label: 'MwSt.', value: totals.taxAmount),
            const Divider(height: 24),
            _SummaryRow(
              label: 'Gesamt',
              value: totals.grandTotal,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Single row in summary card
class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '${value.toStringAsFixed(2)} €',
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(AppColors.primaryTeal),
                    )
                : Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: valueColor,
                    ),
          ),
        ],
      ),
    );
  }
}

/// Action buttons at the bottom
class _ActionButtons extends StatelessWidget {
  final Receipt receipt;

  const _ActionButtons({required this.receipt});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Confirm Button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              // TODO: Save and navigate to dashboard
              Navigator.pop(context, receipt);
            },
            icon: const Icon(Icons.check),
            label: const Text('Bestätigen & Speichern'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Delete Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Confirm and delete
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Verwerfen'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              foregroundColor: const Color(AppColors.errorRed),
            ),
          ),
        ),
      ],
    );
  }
}
