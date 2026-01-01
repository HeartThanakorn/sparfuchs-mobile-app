import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sparfuchs_ai/core/constants/app_constants.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';

/// Dialog for editing a line item's quantity and unit price
/// Returns the updated LineItem or null if cancelled
class EditLineItemDialog extends StatefulWidget {
  final LineItem item;

  const EditLineItemDialog({super.key, required this.item});

  /// Show the dialog and return the updated item
  static Future<LineItem?> show(BuildContext context, LineItem item) {
    return showDialog<LineItem>(
      context: context,
      builder: (context) => EditLineItemDialog(item: item),
    );
  }

  @override
  State<EditLineItemDialog> createState() => _EditLineItemDialogState();
}

class _EditLineItemDialogState extends State<EditLineItemDialog> {
  late TextEditingController _quantityController;
  late TextEditingController _unitPriceController;
  late int _quantity;
  late double _unitPrice;
  double _calculatedTotal = 0;

  /// German currency format for display
  static final _germanCurrencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '€',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _quantity = widget.item.quantity;
    _unitPrice = widget.item.unitPrice;
    _quantityController = TextEditingController(text: _quantity.toString());
    _unitPriceController = TextEditingController(
      text: _unitPrice.toStringAsFixed(2).replaceAll('.', ','),
    );
    _recalculate();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  void _recalculate() {
    final discount = widget.item.discount ?? 0;
    setState(() {
      _calculatedTotal = (_quantity * _unitPrice) - discount;
      if (_calculatedTotal < 0) _calculatedTotal = 0;
    });
  }

  void _onQuantityChanged(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed > 0) {
      _quantity = parsed;
      _recalculate();
    }
  }

  void _onUnitPriceChanged(String value) {
    // Handle German decimal format (comma)
    final normalized = value.replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed != null && parsed >= 0) {
      _unitPrice = parsed;
      _recalculate();
    }
  }

  void _onSave() {
    // Create updated LineItem using copyWith
    final updatedItem = LineItem(
      itemId: widget.item.itemId,
      description: widget.item.description,
      category: widget.item.category,
      quantity: _quantity,
      unitPrice: _unitPrice,
      totalPrice: _calculatedTotal,
      discount: widget.item.discount,
      isDiscounted: widget.item.isDiscounted,
      type: widget.item.type,
      tags: widget.item.tags,
    );
    Navigator.pop(context, updatedItem);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Description (read-only)
            Text(
              widget.item.description,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Quantity Field
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Menge',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              onChanged: _onQuantityChanged,
            ),
            const SizedBox(height: 16),

            // Unit Price Field
            TextFormField(
              controller: _unitPriceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Einzelpreis',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.euro),
                suffixText: '€',
              ),
              onChanged: _onUnitPriceChanged,
            ),
            const SizedBox(height: 16),

            // Discount Info (if applicable)
            if (widget.item.isDiscounted && widget.item.discount != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(AppColors.errorRed).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.discount,
                        size: 18, color: Color(AppColors.errorRed)),
                    const SizedBox(width: 8),
                    Text(
                      'Rabatt: -${widget.item.discount!.toStringAsFixed(2).replaceAll('.', ',')} €',
                      style: TextStyle(color: const Color(AppColors.errorRed)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Calculated Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(AppColors.lightMint),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total price:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    _germanCurrencyFormat.format(_calculatedTotal),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(AppColors.primaryTeal),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _onSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
