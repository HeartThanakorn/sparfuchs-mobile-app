// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'receipt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Receipt _$ReceiptFromJson(Map<String, dynamic> json) {
  return _Receipt.fromJson(json);
}

/// @nodoc
mixin _$Receipt {
  String get receiptId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get householdId => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  bool get isBookmarked => throw _privateConstructorUsedError;
  ReceiptData get receiptData => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Receipt to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReceiptCopyWith<Receipt> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceiptCopyWith<$Res> {
  factory $ReceiptCopyWith(Receipt value, $Res Function(Receipt) then) =
      _$ReceiptCopyWithImpl<$Res, Receipt>;
  @useResult
  $Res call({
    String receiptId,
    String userId,
    String? householdId,
    String imageUrl,
    bool isBookmarked,
    ReceiptData receiptData,
    DateTime createdAt,
    DateTime updatedAt,
  });

  $ReceiptDataCopyWith<$Res> get receiptData;
}

/// @nodoc
class _$ReceiptCopyWithImpl<$Res, $Val extends Receipt>
    implements $ReceiptCopyWith<$Res> {
  _$ReceiptCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? receiptId = null,
    Object? userId = null,
    Object? householdId = freezed,
    Object? imageUrl = null,
    Object? isBookmarked = null,
    Object? receiptData = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            receiptId: null == receiptId
                ? _value.receiptId
                : receiptId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            householdId: freezed == householdId
                ? _value.householdId
                : householdId // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            isBookmarked: null == isBookmarked
                ? _value.isBookmarked
                : isBookmarked // ignore: cast_nullable_to_non_nullable
                      as bool,
            receiptData: null == receiptData
                ? _value.receiptData
                : receiptData // ignore: cast_nullable_to_non_nullable
                      as ReceiptData,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReceiptDataCopyWith<$Res> get receiptData {
    return $ReceiptDataCopyWith<$Res>(_value.receiptData, (value) {
      return _then(_value.copyWith(receiptData: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReceiptImplCopyWith<$Res> implements $ReceiptCopyWith<$Res> {
  factory _$$ReceiptImplCopyWith(
    _$ReceiptImpl value,
    $Res Function(_$ReceiptImpl) then,
  ) = __$$ReceiptImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String receiptId,
    String userId,
    String? householdId,
    String imageUrl,
    bool isBookmarked,
    ReceiptData receiptData,
    DateTime createdAt,
    DateTime updatedAt,
  });

  @override
  $ReceiptDataCopyWith<$Res> get receiptData;
}

/// @nodoc
class __$$ReceiptImplCopyWithImpl<$Res>
    extends _$ReceiptCopyWithImpl<$Res, _$ReceiptImpl>
    implements _$$ReceiptImplCopyWith<$Res> {
  __$$ReceiptImplCopyWithImpl(
    _$ReceiptImpl _value,
    $Res Function(_$ReceiptImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? receiptId = null,
    Object? userId = null,
    Object? householdId = freezed,
    Object? imageUrl = null,
    Object? isBookmarked = null,
    Object? receiptData = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ReceiptImpl(
        receiptId: null == receiptId
            ? _value.receiptId
            : receiptId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        householdId: freezed == householdId
            ? _value.householdId
            : householdId // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        isBookmarked: null == isBookmarked
            ? _value.isBookmarked
            : isBookmarked // ignore: cast_nullable_to_non_nullable
                  as bool,
        receiptData: null == receiptData
            ? _value.receiptData
            : receiptData // ignore: cast_nullable_to_non_nullable
                  as ReceiptData,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReceiptImpl implements _Receipt {
  const _$ReceiptImpl({
    required this.receiptId,
    required this.userId,
    this.householdId,
    required this.imageUrl,
    this.isBookmarked = false,
    required this.receiptData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$ReceiptImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReceiptImplFromJson(json);

  @override
  final String receiptId;
  @override
  final String userId;
  @override
  final String? householdId;
  @override
  final String imageUrl;
  @override
  @JsonKey()
  final bool isBookmarked;
  @override
  final ReceiptData receiptData;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Receipt(receiptId: $receiptId, userId: $userId, householdId: $householdId, imageUrl: $imageUrl, isBookmarked: $isBookmarked, receiptData: $receiptData, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiptImpl &&
            (identical(other.receiptId, receiptId) ||
                other.receiptId == receiptId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked) &&
            (identical(other.receiptData, receiptData) ||
                other.receiptData == receiptData) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    receiptId,
    userId,
    householdId,
    imageUrl,
    isBookmarked,
    receiptData,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiptImplCopyWith<_$ReceiptImpl> get copyWith =>
      __$$ReceiptImplCopyWithImpl<_$ReceiptImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReceiptImplToJson(this);
  }
}

abstract class _Receipt implements Receipt {
  const factory _Receipt({
    required final String receiptId,
    required final String userId,
    final String? householdId,
    required final String imageUrl,
    final bool isBookmarked,
    required final ReceiptData receiptData,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$ReceiptImpl;

  factory _Receipt.fromJson(Map<String, dynamic> json) = _$ReceiptImpl.fromJson;

  @override
  String get receiptId;
  @override
  String get userId;
  @override
  String? get householdId;
  @override
  String get imageUrl;
  @override
  bool get isBookmarked;
  @override
  ReceiptData get receiptData;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Receipt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceiptImplCopyWith<_$ReceiptImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReceiptData _$ReceiptDataFromJson(Map<String, dynamic> json) {
  return _ReceiptData.fromJson(json);
}

/// @nodoc
mixin _$ReceiptData {
  Merchant get merchant => throw _privateConstructorUsedError;
  Transaction get transaction => throw _privateConstructorUsedError;
  List<LineItem> get items => throw _privateConstructorUsedError;
  Totals get totals => throw _privateConstructorUsedError;
  List<TaxEntry> get taxes => throw _privateConstructorUsedError;
  AiMetadata get aiMetadata => throw _privateConstructorUsedError;

  /// Serializes this ReceiptData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReceiptData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReceiptDataCopyWith<ReceiptData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReceiptDataCopyWith<$Res> {
  factory $ReceiptDataCopyWith(
    ReceiptData value,
    $Res Function(ReceiptData) then,
  ) = _$ReceiptDataCopyWithImpl<$Res, ReceiptData>;
  @useResult
  $Res call({
    Merchant merchant,
    Transaction transaction,
    List<LineItem> items,
    Totals totals,
    List<TaxEntry> taxes,
    AiMetadata aiMetadata,
  });

  $MerchantCopyWith<$Res> get merchant;
  $TransactionCopyWith<$Res> get transaction;
  $TotalsCopyWith<$Res> get totals;
  $AiMetadataCopyWith<$Res> get aiMetadata;
}

/// @nodoc
class _$ReceiptDataCopyWithImpl<$Res, $Val extends ReceiptData>
    implements $ReceiptDataCopyWith<$Res> {
  _$ReceiptDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReceiptData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? merchant = null,
    Object? transaction = null,
    Object? items = null,
    Object? totals = null,
    Object? taxes = null,
    Object? aiMetadata = null,
  }) {
    return _then(
      _value.copyWith(
            merchant: null == merchant
                ? _value.merchant
                : merchant // ignore: cast_nullable_to_non_nullable
                      as Merchant,
            transaction: null == transaction
                ? _value.transaction
                : transaction // ignore: cast_nullable_to_non_nullable
                      as Transaction,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<LineItem>,
            totals: null == totals
                ? _value.totals
                : totals // ignore: cast_nullable_to_non_nullable
                      as Totals,
            taxes: null == taxes
                ? _value.taxes
                : taxes // ignore: cast_nullable_to_non_nullable
                      as List<TaxEntry>,
            aiMetadata: null == aiMetadata
                ? _value.aiMetadata
                : aiMetadata // ignore: cast_nullable_to_non_nullable
                      as AiMetadata,
          )
          as $Val,
    );
  }

  /// Create a copy of ReceiptData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MerchantCopyWith<$Res> get merchant {
    return $MerchantCopyWith<$Res>(_value.merchant, (value) {
      return _then(_value.copyWith(merchant: value) as $Val);
    });
  }

  /// Create a copy of ReceiptData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TransactionCopyWith<$Res> get transaction {
    return $TransactionCopyWith<$Res>(_value.transaction, (value) {
      return _then(_value.copyWith(transaction: value) as $Val);
    });
  }

  /// Create a copy of ReceiptData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TotalsCopyWith<$Res> get totals {
    return $TotalsCopyWith<$Res>(_value.totals, (value) {
      return _then(_value.copyWith(totals: value) as $Val);
    });
  }

  /// Create a copy of ReceiptData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AiMetadataCopyWith<$Res> get aiMetadata {
    return $AiMetadataCopyWith<$Res>(_value.aiMetadata, (value) {
      return _then(_value.copyWith(aiMetadata: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReceiptDataImplCopyWith<$Res>
    implements $ReceiptDataCopyWith<$Res> {
  factory _$$ReceiptDataImplCopyWith(
    _$ReceiptDataImpl value,
    $Res Function(_$ReceiptDataImpl) then,
  ) = __$$ReceiptDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Merchant merchant,
    Transaction transaction,
    List<LineItem> items,
    Totals totals,
    List<TaxEntry> taxes,
    AiMetadata aiMetadata,
  });

  @override
  $MerchantCopyWith<$Res> get merchant;
  @override
  $TransactionCopyWith<$Res> get transaction;
  @override
  $TotalsCopyWith<$Res> get totals;
  @override
  $AiMetadataCopyWith<$Res> get aiMetadata;
}

/// @nodoc
class __$$ReceiptDataImplCopyWithImpl<$Res>
    extends _$ReceiptDataCopyWithImpl<$Res, _$ReceiptDataImpl>
    implements _$$ReceiptDataImplCopyWith<$Res> {
  __$$ReceiptDataImplCopyWithImpl(
    _$ReceiptDataImpl _value,
    $Res Function(_$ReceiptDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReceiptData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? merchant = null,
    Object? transaction = null,
    Object? items = null,
    Object? totals = null,
    Object? taxes = null,
    Object? aiMetadata = null,
  }) {
    return _then(
      _$ReceiptDataImpl(
        merchant: null == merchant
            ? _value.merchant
            : merchant // ignore: cast_nullable_to_non_nullable
                  as Merchant,
        transaction: null == transaction
            ? _value.transaction
            : transaction // ignore: cast_nullable_to_non_nullable
                  as Transaction,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<LineItem>,
        totals: null == totals
            ? _value.totals
            : totals // ignore: cast_nullable_to_non_nullable
                  as Totals,
        taxes: null == taxes
            ? _value._taxes
            : taxes // ignore: cast_nullable_to_non_nullable
                  as List<TaxEntry>,
        aiMetadata: null == aiMetadata
            ? _value.aiMetadata
            : aiMetadata // ignore: cast_nullable_to_non_nullable
                  as AiMetadata,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReceiptDataImpl implements _ReceiptData {
  const _$ReceiptDataImpl({
    required this.merchant,
    required this.transaction,
    required final List<LineItem> items,
    required this.totals,
    required final List<TaxEntry> taxes,
    required this.aiMetadata,
  }) : _items = items,
       _taxes = taxes;

  factory _$ReceiptDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReceiptDataImplFromJson(json);

  @override
  final Merchant merchant;
  @override
  final Transaction transaction;
  final List<LineItem> _items;
  @override
  List<LineItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final Totals totals;
  final List<TaxEntry> _taxes;
  @override
  List<TaxEntry> get taxes {
    if (_taxes is EqualUnmodifiableListView) return _taxes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_taxes);
  }

  @override
  final AiMetadata aiMetadata;

  @override
  String toString() {
    return 'ReceiptData(merchant: $merchant, transaction: $transaction, items: $items, totals: $totals, taxes: $taxes, aiMetadata: $aiMetadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReceiptDataImpl &&
            (identical(other.merchant, merchant) ||
                other.merchant == merchant) &&
            (identical(other.transaction, transaction) ||
                other.transaction == transaction) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.totals, totals) || other.totals == totals) &&
            const DeepCollectionEquality().equals(other._taxes, _taxes) &&
            (identical(other.aiMetadata, aiMetadata) ||
                other.aiMetadata == aiMetadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    merchant,
    transaction,
    const DeepCollectionEquality().hash(_items),
    totals,
    const DeepCollectionEquality().hash(_taxes),
    aiMetadata,
  );

  /// Create a copy of ReceiptData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReceiptDataImplCopyWith<_$ReceiptDataImpl> get copyWith =>
      __$$ReceiptDataImplCopyWithImpl<_$ReceiptDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReceiptDataImplToJson(this);
  }
}

abstract class _ReceiptData implements ReceiptData {
  const factory _ReceiptData({
    required final Merchant merchant,
    required final Transaction transaction,
    required final List<LineItem> items,
    required final Totals totals,
    required final List<TaxEntry> taxes,
    required final AiMetadata aiMetadata,
  }) = _$ReceiptDataImpl;

  factory _ReceiptData.fromJson(Map<String, dynamic> json) =
      _$ReceiptDataImpl.fromJson;

  @override
  Merchant get merchant;
  @override
  Transaction get transaction;
  @override
  List<LineItem> get items;
  @override
  Totals get totals;
  @override
  List<TaxEntry> get taxes;
  @override
  AiMetadata get aiMetadata;

  /// Create a copy of ReceiptData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReceiptDataImplCopyWith<_$ReceiptDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Merchant _$MerchantFromJson(Map<String, dynamic> json) {
  return _Merchant.fromJson(json);
}

/// @nodoc
mixin _$Merchant {
  String get name => throw _privateConstructorUsedError;
  String? get branchId => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get rawText => throw _privateConstructorUsedError;

  /// Serializes this Merchant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Merchant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MerchantCopyWith<Merchant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MerchantCopyWith<$Res> {
  factory $MerchantCopyWith(Merchant value, $Res Function(Merchant) then) =
      _$MerchantCopyWithImpl<$Res, Merchant>;
  @useResult
  $Res call({String name, String? branchId, String? address, String? rawText});
}

/// @nodoc
class _$MerchantCopyWithImpl<$Res, $Val extends Merchant>
    implements $MerchantCopyWith<$Res> {
  _$MerchantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Merchant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? branchId = freezed,
    Object? address = freezed,
    Object? rawText = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            branchId: freezed == branchId
                ? _value.branchId
                : branchId // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            rawText: freezed == rawText
                ? _value.rawText
                : rawText // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MerchantImplCopyWith<$Res>
    implements $MerchantCopyWith<$Res> {
  factory _$$MerchantImplCopyWith(
    _$MerchantImpl value,
    $Res Function(_$MerchantImpl) then,
  ) = __$$MerchantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String? branchId, String? address, String? rawText});
}

/// @nodoc
class __$$MerchantImplCopyWithImpl<$Res>
    extends _$MerchantCopyWithImpl<$Res, _$MerchantImpl>
    implements _$$MerchantImplCopyWith<$Res> {
  __$$MerchantImplCopyWithImpl(
    _$MerchantImpl _value,
    $Res Function(_$MerchantImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Merchant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? branchId = freezed,
    Object? address = freezed,
    Object? rawText = freezed,
  }) {
    return _then(
      _$MerchantImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        branchId: freezed == branchId
            ? _value.branchId
            : branchId // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        rawText: freezed == rawText
            ? _value.rawText
            : rawText // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MerchantImpl implements _Merchant {
  const _$MerchantImpl({
    required this.name,
    this.branchId,
    this.address,
    this.rawText,
  });

  factory _$MerchantImpl.fromJson(Map<String, dynamic> json) =>
      _$$MerchantImplFromJson(json);

  @override
  final String name;
  @override
  final String? branchId;
  @override
  final String? address;
  @override
  final String? rawText;

  @override
  String toString() {
    return 'Merchant(name: $name, branchId: $branchId, address: $address, rawText: $rawText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MerchantImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.branchId, branchId) ||
                other.branchId == branchId) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.rawText, rawText) || other.rawText == rawText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, branchId, address, rawText);

  /// Create a copy of Merchant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MerchantImplCopyWith<_$MerchantImpl> get copyWith =>
      __$$MerchantImplCopyWithImpl<_$MerchantImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MerchantImplToJson(this);
  }
}

abstract class _Merchant implements Merchant {
  const factory _Merchant({
    required final String name,
    final String? branchId,
    final String? address,
    final String? rawText,
  }) = _$MerchantImpl;

  factory _Merchant.fromJson(Map<String, dynamic> json) =
      _$MerchantImpl.fromJson;

  @override
  String get name;
  @override
  String? get branchId;
  @override
  String? get address;
  @override
  String? get rawText;

  /// Create a copy of Merchant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MerchantImplCopyWith<_$MerchantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return _Transaction.fromJson(json);
}

/// @nodoc
mixin _$Transaction {
  String get date => throw _privateConstructorUsedError; // Format: YYYY-MM-DD
  String get time => throw _privateConstructorUsedError; // Format: HH:MM:SS
  String get currency => throw _privateConstructorUsedError; // e.g. EUR
  String get paymentMethod => throw _privateConstructorUsedError;

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
    Transaction value,
    $Res Function(Transaction) then,
  ) = _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call({String date, String time, String currency, String paymentMethod});
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? time = null,
    Object? currency = null,
    Object? paymentMethod = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            time: null == time
                ? _value.time
                : time // ignore: cast_nullable_to_non_nullable
                      as String,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentMethod: null == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
    _$TransactionImpl value,
    $Res Function(_$TransactionImpl) then,
  ) = __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String date, String time, String currency, String paymentMethod});
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
    _$TransactionImpl _value,
    $Res Function(_$TransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? time = null,
    Object? currency = null,
    Object? paymentMethod = null,
  }) {
    return _then(
      _$TransactionImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        time: null == time
            ? _value.time
            : time // ignore: cast_nullable_to_non_nullable
                  as String,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentMethod: null == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionImpl implements _Transaction {
  const _$TransactionImpl({
    required this.date,
    required this.time,
    required this.currency,
    required this.paymentMethod,
  });

  factory _$TransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionImplFromJson(json);

  @override
  final String date;
  // Format: YYYY-MM-DD
  @override
  final String time;
  // Format: HH:MM:SS
  @override
  final String currency;
  // e.g. EUR
  @override
  final String paymentMethod;

  @override
  String toString() {
    return 'Transaction(date: $date, time: $time, currency: $currency, paymentMethod: $paymentMethod)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, date, time, currency, paymentMethod);

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionImplToJson(this);
  }
}

abstract class _Transaction implements Transaction {
  const factory _Transaction({
    required final String date,
    required final String time,
    required final String currency,
    required final String paymentMethod,
  }) = _$TransactionImpl;

  factory _Transaction.fromJson(Map<String, dynamic> json) =
      _$TransactionImpl.fromJson;

  @override
  String get date; // Format: YYYY-MM-DD
  @override
  String get time; // Format: HH:MM:SS
  @override
  String get currency; // e.g. EUR
  @override
  String get paymentMethod;

  /// Create a copy of Transaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LineItem _$LineItemFromJson(Map<String, dynamic> json) {
  return _LineItem.fromJson(json);
}

/// @nodoc
mixin _$LineItem {
  // Optional because it might not be generated yet during parsing
  String? get itemId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;
  double get totalPrice => throw _privateConstructorUsedError;
  double? get discount => throw _privateConstructorUsedError;
  bool get isDiscounted => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;

  /// Serializes this LineItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LineItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LineItemCopyWith<LineItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LineItemCopyWith<$Res> {
  factory $LineItemCopyWith(LineItem value, $Res Function(LineItem) then) =
      _$LineItemCopyWithImpl<$Res, LineItem>;
  @useResult
  $Res call({
    String? itemId,
    String description,
    String category,
    int quantity,
    double unitPrice,
    double totalPrice,
    double? discount,
    bool isDiscounted,
    String? type,
    List<String>? tags,
  });
}

/// @nodoc
class _$LineItemCopyWithImpl<$Res, $Val extends LineItem>
    implements $LineItemCopyWith<$Res> {
  _$LineItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LineItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = freezed,
    Object? description = null,
    Object? category = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? totalPrice = null,
    Object? discount = freezed,
    Object? isDiscounted = null,
    Object? type = freezed,
    Object? tags = freezed,
  }) {
    return _then(
      _value.copyWith(
            itemId: freezed == itemId
                ? _value.itemId
                : itemId // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            unitPrice: null == unitPrice
                ? _value.unitPrice
                : unitPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            totalPrice: null == totalPrice
                ? _value.totalPrice
                : totalPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            discount: freezed == discount
                ? _value.discount
                : discount // ignore: cast_nullable_to_non_nullable
                      as double?,
            isDiscounted: null == isDiscounted
                ? _value.isDiscounted
                : isDiscounted // ignore: cast_nullable_to_non_nullable
                      as bool,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
            tags: freezed == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LineItemImplCopyWith<$Res>
    implements $LineItemCopyWith<$Res> {
  factory _$$LineItemImplCopyWith(
    _$LineItemImpl value,
    $Res Function(_$LineItemImpl) then,
  ) = __$$LineItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? itemId,
    String description,
    String category,
    int quantity,
    double unitPrice,
    double totalPrice,
    double? discount,
    bool isDiscounted,
    String? type,
    List<String>? tags,
  });
}

/// @nodoc
class __$$LineItemImplCopyWithImpl<$Res>
    extends _$LineItemCopyWithImpl<$Res, _$LineItemImpl>
    implements _$$LineItemImplCopyWith<$Res> {
  __$$LineItemImplCopyWithImpl(
    _$LineItemImpl _value,
    $Res Function(_$LineItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LineItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemId = freezed,
    Object? description = null,
    Object? category = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? totalPrice = null,
    Object? discount = freezed,
    Object? isDiscounted = null,
    Object? type = freezed,
    Object? tags = freezed,
  }) {
    return _then(
      _$LineItemImpl(
        itemId: freezed == itemId
            ? _value.itemId
            : itemId // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        unitPrice: null == unitPrice
            ? _value.unitPrice
            : unitPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        totalPrice: null == totalPrice
            ? _value.totalPrice
            : totalPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        discount: freezed == discount
            ? _value.discount
            : discount // ignore: cast_nullable_to_non_nullable
                  as double?,
        isDiscounted: null == isDiscounted
            ? _value.isDiscounted
            : isDiscounted // ignore: cast_nullable_to_non_nullable
                  as bool,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
        tags: freezed == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LineItemImpl extends _LineItem {
  const _$LineItemImpl({
    this.itemId,
    required this.description,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.discount,
    this.isDiscounted = false,
    this.type,
    final List<String>? tags,
  }) : _tags = tags,
       super._();

  factory _$LineItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$LineItemImplFromJson(json);

  // Optional because it might not be generated yet during parsing
  @override
  final String? itemId;
  @override
  final String description;
  @override
  final String category;
  @override
  final int quantity;
  @override
  final double unitPrice;
  @override
  final double totalPrice;
  @override
  final double? discount;
  @override
  @JsonKey()
  final bool isDiscounted;
  @override
  final String? type;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'LineItem(itemId: $itemId, description: $description, category: $category, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, discount: $discount, isDiscounted: $isDiscounted, type: $type, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LineItemImpl &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.isDiscounted, isDiscounted) ||
                other.isDiscounted == isDiscounted) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    itemId,
    description,
    category,
    quantity,
    unitPrice,
    totalPrice,
    discount,
    isDiscounted,
    type,
    const DeepCollectionEquality().hash(_tags),
  );

  /// Create a copy of LineItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LineItemImplCopyWith<_$LineItemImpl> get copyWith =>
      __$$LineItemImplCopyWithImpl<_$LineItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LineItemImplToJson(this);
  }
}

abstract class _LineItem extends LineItem {
  const factory _LineItem({
    final String? itemId,
    required final String description,
    required final String category,
    required final int quantity,
    required final double unitPrice,
    required final double totalPrice,
    final double? discount,
    final bool isDiscounted,
    final String? type,
    final List<String>? tags,
  }) = _$LineItemImpl;
  const _LineItem._() : super._();

  factory _LineItem.fromJson(Map<String, dynamic> json) =
      _$LineItemImpl.fromJson;

  // Optional because it might not be generated yet during parsing
  @override
  String? get itemId;
  @override
  String get description;
  @override
  String get category;
  @override
  int get quantity;
  @override
  double get unitPrice;
  @override
  double get totalPrice;
  @override
  double? get discount;
  @override
  bool get isDiscounted;
  @override
  String? get type;
  @override
  List<String>? get tags;

  /// Create a copy of LineItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LineItemImplCopyWith<_$LineItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Totals _$TotalsFromJson(Map<String, dynamic> json) {
  return _Totals.fromJson(json);
}

/// @nodoc
mixin _$Totals {
  double get subtotal => throw _privateConstructorUsedError;
  double get pfandTotal => throw _privateConstructorUsedError;
  double get taxAmount => throw _privateConstructorUsedError;
  double get grandTotal => throw _privateConstructorUsedError;

  /// Serializes this Totals to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Totals
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TotalsCopyWith<Totals> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TotalsCopyWith<$Res> {
  factory $TotalsCopyWith(Totals value, $Res Function(Totals) then) =
      _$TotalsCopyWithImpl<$Res, Totals>;
  @useResult
  $Res call({
    double subtotal,
    double pfandTotal,
    double taxAmount,
    double grandTotal,
  });
}

/// @nodoc
class _$TotalsCopyWithImpl<$Res, $Val extends Totals>
    implements $TotalsCopyWith<$Res> {
  _$TotalsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Totals
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subtotal = null,
    Object? pfandTotal = null,
    Object? taxAmount = null,
    Object? grandTotal = null,
  }) {
    return _then(
      _value.copyWith(
            subtotal: null == subtotal
                ? _value.subtotal
                : subtotal // ignore: cast_nullable_to_non_nullable
                      as double,
            pfandTotal: null == pfandTotal
                ? _value.pfandTotal
                : pfandTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            taxAmount: null == taxAmount
                ? _value.taxAmount
                : taxAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            grandTotal: null == grandTotal
                ? _value.grandTotal
                : grandTotal // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TotalsImplCopyWith<$Res> implements $TotalsCopyWith<$Res> {
  factory _$$TotalsImplCopyWith(
    _$TotalsImpl value,
    $Res Function(_$TotalsImpl) then,
  ) = __$$TotalsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double subtotal,
    double pfandTotal,
    double taxAmount,
    double grandTotal,
  });
}

/// @nodoc
class __$$TotalsImplCopyWithImpl<$Res>
    extends _$TotalsCopyWithImpl<$Res, _$TotalsImpl>
    implements _$$TotalsImplCopyWith<$Res> {
  __$$TotalsImplCopyWithImpl(
    _$TotalsImpl _value,
    $Res Function(_$TotalsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Totals
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subtotal = null,
    Object? pfandTotal = null,
    Object? taxAmount = null,
    Object? grandTotal = null,
  }) {
    return _then(
      _$TotalsImpl(
        subtotal: null == subtotal
            ? _value.subtotal
            : subtotal // ignore: cast_nullable_to_non_nullable
                  as double,
        pfandTotal: null == pfandTotal
            ? _value.pfandTotal
            : pfandTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        taxAmount: null == taxAmount
            ? _value.taxAmount
            : taxAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        grandTotal: null == grandTotal
            ? _value.grandTotal
            : grandTotal // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TotalsImpl implements _Totals {
  const _$TotalsImpl({
    required this.subtotal,
    required this.pfandTotal,
    required this.taxAmount,
    required this.grandTotal,
  });

  factory _$TotalsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TotalsImplFromJson(json);

  @override
  final double subtotal;
  @override
  final double pfandTotal;
  @override
  final double taxAmount;
  @override
  final double grandTotal;

  @override
  String toString() {
    return 'Totals(subtotal: $subtotal, pfandTotal: $pfandTotal, taxAmount: $taxAmount, grandTotal: $grandTotal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TotalsImpl &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.pfandTotal, pfandTotal) ||
                other.pfandTotal == pfandTotal) &&
            (identical(other.taxAmount, taxAmount) ||
                other.taxAmount == taxAmount) &&
            (identical(other.grandTotal, grandTotal) ||
                other.grandTotal == grandTotal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, subtotal, pfandTotal, taxAmount, grandTotal);

  /// Create a copy of Totals
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TotalsImplCopyWith<_$TotalsImpl> get copyWith =>
      __$$TotalsImplCopyWithImpl<_$TotalsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TotalsImplToJson(this);
  }
}

abstract class _Totals implements Totals {
  const factory _Totals({
    required final double subtotal,
    required final double pfandTotal,
    required final double taxAmount,
    required final double grandTotal,
  }) = _$TotalsImpl;

  factory _Totals.fromJson(Map<String, dynamic> json) = _$TotalsImpl.fromJson;

  @override
  double get subtotal;
  @override
  double get pfandTotal;
  @override
  double get taxAmount;
  @override
  double get grandTotal;

  /// Create a copy of Totals
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TotalsImplCopyWith<_$TotalsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TaxEntry _$TaxEntryFromJson(Map<String, dynamic> json) {
  return _TaxEntry.fromJson(json);
}

/// @nodoc
mixin _$TaxEntry {
  double get rate => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;

  /// Serializes this TaxEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TaxEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TaxEntryCopyWith<TaxEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaxEntryCopyWith<$Res> {
  factory $TaxEntryCopyWith(TaxEntry value, $Res Function(TaxEntry) then) =
      _$TaxEntryCopyWithImpl<$Res, TaxEntry>;
  @useResult
  $Res call({double rate, double amount});
}

/// @nodoc
class _$TaxEntryCopyWithImpl<$Res, $Val extends TaxEntry>
    implements $TaxEntryCopyWith<$Res> {
  _$TaxEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TaxEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rate = null, Object? amount = null}) {
    return _then(
      _value.copyWith(
            rate: null == rate
                ? _value.rate
                : rate // ignore: cast_nullable_to_non_nullable
                      as double,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TaxEntryImplCopyWith<$Res>
    implements $TaxEntryCopyWith<$Res> {
  factory _$$TaxEntryImplCopyWith(
    _$TaxEntryImpl value,
    $Res Function(_$TaxEntryImpl) then,
  ) = __$$TaxEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double rate, double amount});
}

/// @nodoc
class __$$TaxEntryImplCopyWithImpl<$Res>
    extends _$TaxEntryCopyWithImpl<$Res, _$TaxEntryImpl>
    implements _$$TaxEntryImplCopyWith<$Res> {
  __$$TaxEntryImplCopyWithImpl(
    _$TaxEntryImpl _value,
    $Res Function(_$TaxEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TaxEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rate = null, Object? amount = null}) {
    return _then(
      _$TaxEntryImpl(
        rate: null == rate
            ? _value.rate
            : rate // ignore: cast_nullable_to_non_nullable
                  as double,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TaxEntryImpl implements _TaxEntry {
  const _$TaxEntryImpl({required this.rate, required this.amount});

  factory _$TaxEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaxEntryImplFromJson(json);

  @override
  final double rate;
  @override
  final double amount;

  @override
  String toString() {
    return 'TaxEntry(rate: $rate, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaxEntryImpl &&
            (identical(other.rate, rate) || other.rate == rate) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rate, amount);

  /// Create a copy of TaxEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TaxEntryImplCopyWith<_$TaxEntryImpl> get copyWith =>
      __$$TaxEntryImplCopyWithImpl<_$TaxEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaxEntryImplToJson(this);
  }
}

abstract class _TaxEntry implements TaxEntry {
  const factory _TaxEntry({
    required final double rate,
    required final double amount,
  }) = _$TaxEntryImpl;

  factory _TaxEntry.fromJson(Map<String, dynamic> json) =
      _$TaxEntryImpl.fromJson;

  @override
  double get rate;
  @override
  double get amount;

  /// Create a copy of TaxEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TaxEntryImplCopyWith<_$TaxEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiMetadata _$AiMetadataFromJson(Map<String, dynamic> json) {
  return _AiMetadata.fromJson(json);
}

/// @nodoc
mixin _$AiMetadata {
  double get confidenceScore => throw _privateConstructorUsedError;
  String get modelUsed => throw _privateConstructorUsedError;
  int? get processingTimeMs => throw _privateConstructorUsedError;

  /// Serializes this AiMetadata to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AiMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AiMetadataCopyWith<AiMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiMetadataCopyWith<$Res> {
  factory $AiMetadataCopyWith(
    AiMetadata value,
    $Res Function(AiMetadata) then,
  ) = _$AiMetadataCopyWithImpl<$Res, AiMetadata>;
  @useResult
  $Res call({double confidenceScore, String modelUsed, int? processingTimeMs});
}

/// @nodoc
class _$AiMetadataCopyWithImpl<$Res, $Val extends AiMetadata>
    implements $AiMetadataCopyWith<$Res> {
  _$AiMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AiMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? confidenceScore = null,
    Object? modelUsed = null,
    Object? processingTimeMs = freezed,
  }) {
    return _then(
      _value.copyWith(
            confidenceScore: null == confidenceScore
                ? _value.confidenceScore
                : confidenceScore // ignore: cast_nullable_to_non_nullable
                      as double,
            modelUsed: null == modelUsed
                ? _value.modelUsed
                : modelUsed // ignore: cast_nullable_to_non_nullable
                      as String,
            processingTimeMs: freezed == processingTimeMs
                ? _value.processingTimeMs
                : processingTimeMs // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AiMetadataImplCopyWith<$Res>
    implements $AiMetadataCopyWith<$Res> {
  factory _$$AiMetadataImplCopyWith(
    _$AiMetadataImpl value,
    $Res Function(_$AiMetadataImpl) then,
  ) = __$$AiMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double confidenceScore, String modelUsed, int? processingTimeMs});
}

/// @nodoc
class __$$AiMetadataImplCopyWithImpl<$Res>
    extends _$AiMetadataCopyWithImpl<$Res, _$AiMetadataImpl>
    implements _$$AiMetadataImplCopyWith<$Res> {
  __$$AiMetadataImplCopyWithImpl(
    _$AiMetadataImpl _value,
    $Res Function(_$AiMetadataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AiMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? confidenceScore = null,
    Object? modelUsed = null,
    Object? processingTimeMs = freezed,
  }) {
    return _then(
      _$AiMetadataImpl(
        confidenceScore: null == confidenceScore
            ? _value.confidenceScore
            : confidenceScore // ignore: cast_nullable_to_non_nullable
                  as double,
        modelUsed: null == modelUsed
            ? _value.modelUsed
            : modelUsed // ignore: cast_nullable_to_non_nullable
                  as String,
        processingTimeMs: freezed == processingTimeMs
            ? _value.processingTimeMs
            : processingTimeMs // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AiMetadataImpl extends _AiMetadata {
  const _$AiMetadataImpl({
    required this.confidenceScore,
    required this.modelUsed,
    this.processingTimeMs,
  }) : super._();

  factory _$AiMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiMetadataImplFromJson(json);

  @override
  final double confidenceScore;
  @override
  final String modelUsed;
  @override
  final int? processingTimeMs;

  @override
  String toString() {
    return 'AiMetadata(confidenceScore: $confidenceScore, modelUsed: $modelUsed, processingTimeMs: $processingTimeMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiMetadataImpl &&
            (identical(other.confidenceScore, confidenceScore) ||
                other.confidenceScore == confidenceScore) &&
            (identical(other.modelUsed, modelUsed) ||
                other.modelUsed == modelUsed) &&
            (identical(other.processingTimeMs, processingTimeMs) ||
                other.processingTimeMs == processingTimeMs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, confidenceScore, modelUsed, processingTimeMs);

  /// Create a copy of AiMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AiMetadataImplCopyWith<_$AiMetadataImpl> get copyWith =>
      __$$AiMetadataImplCopyWithImpl<_$AiMetadataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiMetadataImplToJson(this);
  }
}

abstract class _AiMetadata extends AiMetadata {
  const factory _AiMetadata({
    required final double confidenceScore,
    required final String modelUsed,
    final int? processingTimeMs,
  }) = _$AiMetadataImpl;
  const _AiMetadata._() : super._();

  factory _AiMetadata.fromJson(Map<String, dynamic> json) =
      _$AiMetadataImpl.fromJson;

  @override
  double get confidenceScore;
  @override
  String get modelUsed;
  @override
  int? get processingTimeMs;

  /// Create a copy of AiMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AiMetadataImplCopyWith<_$AiMetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
