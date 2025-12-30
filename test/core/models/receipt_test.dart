import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
// ignore: implementation_imports
import 'package:glados/glados.dart' hide expect;
import 'package:sparfuchs_ai/core/models/receipt.dart';

// Extension to add missing generators or helpers
extension AnyUtils on Any {
  Generator<T?> nullOr<T>(Generator<T> gen) {
    return combine2(any.bool, gen, (isNull, value) => isNull ? null : value);
  }

  Generator<DateTime> get safeDate {
    return combine6(
      any.intInRange(2020, 2030),
      any.intInRange(1, 12),
      any.intInRange(1, 28),
      any.intInRange(0, 23),
      any.intInRange(0, 59),
      any.intInRange(0, 59),
      (y, m, d, h, min, s) => DateTime(y, m, d, h, min, s),
    );
  }
}

// Arbitrary Generators
extension AnyMerchant on Any {
  Generator<Merchant> get merchant {
    return combine4(
      any.letters,
      any.nullOr(any.letters),
      any.nullOr(any.letters),
      any.nullOr(any.letters),
      (name, branchId, address, rawText) => Merchant(
        name: name,
        branchId: branchId,
        address: address,
        rawText: rawText,
      ),
    );
  }
}

extension AnyTransaction on Any {
  Generator<Transaction> get transaction {
    return combine4(
      any.dateString,
      any.timeString,
      any.letters,
      any.choose(['CASH', 'CARD']),
      (date, time, currency, paymentMethod) => Transaction(
        date: date,
        time: time,
        currency: currency,
        paymentMethod: paymentMethod,
      ),
    );
  }

  Generator<String> get dateString {
    return combine3(
      any.intInRange(2020, 2030),
      any.intInRange(1, 12),
      any.intInRange(1, 28),
      (y, m, d) => '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}',
    );
  }

  Generator<String> get timeString {
    return combine3(
      any.intInRange(0, 23),
      any.intInRange(0, 59),
      any.intInRange(0, 59),
      (h, m, s) => '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
    );
  }
}

extension AnyLineItem on Any {
  Generator<LineItem> get lineItem {
    return combine9(
      any.nullOr(any.letters), // itemId
      any.letters, // description
      any.letters, // category
      any.int, // quantity
      any.double, // unitPrice
      any.double, // totalPrice
      any.nullOr(any.double), // discount
      any.bool, // isDiscounted
      any.nullOr(any.letters), // type
      (itemId, desc, cat, qty, price, total, discount, isDisc, type) => LineItem(
        itemId: itemId,
        description: desc,
        category: cat,
        quantity: qty,
        unitPrice: price,
        totalPrice: total,
        discount: discount,
        isDiscounted: isDisc,
        type: type,
        tags: [],
      ),
    );
  }
}

extension AnyTotals on Any {
  Generator<Totals> get totals {
    return combine4(
      any.double,
      any.double,
      any.double,
      any.double,
      (sub, pfand, tax, grand) => Totals(
        subtotal: sub,
        pfandTotal: pfand,
        taxAmount: tax,
        grandTotal: grand,
      ),
    );
  }
}

extension AnyTaxEntry on Any {
  Generator<TaxEntry> get taxEntry {
    return combine2(
      any.double,
      any.double,
      (rate, amount) => TaxEntry(rate: rate, amount: amount),
    );
  }
}

extension AnyAiMetadata on Any {
  Generator<AiMetadata> get aiMetadata {
    return combine3(
      any.double,
      any.letters,
      any.nullOr(any.int),
      (score, model, time) => AiMetadata(
        confidenceScore: score,
        modelUsed: model,
        processingTimeMs: time,
      ),
    );
  }
}

extension AnyReceiptData on Any {
  Generator<ReceiptData> get receiptData {
    return combine6(
      any.merchant,
      any.transaction,
      any.list(any.lineItem),
      any.totals,
      any.list(any.taxEntry),
      any.aiMetadata,
      (merchant, transaction, items, totals, taxes, aiMetadata) => ReceiptData(
        merchant: merchant,
        transaction: transaction,
        items: items,
        totals: totals,
        taxes: taxes,
        aiMetadata: aiMetadata,
      ),
    );
  }
}

extension AnyReceipt on Any {
  Generator<Receipt> get receipt {
    return combine8(
      any.letters, // receiptId
      any.letters, // userId
      any.nullOr(any.letters), // householdId
      any.letters, // imageUrl
      any.bool, // isBookmarked
      any.receiptData, // receiptData
      any.safeDate, // createdAt
      any.safeDate, // updatedAt
      (id, uid, hid, img, bookmarked, data, created, updated) => Receipt(
        receiptId: id,
        userId: uid,
        householdId: hid,
        imageUrl: img,
        isBookmarked: bookmarked,
        receiptData: data,
        createdAt: created,
        updatedAt: updated,
      ),
    );
  }
}

void main() {
  Glados(any.receipt).test('Property 7: Receipt Serialization Round-Trip', (receipt) {
    final jsonString = jsonEncode(receipt.toJson());
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    final decoded = Receipt.fromJson(jsonMap);
    expect(decoded, receipt);
  });
}
