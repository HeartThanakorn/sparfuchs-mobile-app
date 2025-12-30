
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect; 
import 'package:sparfuchs_ai/core/models/receipt.dart';

// Extension to add missing generators or helpers
extension AnyUtils on Any {
  Generator<T?> nullOr<T>(Generator<T> gen) {
    return combine2(this.bool, gen, (isNull, value) => isNull ? null : value);
  }

  Generator<DateTime> get safeDate {
    return combine6(
      this.intInRange(2020, 2030),
      this.intInRange(1, 12),
      this.intInRange(1, 28),
      this.intInRange(0, 23),
      this.intInRange(0, 59),
      this.intInRange(0, 59),
      (y, m, d, h, min, s) => DateTime(y, m, d, h, min, s),
    );
  }
}

// Arbitrary Generators
extension AnyMerchant on Any {
  Generator<Merchant> get merchant {
    return combine4(
      this.letters,
      this.nullOr(this.letters),
      this.nullOr(this.letters),
      this.nullOr(this.letters),
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
      this.dateString, 
      this.timeString, 
      this.letters,
      this.choose(['CASH', 'CARD']),
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
      this.intInRange(2020, 2030), 
      this.intInRange(1, 12),
      this.intInRange(1, 28),
      (y, m, d) => '$y-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}'
    );
  }

  Generator<String> get timeString {
     return combine3(
      this.intInRange(0, 23), 
      this.intInRange(0, 59),
      this.intInRange(0, 59),
      (h, m, s) => '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
    );
  }
}

extension AnyLineItem on Any {
  Generator<LineItem> get lineItem {
    return combine9(
      this.nullOr(this.letters), // itemId
      this.letters,       // description
      this.letters,       // category
      this.int,          // quantity
      this.double,       // unitPrice
      this.double,       // totalPrice
      this.nullOr(this.double), // discount
      this.bool,         // isDiscounted
      this.nullOr(this.letters), // type
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
      this.double,
      this.double,
      this.double,
      this.double,
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
      this.double,
      this.double,
      (rate, amount) => TaxEntry(rate: rate, amount: amount),
    );
  }
}

extension AnyAiMetadata on Any {
  Generator<AiMetadata> get aiMetadata {
    return combine3(
      this.double,
      this.letters,
      this.nullOr(this.int),
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
      this.merchant,
      this.transaction,
      this.list(this.lineItem),
      this.totals,
      this.list(this.taxEntry),
      this.aiMetadata,
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
      this.letters, // receiptId
      this.letters, // userId
      this.nullOr(this.letters), // householdId
      this.letters, // imageUrl
      this.bool, // isBookmarked
      this.receiptData, // receiptData
      this.safeDate, // createdAt
      this.safeDate, // updatedAt
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
