import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';
import 'package:sparfuchs_ai/features/receipt/presentation/providers/receipt_provider.dart';
import 'package:sparfuchs_ai/features/receipt/presentation/widgets/edit_line_item_dialog.dart';
import 'package:sparfuchs_ai/features/inflation/data/providers/product_providers.dart';

/// Screen for verifying and reviewing a scanned receipt
class VerificationScreen extends ConsumerStatefulWidget {
  final Receipt receipt;
  final File? localImage;

  const VerificationScreen({
    super.key,
    required this.receipt,
    this.localImage,
  });

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  late List<LineItem> _items;
  late Totals _totals;
  late bool _isBookmarked;
  bool _isSaving = false;

  bool get _isNewReceipt => widget.localImage != null;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.receipt.receiptData.items);
    _totals = widget.receipt.receiptData.totals;
    _isBookmarked = widget.receipt.isBookmarked;
  }

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

  Receipt _buildUpdatedReceipt() {
    return widget.receipt.copyWith(
      isBookmarked: _isBookmarked,
      receiptData: widget.receipt.receiptData.copyWith(
        items: _items,
        totals: _totals,
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() => _isSaving = true);

    try {
      final repository = ref.read(receiptRepositoryProvider);
      final updatedReceipt = _buildUpdatedReceipt();

        // 1. Upload Image
        String imageUrl = '';
        try {
          // Try Firebase Storage first
          imageUrl = await repository.uploadReceiptImage(widget.localImage!);
        } catch (e) {
          debugPrint('Image upload failed: $e');
          
          // Fallback: Save locally
          try {
            imageUrl = await repository.saveImageLocally(widget.localImage!);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Upload fehlgeschlagen. Bild wurde lokal gespeichert.'),
                  backgroundColor: Color(AppColors.warningOrange),
                ),
              );
            }
          } catch (localError) {
            debugPrint('Local save failed: $localError');
             if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bild konnte nicht gespeichert werden.'),
                  backgroundColor: Color(AppColors.errorRed),
                ),
              );
            }
          }
        }

        // 2. Save Receipt
        final receiptId = await repository.saveReceipt(
          receiptData: updatedReceipt.receiptData,
          imageUrl: imageUrl, 
          householdId: updatedReceipt.householdId,
        );

        // 3. Update Inflation Tracker (Fire & Forget)
        // We don't await this to keep UI responsive
        final productRepository = ref.read(productRepositoryProvider);
        for (final item in updatedReceipt.receiptData.items) {
          productRepository.addPricePoint(
            normalizedName: item.description, 
            price: item.unitPrice, 
            merchant: updatedReceipt.receiptData.merchant.name, 
            receiptId: receiptId
          ).catchError((e) {
            debugPrint('Failed to track product price: $e');
          });
        }

      } else {
        // Update existing
        await repository.updateReceipt(
          updatedReceipt.receiptId,
          updatedReceipt.receiptData,
        );
      }

      if (mounted) {
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern: $e')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _editItem(LineItem item) async {
    final result = await showDialog<LineItem>(
      context: context,
      builder: (context) => EditLineItemDialog(item: item),
    );

    if (result != null) {
      setState(() {
        final index = _items.indexOf(item);
        if (index != -1) {
          _items[index] = result;
          _recalculateTotals();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSaving) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Beleg wird gespeichert...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Überprüfung'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? const Color(AppColors.warningOrange) : null,
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
            if (widget.receipt.receiptData.aiMetadata.needsReview)
              const _ReviewNeededBanner(),

            const SizedBox(height: 16),

            _PurchaseInfoCard(
              receipt: widget.receipt,
              localImage: widget.localImage,
            ),

            const SizedBox(height: 24),

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

            _ItemsList(
              items: _items,
              onItemTap: _editItem,
            ),

            const SizedBox(height: 24),

            _SummaryCard(totals: _totals),

            const SizedBox(height: 32),

            _ActionButtons(
              onConfirm: _onConfirm,
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
                const SizedBox(height: 2),
                Text(
                  'Die KI war sich bei einigen Details nicht sicher.',
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

class _PurchaseInfoCard extends StatelessWidget {
  final Receipt receipt;
  final File? localImage;

  const _PurchaseInfoCard({
    required this.receipt,
    this.localImage,
  });

  @override
  Widget build(BuildContext context) {
    final merchant = receipt.receiptData.merchant;
    final transaction = receipt.receiptData.transaction;
    
    // Format date with German locale
    String formattedDate = transaction.date;
    try {
      final date = DateTime.parse(transaction.date);
      formattedDate = DateFormat('dd.MM.yyyy', 'de_DE').format(date);
    } catch (_) {}

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(AppColors.neutralGray).withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Receipt Thumbnail
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(AppColors.lightMint),
                borderRadius: BorderRadius.circular(8),
                image: localImage != null
                    ? DecorationImage(
                        image: FileImage(localImage!),
                        fit: BoxFit.cover,
                      )
                    : (receipt.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: receipt.imageUrl.startsWith('http')
                                ? NetworkImage(receipt.imageUrl)
                                : FileImage(File(receipt.imageUrl)) as ImageProvider,
                            fit: BoxFit.cover,
                          )
                        : null),
              ),
              child: (localImage == null && receipt.imageUrl.isEmpty)
                  ? const Center(
                      child: Icon(
                        Icons.receipt_long,
                        color: Color(AppColors.primaryTeal),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Händler',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(AppColors.neutralGray),
                        ),
                  ),
                  Text(
                    merchant.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Datum',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: const Color(AppColors.neutralGray),
                                ),
                          ),
                          Text(
                            formattedDate,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Zeit',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: const Color(AppColors.neutralGray),
                                ),
                          ),
                          Text(
                            transaction.time,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemsList extends StatelessWidget {
  final List<LineItem> items;
  final Function(LineItem) onItemTap;

  const _ItemsList({required this.items, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Keine Artikel erkannt',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(AppColors.neutralGray),
                ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return _ItemTile(
          item: items[index],
          onTap: () => onItemTap(items[index]),
        );
      },
    );
  }
}

class _ItemTile extends StatelessWidget {
  final LineItem item;
  final VoidCallback onTap;

  const _ItemTile({required this.item, required this.onTap});

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

  @override
  Widget build(BuildContext context) {
    final isPfand = item.isPfand;
    final isDiscounted = item.isDiscounted;
    
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

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
}

class _SummaryCard extends StatelessWidget {
  final Totals totals;

  const _SummaryCard({required this.totals});

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

class _ActionButtons extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onDiscard;

  const _ActionButtons({required this.onConfirm, required this.onDiscard});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
