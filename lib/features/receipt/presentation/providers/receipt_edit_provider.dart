import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparfuchs_ai/core/models/receipt.dart';

/// State representing a receipt being edited
class ReceiptEditState {
  final Receipt? originalReceipt;
  final List<LineItem> editedItems;
  final Totals calculatedTotals;
  final bool hasChanges;
  final bool isSaving;

  const ReceiptEditState({
    this.originalReceipt,
    this.editedItems = const [],
    this.calculatedTotals = const Totals(
      subtotal: 0,
      pfandTotal: 0,
      taxAmount: 0,
      grandTotal: 0,
    ),
    this.hasChanges = false,
    this.isSaving = false,
  });

  ReceiptEditState copyWith({
    Receipt? originalReceipt,
    List<LineItem>? editedItems,
    Totals? calculatedTotals,
    bool? hasChanges,
    bool? isSaving,
  }) {
    return ReceiptEditState(
      originalReceipt: originalReceipt ?? this.originalReceipt,
      editedItems: editedItems ?? this.editedItems,
      calculatedTotals: calculatedTotals ?? this.calculatedTotals,
      hasChanges: hasChanges ?? this.hasChanges,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// StateNotifier for managing receipt editing state
class ReceiptEditNotifier extends StateNotifier<ReceiptEditState> {
  ReceiptEditNotifier() : super(const ReceiptEditState());

  /// Initialize editing with a receipt
  void loadReceipt(Receipt receipt) {
    state = ReceiptEditState(
      originalReceipt: receipt,
      editedItems: List.from(receipt.receiptData.items),
      calculatedTotals: receipt.receiptData.totals,
      hasChanges: false,
    );
  }

  /// Update quantity for a specific item
  void updateItemQuantity(String itemId, int quantity) {
    if (quantity < 1) return;

    final updatedItems = state.editedItems.map((item) {
      if (item.itemId == itemId) {
        final newTotalPrice = item.unitPrice * quantity;
        return item.copyWith(
          quantity: quantity,
          totalPrice: newTotalPrice,
        );
      }
      return item;
    }).toList();

    _updateState(updatedItems);
  }

  /// Update unit price for a specific item
  void updateItemPrice(String itemId, double price) {
    if (price < 0) return;

    final updatedItems = state.editedItems.map((item) {
      if (item.itemId == itemId) {
        final newTotalPrice = price * item.quantity;
        return item.copyWith(
          unitPrice: price,
          totalPrice: newTotalPrice,
        );
      }
      return item;
    }).toList();

    _updateState(updatedItems);
  }

  /// Update description for an item
  void updateItemDescription(String itemId, String description) {
    final updatedItems = state.editedItems.map((item) {
      if (item.itemId == itemId) {
        return item.copyWith(description: description);
      }
      return item;
    }).toList();

    _updateState(updatedItems);
  }

  /// Remove an item from the list
  void removeItem(String itemId) {
    final updatedItems = state.editedItems
        .where((item) => item.itemId != itemId)
        .toList();

    _updateState(updatedItems);
  }

  /// Add a new item
  void addItem(LineItem item) {
    final updatedItems = [...state.editedItems, item];
    _updateState(updatedItems);
  }

  /// Recalculate totals and update state
  void _updateState(List<LineItem> items) {
    final totals = _recalculateTotals(items);
    state = state.copyWith(
      editedItems: items,
      calculatedTotals: totals,
      hasChanges: true,
    );
  }

  /// Recalculate all totals based on items
  Totals _recalculateTotals(List<LineItem> items) {
    double subtotal = 0;
    double pfandTotal = 0;

    for (final item in items) {
      if (item.isPfand) {
        pfandTotal += item.totalPrice;
      } else {
        subtotal += item.totalPrice;
      }
    }

    // Estimate tax (simplified: 7% avg for grocery items)
    // In production, this should be calculated based on actual tax rates
    final taxAmount = subtotal * 0.07;
    final grandTotal = subtotal + pfandTotal;

    return Totals(
      subtotal: subtotal,
      pfandTotal: pfandTotal,
      taxAmount: taxAmount,
      grandTotal: grandTotal,
    );
  }

  /// Mark as saving
  void setSaving(bool saving) {
    state = state.copyWith(isSaving: saving);
  }

  /// Build the edited receipt for saving
  Receipt? buildEditedReceipt() {
    final original = state.originalReceipt;
    if (original == null) return null;

    return original.copyWith(
      receiptData: original.receiptData.copyWith(
        items: state.editedItems,
        totals: state.calculatedTotals,
      ),
      updatedAt: DateTime.now(),
    );
  }

  /// Reset to original state
  void reset() {
    if (state.originalReceipt != null) {
      loadReceipt(state.originalReceipt!);
    } else {
      state = const ReceiptEditState();
    }
  }

  /// Clear editing state
  void clear() {
    state = const ReceiptEditState();
  }
}

/// Provider for receipt editing state
final receiptEditProvider =
    StateNotifierProvider<ReceiptEditNotifier, ReceiptEditState>((ref) {
  return ReceiptEditNotifier();
});
