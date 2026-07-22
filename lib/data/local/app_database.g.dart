// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LedgerRecordsTable extends LedgerRecords
    with TableInfo<$LedgerRecordsTable, LedgerRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    category,
    amount,
    date,
    paymentMethod,
    memo,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerRecord(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      category:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}category'],
          )!,
      amount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}amount'],
          )!,
      date:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}date'],
          )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $LedgerRecordsTable createAlias(String alias) {
    return $LedgerRecordsTable(attachedDatabase, alias);
  }
}

class LedgerRecord extends DataClass implements Insertable<LedgerRecord> {
  final int id;
  final String type;
  final String category;
  final int amount;
  final DateTime date;
  final String? paymentMethod;
  final String? memo;
  final DateTime createdAt;
  const LedgerRecord({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.paymentMethod,
    this.memo,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<int>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LedgerRecordsCompanion toCompanion(bool nullToAbsent) {
    return LedgerRecordsCompanion(
      id: Value(id),
      type: Value(type),
      category: Value(category),
      amount: Value(amount),
      date: Value(date),
      paymentMethod:
          paymentMethod == null && nullToAbsent
              ? const Value.absent()
              : Value(paymentMethod),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      createdAt: Value(createdAt),
    );
  }

  factory LedgerRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerRecord(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<int>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      memo: serializer.fromJson<String?>(json['memo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<int>(amount),
      'date': serializer.toJson<DateTime>(date),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'memo': serializer.toJson<String?>(memo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LedgerRecord copyWith({
    int? id,
    String? type,
    String? category,
    int? amount,
    DateTime? date,
    Value<String?> paymentMethod = const Value.absent(),
    Value<String?> memo = const Value.absent(),
    DateTime? createdAt,
  }) => LedgerRecord(
    id: id ?? this.id,
    type: type ?? this.type,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    paymentMethod:
        paymentMethod.present ? paymentMethod.value : this.paymentMethod,
    memo: memo.present ? memo.value : this.memo,
    createdAt: createdAt ?? this.createdAt,
  );
  LedgerRecord copyWithCompanion(LedgerRecordsCompanion data) {
    return LedgerRecord(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      paymentMethod:
          data.paymentMethod.present
              ? data.paymentMethod.value
              : this.paymentMethod,
      memo: data.memo.present ? data.memo.value : this.memo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerRecord(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    category,
    amount,
    date,
    paymentMethod,
    memo,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerRecord &&
          other.id == this.id &&
          other.type == this.type &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.paymentMethod == this.paymentMethod &&
          other.memo == this.memo &&
          other.createdAt == this.createdAt);
}

class LedgerRecordsCompanion extends UpdateCompanion<LedgerRecord> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> category;
  final Value<int> amount;
  final Value<DateTime> date;
  final Value<String?> paymentMethod;
  final Value<String?> memo;
  final Value<DateTime> createdAt;
  const LedgerRecordsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LedgerRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String category,
    required int amount,
    required DateTime date,
    this.paymentMethod = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : type = Value(type),
       category = Value(category),
       amount = Value(amount),
       date = Value(date);
  static Insertable<LedgerRecord> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? category,
    Expression<int>? amount,
    Expression<DateTime>? date,
    Expression<String>? paymentMethod,
    Expression<String>? memo,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (memo != null) 'memo': memo,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LedgerRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? category,
    Value<int>? amount,
    Value<DateTime>? date,
    Value<String?>? paymentMethod,
    Value<String?>? memo,
    Value<DateTime>? createdAt,
  }) {
    return LedgerRecordsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerRecordsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AssetsTable extends Assets with TableInfo<$AssetsTable, Asset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _assetTypeMeta = const VerificationMeta(
    'assetType',
  );
  @override
  late final GeneratedColumn<String> assetType = GeneratedColumn<String>(
    'asset_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetNameMeta = const VerificationMeta(
    'assetName',
  );
  @override
  late final GeneratedColumn<String> assetName = GeneratedColumn<String>(
    'asset_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sharesMeta = const VerificationMeta('shares');
  @override
  late final GeneratedColumn<double> shares = GeneratedColumn<double>(
    'shares',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _includeInPortfolioMeta =
      const VerificationMeta('includeInPortfolio');
  @override
  late final GeneratedColumn<bool> includeInPortfolio = GeneratedColumn<bool>(
    'include_in_portfolio',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("include_in_portfolio" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assetType,
    assetName,
    amount,
    shares,
    includeInPortfolio,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Asset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('asset_type')) {
      context.handle(
        _assetTypeMeta,
        assetType.isAcceptableOrUnknown(data['asset_type']!, _assetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_assetTypeMeta);
    }
    if (data.containsKey('asset_name')) {
      context.handle(
        _assetNameMeta,
        assetName.isAcceptableOrUnknown(data['asset_name']!, _assetNameMeta),
      );
    } else if (isInserting) {
      context.missing(_assetNameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('shares')) {
      context.handle(
        _sharesMeta,
        shares.isAcceptableOrUnknown(data['shares']!, _sharesMeta),
      );
    }
    if (data.containsKey('include_in_portfolio')) {
      context.handle(
        _includeInPortfolioMeta,
        includeInPortfolio.isAcceptableOrUnknown(
          data['include_in_portfolio']!,
          _includeInPortfolioMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Asset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Asset(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      assetType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}asset_type'],
          )!,
      assetName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}asset_name'],
          )!,
      amount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}amount'],
          )!,
      shares: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}shares'],
      ),
      includeInPortfolio:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}include_in_portfolio'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $AssetsTable createAlias(String alias) {
    return $AssetsTable(attachedDatabase, alias);
  }
}

class Asset extends DataClass implements Insertable<Asset> {
  final int id;
  final String assetType;
  final String assetName;
  final int amount;
  final double? shares;
  final bool includeInPortfolio;
  final DateTime createdAt;
  const Asset({
    required this.id,
    required this.assetType,
    required this.assetName,
    required this.amount,
    this.shares,
    required this.includeInPortfolio,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['asset_type'] = Variable<String>(assetType);
    map['asset_name'] = Variable<String>(assetName);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || shares != null) {
      map['shares'] = Variable<double>(shares);
    }
    map['include_in_portfolio'] = Variable<bool>(includeInPortfolio);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AssetsCompanion toCompanion(bool nullToAbsent) {
    return AssetsCompanion(
      id: Value(id),
      assetType: Value(assetType),
      assetName: Value(assetName),
      amount: Value(amount),
      shares:
          shares == null && nullToAbsent ? const Value.absent() : Value(shares),
      includeInPortfolio: Value(includeInPortfolio),
      createdAt: Value(createdAt),
    );
  }

  factory Asset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Asset(
      id: serializer.fromJson<int>(json['id']),
      assetType: serializer.fromJson<String>(json['assetType']),
      assetName: serializer.fromJson<String>(json['assetName']),
      amount: serializer.fromJson<int>(json['amount']),
      shares: serializer.fromJson<double?>(json['shares']),
      includeInPortfolio: serializer.fromJson<bool>(json['includeInPortfolio']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assetType': serializer.toJson<String>(assetType),
      'assetName': serializer.toJson<String>(assetName),
      'amount': serializer.toJson<int>(amount),
      'shares': serializer.toJson<double?>(shares),
      'includeInPortfolio': serializer.toJson<bool>(includeInPortfolio),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Asset copyWith({
    int? id,
    String? assetType,
    String? assetName,
    int? amount,
    Value<double?> shares = const Value.absent(),
    bool? includeInPortfolio,
    DateTime? createdAt,
  }) => Asset(
    id: id ?? this.id,
    assetType: assetType ?? this.assetType,
    assetName: assetName ?? this.assetName,
    amount: amount ?? this.amount,
    shares: shares.present ? shares.value : this.shares,
    includeInPortfolio: includeInPortfolio ?? this.includeInPortfolio,
    createdAt: createdAt ?? this.createdAt,
  );
  Asset copyWithCompanion(AssetsCompanion data) {
    return Asset(
      id: data.id.present ? data.id.value : this.id,
      assetType: data.assetType.present ? data.assetType.value : this.assetType,
      assetName: data.assetName.present ? data.assetName.value : this.assetName,
      amount: data.amount.present ? data.amount.value : this.amount,
      shares: data.shares.present ? data.shares.value : this.shares,
      includeInPortfolio:
          data.includeInPortfolio.present
              ? data.includeInPortfolio.value
              : this.includeInPortfolio,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Asset(')
          ..write('id: $id, ')
          ..write('assetType: $assetType, ')
          ..write('assetName: $assetName, ')
          ..write('amount: $amount, ')
          ..write('shares: $shares, ')
          ..write('includeInPortfolio: $includeInPortfolio, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    assetType,
    assetName,
    amount,
    shares,
    includeInPortfolio,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Asset &&
          other.id == this.id &&
          other.assetType == this.assetType &&
          other.assetName == this.assetName &&
          other.amount == this.amount &&
          other.shares == this.shares &&
          other.includeInPortfolio == this.includeInPortfolio &&
          other.createdAt == this.createdAt);
}

class AssetsCompanion extends UpdateCompanion<Asset> {
  final Value<int> id;
  final Value<String> assetType;
  final Value<String> assetName;
  final Value<int> amount;
  final Value<double?> shares;
  final Value<bool> includeInPortfolio;
  final Value<DateTime> createdAt;
  const AssetsCompanion({
    this.id = const Value.absent(),
    this.assetType = const Value.absent(),
    this.assetName = const Value.absent(),
    this.amount = const Value.absent(),
    this.shares = const Value.absent(),
    this.includeInPortfolio = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AssetsCompanion.insert({
    this.id = const Value.absent(),
    required String assetType,
    required String assetName,
    required int amount,
    this.shares = const Value.absent(),
    this.includeInPortfolio = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : assetType = Value(assetType),
       assetName = Value(assetName),
       amount = Value(amount);
  static Insertable<Asset> custom({
    Expression<int>? id,
    Expression<String>? assetType,
    Expression<String>? assetName,
    Expression<int>? amount,
    Expression<double>? shares,
    Expression<bool>? includeInPortfolio,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetType != null) 'asset_type': assetType,
      if (assetName != null) 'asset_name': assetName,
      if (amount != null) 'amount': amount,
      if (shares != null) 'shares': shares,
      if (includeInPortfolio != null)
        'include_in_portfolio': includeInPortfolio,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AssetsCompanion copyWith({
    Value<int>? id,
    Value<String>? assetType,
    Value<String>? assetName,
    Value<int>? amount,
    Value<double?>? shares,
    Value<bool>? includeInPortfolio,
    Value<DateTime>? createdAt,
  }) {
    return AssetsCompanion(
      id: id ?? this.id,
      assetType: assetType ?? this.assetType,
      assetName: assetName ?? this.assetName,
      amount: amount ?? this.amount,
      shares: shares ?? this.shares,
      includeInPortfolio: includeInPortfolio ?? this.includeInPortfolio,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (assetType.present) {
      map['asset_type'] = Variable<String>(assetType.value);
    }
    if (assetName.present) {
      map['asset_name'] = Variable<String>(assetName.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (shares.present) {
      map['shares'] = Variable<double>(shares.value);
    }
    if (includeInPortfolio.present) {
      map['include_in_portfolio'] = Variable<bool>(includeInPortfolio.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetsCompanion(')
          ..write('id: $id, ')
          ..write('assetType: $assetType, ')
          ..write('assetName: $assetName, ')
          ..write('amount: $amount, ')
          ..write('shares: $shares, ')
          ..write('includeInPortfolio: $includeInPortfolio, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PortfolioTargetsTable extends PortfolioTargets
    with TableInfo<$PortfolioTargetsTable, PortfolioTarget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PortfolioTargetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _assetTypeMeta = const VerificationMeta(
    'assetType',
  );
  @override
  late final GeneratedColumn<String> assetType = GeneratedColumn<String>(
    'asset_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _targetRatioMeta = const VerificationMeta(
    'targetRatio',
  );
  @override
  late final GeneratedColumn<int> targetRatio = GeneratedColumn<int>(
    'target_ratio',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assetType,
    isEnabled,
    targetRatio,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'portfolio_targets';
  @override
  VerificationContext validateIntegrity(
    Insertable<PortfolioTarget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('asset_type')) {
      context.handle(
        _assetTypeMeta,
        assetType.isAcceptableOrUnknown(data['asset_type']!, _assetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_assetTypeMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('target_ratio')) {
      context.handle(
        _targetRatioMeta,
        targetRatio.isAcceptableOrUnknown(
          data['target_ratio']!,
          _targetRatioMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PortfolioTarget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PortfolioTarget(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      assetType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}asset_type'],
          )!,
      isEnabled:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_enabled'],
          )!,
      targetRatio:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}target_ratio'],
          )!,
      updatedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}updated_at'],
          )!,
    );
  }

  @override
  $PortfolioTargetsTable createAlias(String alias) {
    return $PortfolioTargetsTable(attachedDatabase, alias);
  }
}

class PortfolioTarget extends DataClass implements Insertable<PortfolioTarget> {
  final int id;
  final String assetType;
  final bool isEnabled;
  final int targetRatio;
  final DateTime updatedAt;
  const PortfolioTarget({
    required this.id,
    required this.assetType,
    required this.isEnabled,
    required this.targetRatio,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['asset_type'] = Variable<String>(assetType);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['target_ratio'] = Variable<int>(targetRatio);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PortfolioTargetsCompanion toCompanion(bool nullToAbsent) {
    return PortfolioTargetsCompanion(
      id: Value(id),
      assetType: Value(assetType),
      isEnabled: Value(isEnabled),
      targetRatio: Value(targetRatio),
      updatedAt: Value(updatedAt),
    );
  }

  factory PortfolioTarget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PortfolioTarget(
      id: serializer.fromJson<int>(json['id']),
      assetType: serializer.fromJson<String>(json['assetType']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      targetRatio: serializer.fromJson<int>(json['targetRatio']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assetType': serializer.toJson<String>(assetType),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'targetRatio': serializer.toJson<int>(targetRatio),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PortfolioTarget copyWith({
    int? id,
    String? assetType,
    bool? isEnabled,
    int? targetRatio,
    DateTime? updatedAt,
  }) => PortfolioTarget(
    id: id ?? this.id,
    assetType: assetType ?? this.assetType,
    isEnabled: isEnabled ?? this.isEnabled,
    targetRatio: targetRatio ?? this.targetRatio,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PortfolioTarget copyWithCompanion(PortfolioTargetsCompanion data) {
    return PortfolioTarget(
      id: data.id.present ? data.id.value : this.id,
      assetType: data.assetType.present ? data.assetType.value : this.assetType,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      targetRatio:
          data.targetRatio.present ? data.targetRatio.value : this.targetRatio,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PortfolioTarget(')
          ..write('id: $id, ')
          ..write('assetType: $assetType, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('targetRatio: $targetRatio, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, assetType, isEnabled, targetRatio, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PortfolioTarget &&
          other.id == this.id &&
          other.assetType == this.assetType &&
          other.isEnabled == this.isEnabled &&
          other.targetRatio == this.targetRatio &&
          other.updatedAt == this.updatedAt);
}

class PortfolioTargetsCompanion extends UpdateCompanion<PortfolioTarget> {
  final Value<int> id;
  final Value<String> assetType;
  final Value<bool> isEnabled;
  final Value<int> targetRatio;
  final Value<DateTime> updatedAt;
  const PortfolioTargetsCompanion({
    this.id = const Value.absent(),
    this.assetType = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.targetRatio = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PortfolioTargetsCompanion.insert({
    this.id = const Value.absent(),
    required String assetType,
    this.isEnabled = const Value.absent(),
    this.targetRatio = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : assetType = Value(assetType);
  static Insertable<PortfolioTarget> custom({
    Expression<int>? id,
    Expression<String>? assetType,
    Expression<bool>? isEnabled,
    Expression<int>? targetRatio,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetType != null) 'asset_type': assetType,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (targetRatio != null) 'target_ratio': targetRatio,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PortfolioTargetsCompanion copyWith({
    Value<int>? id,
    Value<String>? assetType,
    Value<bool>? isEnabled,
    Value<int>? targetRatio,
    Value<DateTime>? updatedAt,
  }) {
    return PortfolioTargetsCompanion(
      id: id ?? this.id,
      assetType: assetType ?? this.assetType,
      isEnabled: isEnabled ?? this.isEnabled,
      targetRatio: targetRatio ?? this.targetRatio,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (assetType.present) {
      map['asset_type'] = Variable<String>(assetType.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (targetRatio.present) {
      map['target_ratio'] = Variable<int>(targetRatio.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PortfolioTargetsCompanion(')
          ..write('id: $id, ')
          ..write('assetType: $assetType, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('targetRatio: $targetRatio, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FavoriteLedgerRecordsTable extends FavoriteLedgerRecords
    with TableInfo<$FavoriteLedgerRecordsTable, FavoriteLedgerRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteLedgerRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    category,
    amount,
    paymentMethod,
    memo,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_ledger_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteLedgerRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavoriteLedgerRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteLedgerRecord(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      category:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}category'],
          )!,
      amount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}amount'],
          )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $FavoriteLedgerRecordsTable createAlias(String alias) {
    return $FavoriteLedgerRecordsTable(attachedDatabase, alias);
  }
}

class FavoriteLedgerRecord extends DataClass
    implements Insertable<FavoriteLedgerRecord> {
  final int id;
  final String type;
  final String category;
  final int amount;
  final String? paymentMethod;
  final String? memo;
  final DateTime createdAt;
  const FavoriteLedgerRecord({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    this.paymentMethod,
    this.memo,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FavoriteLedgerRecordsCompanion toCompanion(bool nullToAbsent) {
    return FavoriteLedgerRecordsCompanion(
      id: Value(id),
      type: Value(type),
      category: Value(category),
      amount: Value(amount),
      paymentMethod:
          paymentMethod == null && nullToAbsent
              ? const Value.absent()
              : Value(paymentMethod),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      createdAt: Value(createdAt),
    );
  }

  factory FavoriteLedgerRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteLedgerRecord(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<int>(json['amount']),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      memo: serializer.fromJson<String?>(json['memo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<int>(amount),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'memo': serializer.toJson<String?>(memo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FavoriteLedgerRecord copyWith({
    int? id,
    String? type,
    String? category,
    int? amount,
    Value<String?> paymentMethod = const Value.absent(),
    Value<String?> memo = const Value.absent(),
    DateTime? createdAt,
  }) => FavoriteLedgerRecord(
    id: id ?? this.id,
    type: type ?? this.type,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    paymentMethod:
        paymentMethod.present ? paymentMethod.value : this.paymentMethod,
    memo: memo.present ? memo.value : this.memo,
    createdAt: createdAt ?? this.createdAt,
  );
  FavoriteLedgerRecord copyWithCompanion(FavoriteLedgerRecordsCompanion data) {
    return FavoriteLedgerRecord(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentMethod:
          data.paymentMethod.present
              ? data.paymentMethod.value
              : this.paymentMethod,
      memo: data.memo.present ? data.memo.value : this.memo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteLedgerRecord(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, category, amount, paymentMethod, memo, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteLedgerRecord &&
          other.id == this.id &&
          other.type == this.type &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.paymentMethod == this.paymentMethod &&
          other.memo == this.memo &&
          other.createdAt == this.createdAt);
}

class FavoriteLedgerRecordsCompanion
    extends UpdateCompanion<FavoriteLedgerRecord> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> category;
  final Value<int> amount;
  final Value<String?> paymentMethod;
  final Value<String?> memo;
  final Value<DateTime> createdAt;
  const FavoriteLedgerRecordsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FavoriteLedgerRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String category,
    required int amount,
    this.paymentMethod = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : type = Value(type),
       category = Value(category),
       amount = Value(amount);
  static Insertable<FavoriteLedgerRecord> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? category,
    Expression<int>? amount,
    Expression<String>? paymentMethod,
    Expression<String>? memo,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (memo != null) 'memo': memo,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FavoriteLedgerRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? category,
    Value<int>? amount,
    Value<String?>? paymentMethod,
    Value<String?>? memo,
    Value<DateTime>? createdAt,
  }) {
    return FavoriteLedgerRecordsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteLedgerRecordsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LedgerRecordsTable ledgerRecords = $LedgerRecordsTable(this);
  late final $AssetsTable assets = $AssetsTable(this);
  late final $PortfolioTargetsTable portfolioTargets = $PortfolioTargetsTable(
    this,
  );
  late final $FavoriteLedgerRecordsTable favoriteLedgerRecords =
      $FavoriteLedgerRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    ledgerRecords,
    assets,
    portfolioTargets,
    favoriteLedgerRecords,
  ];
}

typedef $$LedgerRecordsTableCreateCompanionBuilder =
    LedgerRecordsCompanion Function({
      Value<int> id,
      required String type,
      required String category,
      required int amount,
      required DateTime date,
      Value<String?> paymentMethod,
      Value<String?> memo,
      Value<DateTime> createdAt,
    });
typedef $$LedgerRecordsTableUpdateCompanionBuilder =
    LedgerRecordsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String> category,
      Value<int> amount,
      Value<DateTime> date,
      Value<String?> paymentMethod,
      Value<String?> memo,
      Value<DateTime> createdAt,
    });

class $$LedgerRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerRecordsTable> {
  $$LedgerRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LedgerRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerRecordsTable> {
  $$LedgerRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LedgerRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerRecordsTable> {
  $$LedgerRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LedgerRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LedgerRecordsTable,
          LedgerRecord,
          $$LedgerRecordsTableFilterComposer,
          $$LedgerRecordsTableOrderingComposer,
          $$LedgerRecordsTableAnnotationComposer,
          $$LedgerRecordsTableCreateCompanionBuilder,
          $$LedgerRecordsTableUpdateCompanionBuilder,
          (
            LedgerRecord,
            BaseReferences<_$AppDatabase, $LedgerRecordsTable, LedgerRecord>,
          ),
          LedgerRecord,
          PrefetchHooks Function()
        > {
  $$LedgerRecordsTableTableManager(_$AppDatabase db, $LedgerRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LedgerRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$LedgerRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LedgerRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LedgerRecordsCompanion(
                id: id,
                type: type,
                category: category,
                amount: amount,
                date: date,
                paymentMethod: paymentMethod,
                memo: memo,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required String category,
                required int amount,
                required DateTime date,
                Value<String?> paymentMethod = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LedgerRecordsCompanion.insert(
                id: id,
                type: type,
                category: category,
                amount: amount,
                date: date,
                paymentMethod: paymentMethod,
                memo: memo,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LedgerRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LedgerRecordsTable,
      LedgerRecord,
      $$LedgerRecordsTableFilterComposer,
      $$LedgerRecordsTableOrderingComposer,
      $$LedgerRecordsTableAnnotationComposer,
      $$LedgerRecordsTableCreateCompanionBuilder,
      $$LedgerRecordsTableUpdateCompanionBuilder,
      (
        LedgerRecord,
        BaseReferences<_$AppDatabase, $LedgerRecordsTable, LedgerRecord>,
      ),
      LedgerRecord,
      PrefetchHooks Function()
    >;
typedef $$AssetsTableCreateCompanionBuilder =
    AssetsCompanion Function({
      Value<int> id,
      required String assetType,
      required String assetName,
      required int amount,
      Value<double?> shares,
      Value<bool> includeInPortfolio,
      Value<DateTime> createdAt,
    });
typedef $$AssetsTableUpdateCompanionBuilder =
    AssetsCompanion Function({
      Value<int> id,
      Value<String> assetType,
      Value<String> assetName,
      Value<int> amount,
      Value<double?> shares,
      Value<bool> includeInPortfolio,
      Value<DateTime> createdAt,
    });

class $$AssetsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetType => $composableBuilder(
    column: $table.assetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetName => $composableBuilder(
    column: $table.assetName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get shares => $composableBuilder(
    column: $table.shares,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get includeInPortfolio => $composableBuilder(
    column: $table.includeInPortfolio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetType => $composableBuilder(
    column: $table.assetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetName => $composableBuilder(
    column: $table.assetName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get shares => $composableBuilder(
    column: $table.shares,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get includeInPortfolio => $composableBuilder(
    column: $table.includeInPortfolio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assetType =>
      $composableBuilder(column: $table.assetType, builder: (column) => column);

  GeneratedColumn<String> get assetName =>
      $composableBuilder(column: $table.assetName, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get shares =>
      $composableBuilder(column: $table.shares, builder: (column) => column);

  GeneratedColumn<bool> get includeInPortfolio => $composableBuilder(
    column: $table.includeInPortfolio,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetsTable,
          Asset,
          $$AssetsTableFilterComposer,
          $$AssetsTableOrderingComposer,
          $$AssetsTableAnnotationComposer,
          $$AssetsTableCreateCompanionBuilder,
          $$AssetsTableUpdateCompanionBuilder,
          (Asset, BaseReferences<_$AppDatabase, $AssetsTable, Asset>),
          Asset,
          PrefetchHooks Function()
        > {
  $$AssetsTableTableManager(_$AppDatabase db, $AssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$AssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$AssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$AssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> assetType = const Value.absent(),
                Value<String> assetName = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<double?> shares = const Value.absent(),
                Value<bool> includeInPortfolio = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AssetsCompanion(
                id: id,
                assetType: assetType,
                assetName: assetName,
                amount: amount,
                shares: shares,
                includeInPortfolio: includeInPortfolio,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String assetType,
                required String assetName,
                required int amount,
                Value<double?> shares = const Value.absent(),
                Value<bool> includeInPortfolio = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AssetsCompanion.insert(
                id: id,
                assetType: assetType,
                assetName: assetName,
                amount: amount,
                shares: shares,
                includeInPortfolio: includeInPortfolio,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetsTable,
      Asset,
      $$AssetsTableFilterComposer,
      $$AssetsTableOrderingComposer,
      $$AssetsTableAnnotationComposer,
      $$AssetsTableCreateCompanionBuilder,
      $$AssetsTableUpdateCompanionBuilder,
      (Asset, BaseReferences<_$AppDatabase, $AssetsTable, Asset>),
      Asset,
      PrefetchHooks Function()
    >;
typedef $$PortfolioTargetsTableCreateCompanionBuilder =
    PortfolioTargetsCompanion Function({
      Value<int> id,
      required String assetType,
      Value<bool> isEnabled,
      Value<int> targetRatio,
      Value<DateTime> updatedAt,
    });
typedef $$PortfolioTargetsTableUpdateCompanionBuilder =
    PortfolioTargetsCompanion Function({
      Value<int> id,
      Value<String> assetType,
      Value<bool> isEnabled,
      Value<int> targetRatio,
      Value<DateTime> updatedAt,
    });

class $$PortfolioTargetsTableFilterComposer
    extends Composer<_$AppDatabase, $PortfolioTargetsTable> {
  $$PortfolioTargetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetType => $composableBuilder(
    column: $table.assetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetRatio => $composableBuilder(
    column: $table.targetRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PortfolioTargetsTableOrderingComposer
    extends Composer<_$AppDatabase, $PortfolioTargetsTable> {
  $$PortfolioTargetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetType => $composableBuilder(
    column: $table.assetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetRatio => $composableBuilder(
    column: $table.targetRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PortfolioTargetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PortfolioTargetsTable> {
  $$PortfolioTargetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get assetType =>
      $composableBuilder(column: $table.assetType, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<int> get targetRatio => $composableBuilder(
    column: $table.targetRatio,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PortfolioTargetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PortfolioTargetsTable,
          PortfolioTarget,
          $$PortfolioTargetsTableFilterComposer,
          $$PortfolioTargetsTableOrderingComposer,
          $$PortfolioTargetsTableAnnotationComposer,
          $$PortfolioTargetsTableCreateCompanionBuilder,
          $$PortfolioTargetsTableUpdateCompanionBuilder,
          (
            PortfolioTarget,
            BaseReferences<
              _$AppDatabase,
              $PortfolioTargetsTable,
              PortfolioTarget
            >,
          ),
          PortfolioTarget,
          PrefetchHooks Function()
        > {
  $$PortfolioTargetsTableTableManager(
    _$AppDatabase db,
    $PortfolioTargetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$PortfolioTargetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PortfolioTargetsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$PortfolioTargetsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> assetType = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<int> targetRatio = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PortfolioTargetsCompanion(
                id: id,
                assetType: assetType,
                isEnabled: isEnabled,
                targetRatio: targetRatio,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String assetType,
                Value<bool> isEnabled = const Value.absent(),
                Value<int> targetRatio = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PortfolioTargetsCompanion.insert(
                id: id,
                assetType: assetType,
                isEnabled: isEnabled,
                targetRatio: targetRatio,
                updatedAt: updatedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PortfolioTargetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PortfolioTargetsTable,
      PortfolioTarget,
      $$PortfolioTargetsTableFilterComposer,
      $$PortfolioTargetsTableOrderingComposer,
      $$PortfolioTargetsTableAnnotationComposer,
      $$PortfolioTargetsTableCreateCompanionBuilder,
      $$PortfolioTargetsTableUpdateCompanionBuilder,
      (
        PortfolioTarget,
        BaseReferences<_$AppDatabase, $PortfolioTargetsTable, PortfolioTarget>,
      ),
      PortfolioTarget,
      PrefetchHooks Function()
    >;
typedef $$FavoriteLedgerRecordsTableCreateCompanionBuilder =
    FavoriteLedgerRecordsCompanion Function({
      Value<int> id,
      required String type,
      required String category,
      required int amount,
      Value<String?> paymentMethod,
      Value<String?> memo,
      Value<DateTime> createdAt,
    });
typedef $$FavoriteLedgerRecordsTableUpdateCompanionBuilder =
    FavoriteLedgerRecordsCompanion Function({
      Value<int> id,
      Value<String> type,
      Value<String> category,
      Value<int> amount,
      Value<String?> paymentMethod,
      Value<String?> memo,
      Value<DateTime> createdAt,
    });

class $$FavoriteLedgerRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteLedgerRecordsTable> {
  $$FavoriteLedgerRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteLedgerRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteLedgerRecordsTable> {
  $$FavoriteLedgerRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteLedgerRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteLedgerRecordsTable> {
  $$FavoriteLedgerRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FavoriteLedgerRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteLedgerRecordsTable,
          FavoriteLedgerRecord,
          $$FavoriteLedgerRecordsTableFilterComposer,
          $$FavoriteLedgerRecordsTableOrderingComposer,
          $$FavoriteLedgerRecordsTableAnnotationComposer,
          $$FavoriteLedgerRecordsTableCreateCompanionBuilder,
          $$FavoriteLedgerRecordsTableUpdateCompanionBuilder,
          (
            FavoriteLedgerRecord,
            BaseReferences<
              _$AppDatabase,
              $FavoriteLedgerRecordsTable,
              FavoriteLedgerRecord
            >,
          ),
          FavoriteLedgerRecord,
          PrefetchHooks Function()
        > {
  $$FavoriteLedgerRecordsTableTableManager(
    _$AppDatabase db,
    $FavoriteLedgerRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$FavoriteLedgerRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$FavoriteLedgerRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$FavoriteLedgerRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String?> paymentMethod = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FavoriteLedgerRecordsCompanion(
                id: id,
                type: type,
                category: category,
                amount: amount,
                paymentMethod: paymentMethod,
                memo: memo,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String type,
                required String category,
                required int amount,
                Value<String?> paymentMethod = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FavoriteLedgerRecordsCompanion.insert(
                id: id,
                type: type,
                category: category,
                amount: amount,
                paymentMethod: paymentMethod,
                memo: memo,
                createdAt: createdAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteLedgerRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteLedgerRecordsTable,
      FavoriteLedgerRecord,
      $$FavoriteLedgerRecordsTableFilterComposer,
      $$FavoriteLedgerRecordsTableOrderingComposer,
      $$FavoriteLedgerRecordsTableAnnotationComposer,
      $$FavoriteLedgerRecordsTableCreateCompanionBuilder,
      $$FavoriteLedgerRecordsTableUpdateCompanionBuilder,
      (
        FavoriteLedgerRecord,
        BaseReferences<
          _$AppDatabase,
          $FavoriteLedgerRecordsTable,
          FavoriteLedgerRecord
        >,
      ),
      FavoriteLedgerRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LedgerRecordsTableTableManager get ledgerRecords =>
      $$LedgerRecordsTableTableManager(_db, _db.ledgerRecords);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db, _db.assets);
  $$PortfolioTargetsTableTableManager get portfolioTargets =>
      $$PortfolioTargetsTableTableManager(_db, _db.portfolioTargets);
  $$FavoriteLedgerRecordsTableTableManager get favoriteLedgerRecords =>
      $$FavoriteLedgerRecordsTableTableManager(_db, _db.favoriteLedgerRecords);
}
