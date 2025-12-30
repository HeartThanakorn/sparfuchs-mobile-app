import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/features/receipt/presentation/widgets/edit_line_item_dialog.dart';

/// Screen for verifying and reviewing a scanned receipt
class VerificationScreen extends StatefulWidget {
  final Receipt receipt;

  const VerificationScreen({super.key, required this.receipt});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late List<LineItem> _items;
  late Totals _totals;
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.receipt.receiptData.items);
    _totals = widget.receipt.receiptData.totals;
    _isBookmarked = widget.receipt.isBookmarked;
  }

  /// Recalculates all totals based on current items
  void _recalculateTotals() {
    double subtotal = 0;
    double pfandTotal = 0;

    for (final item in _items) {
      if (item.isPfand) {
        pfandTotal += item.totalPrice;
      } else {
        subtotal += item.totalPrice;
      }
    }

    // Estimate tax (German 7% for food)
    final taxAmount = subtotal * 0.07;
    final grandTotal = subtotal + pfandTotal + taxAmount;

    setState(() {
      _totals = Totals(
        subtotal: subtotal,
        pfandTotal: pfandTotal,
        taxAmount: taxAmount,
        grandTotal: grandTotal,
      );
    });
  }

  /// Handle editing a line item
  Future<void> _editItem(int index) async {
    final updatedItem = await EditLineItemDialog.show(context, _items[index]);
    if (updatedItem != null) {
      setState(() {
        _items[index] = updatedItem;
      });
      _recalculateTotals();
    }
  }

  /// Build the updated receipt for saving
  Receipt _buildUpdatedReceipt() {
    return Receipt(
      receiptId: widget.receipt.receiptId,
      userId: widget.receipt.userId,
      householdId: widget.receipt.householdId,
      imageUrl: widget.receipt.imageUrl,
      isBookmarked: _isBookmarked,
      receiptData: ReceiptData(
        merchant: widget.receipt.receiptData.merchant,
        transaction: widget.receipt.receiptData.transaction,
        items: _items,
        totals: _totals,
        taxes: widget.receipt.receiptData.taxes,
        aiMetadata: widget.receipt.receiptData.aiMetadata,
      ),
      createdAt: widget.receipt.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beleg prüfen'),
        actions: [
          // Bookmark toggle
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            ),
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
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
            if (widget.receipt.receiptData.aiMetadata.needsReview)
              const _ReviewNeededBanner(),

            const SizedBox(height: 16),

            // Purchase Info Card
            _PurchaseInfoCard(receipt: widget.receipt),

            const SizedBox(height: 24),

            // Items Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Artikel (${_items.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Tippen zum Bearbeiten',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(AppColors.neutralGray),
                      ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Items List (now tappable)
            _ItemsList(
              items: _items,
              onItemTap: _editItem,
            ),

            const SizedBox(height: 24),

            // Summary Card (uses recalculated totals)
            _SummaryCard(totals: _totals),

            const SizedBox(height: 32),

            // Action Buttons
            _ActionButtons(
              onConfirm: () {
                Navigator.pop(context, _buildUpdatedReceipt());
              },
              onDiscard: () {
                Navigator.pop(context);
              },
            ),
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

/// List of line items separated into regular and Pfand sections
class _ItemsList extends StatelessWidget {
  final List<LineItem> items;
  final void Function(int index)? onItemTap;

  const _ItemsList({required this.items, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    // Separate items into regular and Pfand with original indices
    final regularIndices = <int>[];
    final pfandIndices = <int>[];
    for (int i = 0; i < items.length; i++) {
      if (items[i].isPfand) {
        pfandIndices.add(i);
      } else {
        regularIndices.add(i);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Regular Items Section
        if (regularIndices.isNotEmpty) ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: regularIndices.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final originalIndex = regularIndices[index];
              return _ItemTile(
                item: items[originalIndex],
                onTap: onItemTap != null ? () => onItemTap!(originalIndex) : null,
              );
            },
          ),
        ],

        // Pfand Section (if any)
        if (pfandIndices.isNotEmpty) ...[
          const SizedBox(height: 16),
          // Deposit Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(AppColors.successGreen).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(AppColors.successGreen).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.recycling,
                  color: Color(AppColors.successGreen),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'PFAND / EINWEG',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(AppColors.successGreen),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Pfand Items List
          Container(
            decoration: BoxDecoration(
              color: const Color(AppColors.successGreen).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pfandIndices.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: const Color(AppColors.successGreen).withValues(alpha: 0.2),
              ),
              itemBuilder: (context, index) {
                final originalIndex = pfandIndices[index];
                return _ItemTile(
                  item: items[originalIndex],
                  onTap: onItemTap != null ? () => onItemTap!(originalIndex) : null,
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// Single item tile with discount highlighting
class _ItemTile extends StatelessWidget {
  final LineItem item;
  final VoidCallback? onTap;

  const _ItemTile({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPfand = item.isPfand;
    final isDiscounted = item.isDiscounted;
    
    // Calculate original price (before discount)
    final originalPrice = isDiscounted && item.discount != null
        ? item.totalPrice + item.discount!
        : item.totalPrice;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
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
                Text(
                  item.category,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(AppColors.neutralGray),
                      ),
                ),
              ],
            ),
          ),

          // Price Column with Discount Highlighting
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Current Price Row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Discount Badge (moved next to price)
                  if (isDiscounted && item.discount != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(AppColors.errorRed)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${item.discount!.toStringAsFixed(2)} €',
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: const Color(AppColors.errorRed),
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ],
                  // Final Price
                  Text(
                    '${item.totalPrice.toStringAsFixed(2)} €',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDiscounted
                              ? const Color(AppColors.successGreen)
                              : null,
                        ),
                  ),
                ],
              ),
              // Original Price (struck through) when discounted
              if (isDiscounted) ...[
                const SizedBox(height: 2),
                Text(
                  '${originalPrice.toStringAsFixed(2)} €',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(AppColors.neutralGray),
                        decoration: TextDecoration.lineThrough,
                        decorationColor: const Color(AppColors.neutralGray),
                      ),
                ),
              ],
              // Quantity info
              if (item.quantity > 1 && !isDiscounted)
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
/// Uses German locale number formatting (1.234,56 €)
class _SummaryCard extends StatelessWidget {
  final Totals totals;

  const _SummaryCard({required this.totals});

  /// German number format: comma as decimal separator, dot as thousand separator
  static final _germanCurrencyFormat = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 2,
  );

  String _formatCurrency(double value) {
    return _germanCurrencyFormat.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SummaryRow(
              label: 'Zwischensumme',
              formattedValue: _formatCurrency(totals.subtotal),
            ),
            if (totals.pfandTotal > 0)
              _SummaryRow(
                label: 'Pfand',
                formattedValue: _formatCurrency(totals.pfandTotal),
                valueColor: const Color(AppColors.successGreen),
                icon: Icons.recycling,
                iconColor: const Color(AppColors.successGreen),
              ),
            _SummaryRow(
              label: 'MwSt.',
              formattedValue: _formatCurrency(totals.taxAmount),
            ),
            const Divider(height: 24),
            _SummaryRow(
              label: 'Gesamt',
              formattedValue: _formatCurrency(totals.grandTotal),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Single row in summary card with optional icon
class _SummaryRow extends StatelessWidget {
  final String label;
  final String formattedValue;
  final bool isTotal;
  final Color? valueColor;
  final IconData? icon;
  final Color? iconColor;

  const _SummaryRow({
    required this.label,
    required this.formattedValue,
    this.isTotal = false,
    this.valueColor,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label with optional icon
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: isTotal
                    ? Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        )
                    : Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          // Value
          Text(
            formattedValue,
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
  final VoidCallback onConfirm;
  final VoidCallback onDiscard;

  const _ActionButtons({required this.onConfirm, required this.onDiscard});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Confirm Button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onConfirm,
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
            onPressed: onDiscard,
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
