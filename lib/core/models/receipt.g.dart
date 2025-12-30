// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReceiptImpl _$$ReceiptImplFromJson(Map<String, dynamic> json) =>
    _$ReceiptImpl(
      receiptId: json['receiptId'] as String,
      userId: json['userId'] as String,
      householdId: json['householdId'] as String?,
      imageUrl: json['imageUrl'] as String,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      receiptData: ReceiptData.fromJson(
        json['receiptData'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ReceiptImplToJson(_$ReceiptImpl instance) =>
    <String, dynamic>{
      'receiptId': instance.receiptId,
      'userId': instance.userId,
      'householdId': instance.householdId,
      'imageUrl': instance.imageUrl,
      'isBookmarked': instance.isBookmarked,
      'receiptData': instance.receiptData,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$ReceiptDataImpl _$$ReceiptDataImplFromJson(Map<String, dynamic> json) =>
    _$ReceiptDataImpl(
      merchant: Merchant.fromJson(json['merchant'] as Map<String, dynamic>),
      transaction: Transaction.fromJson(
        json['transaction'] as Map<String, dynamic>,
      ),
      items: (json['items'] as List<dynamic>)
          .map((e) => LineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totals: Totals.fromJson(json['totals'] as Map<String, dynamic>),
      taxes: (json['taxes'] as List<dynamic>)
          .map((e) => TaxEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      aiMetadata: AiMetadata.fromJson(
        json['aiMetadata'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$$ReceiptDataImplToJson(_$ReceiptDataImpl instance) =>
    <String, dynamic>{
      'merchant': instance.merchant,
      'transaction': instance.transaction,
      'items': instance.items,
      'totals': instance.totals,
      'taxes': instance.taxes,
      'aiMetadata': instance.aiMetadata,
    };

_$MerchantImpl _$$MerchantImplFromJson(Map<String, dynamic> json) =>
    _$MerchantImpl(
      name: json['name'] as String,
      branchId: json['branchId'] as String?,
      address: json['address'] as String?,
      rawText: json['rawText'] as String?,
    );

Map<String, dynamic> _$$MerchantImplToJson(_$MerchantImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'branchId': instance.branchId,
      'address': instance.address,
      'rawText': instance.rawText,
    };

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      date: json['date'] as String,
      time: json['time'] as String,
      currency: json['currency'] as String,
      paymentMethod: json['paymentMethod'] as String,
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'date': instance.date,
      'time': instance.time,
      'currency': instance.currency,
      'paymentMethod': instance.paymentMethod,
    };

_$LineItemImpl _$$LineItemImplFromJson(Map<String, dynamic> json) =>
    _$LineItemImpl(
      itemId: json['itemId'] as String?,
      description: json['description'] as String,
      category: json['category'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      isDiscounted: json['isDiscounted'] as bool? ?? false,
      type: json['type'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$LineItemImplToJson(_$LineItemImpl instance) =>
    <String, dynamic>{
      'itemId': instance.itemId,
      'description': instance.description,
      'category': instance.category,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
      'discount': instance.discount,
      'isDiscounted': instance.isDiscounted,
      'type': instance.type,
      'tags': instance.tags,
    };

_$TotalsImpl _$$TotalsImplFromJson(Map<String, dynamic> json) => _$TotalsImpl(
  subtotal: (json['subtotal'] as num).toDouble(),
  pfandTotal: (json['pfandTotal'] as num).toDouble(),
  taxAmount: (json['taxAmount'] as num).toDouble(),
  grandTotal: (json['grandTotal'] as num).toDouble(),
);

Map<String, dynamic> _$$TotalsImplToJson(_$TotalsImpl instance) =>
    <String, dynamic>{
      'subtotal': instance.subtotal,
      'pfandTotal': instance.pfandTotal,
      'taxAmount': instance.taxAmount,
      'grandTotal': instance.grandTotal,
    };

_$TaxEntryImpl _$$TaxEntryImplFromJson(Map<String, dynamic> json) =>
    _$TaxEntryImpl(
      rate: (json['rate'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$$TaxEntryImplToJson(_$TaxEntryImpl instance) =>
    <String, dynamic>{'rate': instance.rate, 'amount': instance.amount};

_$AiMetadataImpl _$$AiMetadataImplFromJson(Map<String, dynamic> json) =>
    _$AiMetadataImpl(
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      modelUsed: json['modelUsed'] as String,
      processingTimeMs: (json['processingTimeMs'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$AiMetadataImplToJson(_$AiMetadataImpl instance) =>
    <String, dynamic>{
      'confidenceScore': instance.confidenceScore,
      'modelUsed': instance.modelUsed,
      'processingTimeMs': instance.processingTimeMs,
    };
