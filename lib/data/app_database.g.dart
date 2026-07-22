// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChildrenTable extends Children with TableInfo<$ChildrenTable, Child> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChildrenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockAccountLabelMeta = const VerificationMeta(
    'stockAccountLabel',
  );
  @override
  late final GeneratedColumn<String> stockAccountLabel =
      GeneratedColumn<String>(
        'stock_account_label',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _avatarPathMeta = const VerificationMeta(
    'avatarPath',
  );
  @override
  late final GeneratedColumn<String> avatarPath = GeneratedColumn<String>(
    'avatar_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weeklyAllowanceDefaultMeta =
      const VerificationMeta('weeklyAllowanceDefault');
  @override
  late final GeneratedColumn<int> weeklyAllowanceDefault = GeneratedColumn<int>(
    'weekly_allowance_default',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _payDayOfWeekMeta = const VerificationMeta(
    'payDayOfWeek',
  );
  @override
  late final GeneratedColumn<int> payDayOfWeek = GeneratedColumn<int>(
    'pay_day_of_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _autoTransferThresholdMeta =
      const VerificationMeta('autoTransferThreshold');
  @override
  late final GeneratedColumn<int> autoTransferThreshold = GeneratedColumn<int>(
    'auto_transfer_threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100000),
  );
  static const VerificationMeta _bonusEnabledMeta = const VerificationMeta(
    'bonusEnabled',
  );
  @override
  late final GeneratedColumn<bool> bonusEnabled = GeneratedColumn<bool>(
    'bonus_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bonus_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _bonusDayOfWeekMeta = const VerificationMeta(
    'bonusDayOfWeek',
  );
  @override
  late final GeneratedColumn<int> bonusDayOfWeek = GeneratedColumn<int>(
    'bonus_day_of_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _bonusThresholdMeta = const VerificationMeta(
    'bonusThreshold',
  );
  @override
  late final GeneratedColumn<int> bonusThreshold = GeneratedColumn<int>(
    'bonus_threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1000),
  );
  static const VerificationMeta _bonusAmountMeta = const VerificationMeta(
    'bonusAmount',
  );
  @override
  late final GeneratedColumn<int> bonusAmount = GeneratedColumn<int>(
    'bonus_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(500),
  );
  static const VerificationMeta _interestEnabledMeta = const VerificationMeta(
    'interestEnabled',
  );
  @override
  late final GeneratedColumn<bool> interestEnabled = GeneratedColumn<bool>(
    'interest_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("interest_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _interestPercentMeta = const VerificationMeta(
    'interestPercent',
  );
  @override
  late final GeneratedColumn<double> interestPercent = GeneratedColumn<double>(
    'interest_percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _interestPeriodMeta = const VerificationMeta(
    'interestPeriod',
  );
  @override
  late final GeneratedColumn<int> interestPeriod = GeneratedColumn<int>(
    'interest_period',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _interestUseBankRateMeta =
      const VerificationMeta('interestUseBankRate');
  @override
  late final GeneratedColumn<bool> interestUseBankRate = GeneratedColumn<bool>(
    'interest_use_bank_rate',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("interest_use_bank_rate" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _interestMultiplierMeta =
      const VerificationMeta('interestMultiplier');
  @override
  late final GeneratedColumn<double> interestMultiplier =
      GeneratedColumn<double>(
        'interest_multiplier',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1.0),
      );
  static const VerificationMeta _quizRewardMeta = const VerificationMeta(
    'quizReward',
  );
  @override
  late final GeneratedColumn<int> quizReward = GeneratedColumn<int>(
    'quiz_reward',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    stockAccountLabel,
    avatarPath,
    weeklyAllowanceDefault,
    payDayOfWeek,
    autoTransferThreshold,
    bonusEnabled,
    bonusDayOfWeek,
    bonusThreshold,
    bonusAmount,
    interestEnabled,
    interestPercent,
    interestPeriod,
    interestUseBankRate,
    interestMultiplier,
    quizReward,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'children';
  @override
  VerificationContext validateIntegrity(
    Insertable<Child> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('stock_account_label')) {
      context.handle(
        _stockAccountLabelMeta,
        stockAccountLabel.isAcceptableOrUnknown(
          data['stock_account_label']!,
          _stockAccountLabelMeta,
        ),
      );
    }
    if (data.containsKey('avatar_path')) {
      context.handle(
        _avatarPathMeta,
        avatarPath.isAcceptableOrUnknown(data['avatar_path']!, _avatarPathMeta),
      );
    }
    if (data.containsKey('weekly_allowance_default')) {
      context.handle(
        _weeklyAllowanceDefaultMeta,
        weeklyAllowanceDefault.isAcceptableOrUnknown(
          data['weekly_allowance_default']!,
          _weeklyAllowanceDefaultMeta,
        ),
      );
    }
    if (data.containsKey('pay_day_of_week')) {
      context.handle(
        _payDayOfWeekMeta,
        payDayOfWeek.isAcceptableOrUnknown(
          data['pay_day_of_week']!,
          _payDayOfWeekMeta,
        ),
      );
    }
    if (data.containsKey('auto_transfer_threshold')) {
      context.handle(
        _autoTransferThresholdMeta,
        autoTransferThreshold.isAcceptableOrUnknown(
          data['auto_transfer_threshold']!,
          _autoTransferThresholdMeta,
        ),
      );
    }
    if (data.containsKey('bonus_enabled')) {
      context.handle(
        _bonusEnabledMeta,
        bonusEnabled.isAcceptableOrUnknown(
          data['bonus_enabled']!,
          _bonusEnabledMeta,
        ),
      );
    }
    if (data.containsKey('bonus_day_of_week')) {
      context.handle(
        _bonusDayOfWeekMeta,
        bonusDayOfWeek.isAcceptableOrUnknown(
          data['bonus_day_of_week']!,
          _bonusDayOfWeekMeta,
        ),
      );
    }
    if (data.containsKey('bonus_threshold')) {
      context.handle(
        _bonusThresholdMeta,
        bonusThreshold.isAcceptableOrUnknown(
          data['bonus_threshold']!,
          _bonusThresholdMeta,
        ),
      );
    }
    if (data.containsKey('bonus_amount')) {
      context.handle(
        _bonusAmountMeta,
        bonusAmount.isAcceptableOrUnknown(
          data['bonus_amount']!,
          _bonusAmountMeta,
        ),
      );
    }
    if (data.containsKey('interest_enabled')) {
      context.handle(
        _interestEnabledMeta,
        interestEnabled.isAcceptableOrUnknown(
          data['interest_enabled']!,
          _interestEnabledMeta,
        ),
      );
    }
    if (data.containsKey('interest_percent')) {
      context.handle(
        _interestPercentMeta,
        interestPercent.isAcceptableOrUnknown(
          data['interest_percent']!,
          _interestPercentMeta,
        ),
      );
    }
    if (data.containsKey('interest_period')) {
      context.handle(
        _interestPeriodMeta,
        interestPeriod.isAcceptableOrUnknown(
          data['interest_period']!,
          _interestPeriodMeta,
        ),
      );
    }
    if (data.containsKey('interest_use_bank_rate')) {
      context.handle(
        _interestUseBankRateMeta,
        interestUseBankRate.isAcceptableOrUnknown(
          data['interest_use_bank_rate']!,
          _interestUseBankRateMeta,
        ),
      );
    }
    if (data.containsKey('interest_multiplier')) {
      context.handle(
        _interestMultiplierMeta,
        interestMultiplier.isAcceptableOrUnknown(
          data['interest_multiplier']!,
          _interestMultiplierMeta,
        ),
      );
    }
    if (data.containsKey('quiz_reward')) {
      context.handle(
        _quizRewardMeta,
        quizReward.isAcceptableOrUnknown(data['quiz_reward']!, _quizRewardMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Child map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Child(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      stockAccountLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_account_label'],
      ),
      avatarPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_path'],
      ),
      weeklyAllowanceDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekly_allowance_default'],
      )!,
      payDayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pay_day_of_week'],
      )!,
      autoTransferThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_transfer_threshold'],
      )!,
      bonusEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bonus_enabled'],
      )!,
      bonusDayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bonus_day_of_week'],
      )!,
      bonusThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bonus_threshold'],
      )!,
      bonusAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bonus_amount'],
      )!,
      interestEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}interest_enabled'],
      )!,
      interestPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interest_percent'],
      )!,
      interestPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interest_period'],
      )!,
      interestUseBankRate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}interest_use_bank_rate'],
      )!,
      interestMultiplier: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interest_multiplier'],
      )!,
      quizReward: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quiz_reward'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ChildrenTable createAlias(String alias) {
    return $ChildrenTable(attachedDatabase, alias);
  }
}

class Child extends DataClass implements Insertable<Child> {
  final String id;
  final String name;
  final String? stockAccountLabel;

  /// 프로필 사진 파일 경로 (기기 로컬. 동기화 시에는 전파하지 않음)
  final String? avatarPath;
  final int weeklyAllowanceDefault;
  final int payDayOfWeek;
  final int autoTransferThreshold;
  final bool bonusEnabled;
  final int bonusDayOfWeek;
  final int bonusThreshold;
  final int bonusAmount;
  final bool interestEnabled;
  final double interestPercent;
  final int interestPeriod;

  /// true면 이자율을 "실제 은행 예금금리 × 배수"로 계산한다(교육 목적: 진짜 금리와 연동).
  /// 은행 금리를 못 가져온 경우엔 interestPercent로 폴백.
  final bool interestUseBankRate;

  /// 은행 예금금리의 몇 배를 줄지. 기본 1배(은행 정기예금과 동일한 현실적 이자율).
  final double interestMultiplier;

  /// 경제왕 퀴즈 정답 1문제당 보상(원). 해설 보고 다시 맞히면 이 금액의 절반.
  final int quizReward;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Child({
    required this.id,
    required this.name,
    this.stockAccountLabel,
    this.avatarPath,
    required this.weeklyAllowanceDefault,
    required this.payDayOfWeek,
    required this.autoTransferThreshold,
    required this.bonusEnabled,
    required this.bonusDayOfWeek,
    required this.bonusThreshold,
    required this.bonusAmount,
    required this.interestEnabled,
    required this.interestPercent,
    required this.interestPeriod,
    required this.interestUseBankRate,
    required this.interestMultiplier,
    required this.quizReward,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || stockAccountLabel != null) {
      map['stock_account_label'] = Variable<String>(stockAccountLabel);
    }
    if (!nullToAbsent || avatarPath != null) {
      map['avatar_path'] = Variable<String>(avatarPath);
    }
    map['weekly_allowance_default'] = Variable<int>(weeklyAllowanceDefault);
    map['pay_day_of_week'] = Variable<int>(payDayOfWeek);
    map['auto_transfer_threshold'] = Variable<int>(autoTransferThreshold);
    map['bonus_enabled'] = Variable<bool>(bonusEnabled);
    map['bonus_day_of_week'] = Variable<int>(bonusDayOfWeek);
    map['bonus_threshold'] = Variable<int>(bonusThreshold);
    map['bonus_amount'] = Variable<int>(bonusAmount);
    map['interest_enabled'] = Variable<bool>(interestEnabled);
    map['interest_percent'] = Variable<double>(interestPercent);
    map['interest_period'] = Variable<int>(interestPeriod);
    map['interest_use_bank_rate'] = Variable<bool>(interestUseBankRate);
    map['interest_multiplier'] = Variable<double>(interestMultiplier);
    map['quiz_reward'] = Variable<int>(quizReward);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ChildrenCompanion toCompanion(bool nullToAbsent) {
    return ChildrenCompanion(
      id: Value(id),
      name: Value(name),
      stockAccountLabel: stockAccountLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(stockAccountLabel),
      avatarPath: avatarPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarPath),
      weeklyAllowanceDefault: Value(weeklyAllowanceDefault),
      payDayOfWeek: Value(payDayOfWeek),
      autoTransferThreshold: Value(autoTransferThreshold),
      bonusEnabled: Value(bonusEnabled),
      bonusDayOfWeek: Value(bonusDayOfWeek),
      bonusThreshold: Value(bonusThreshold),
      bonusAmount: Value(bonusAmount),
      interestEnabled: Value(interestEnabled),
      interestPercent: Value(interestPercent),
      interestPeriod: Value(interestPeriod),
      interestUseBankRate: Value(interestUseBankRate),
      interestMultiplier: Value(interestMultiplier),
      quizReward: Value(quizReward),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Child.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Child(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      stockAccountLabel: serializer.fromJson<String?>(
        json['stockAccountLabel'],
      ),
      avatarPath: serializer.fromJson<String?>(json['avatarPath']),
      weeklyAllowanceDefault: serializer.fromJson<int>(
        json['weeklyAllowanceDefault'],
      ),
      payDayOfWeek: serializer.fromJson<int>(json['payDayOfWeek']),
      autoTransferThreshold: serializer.fromJson<int>(
        json['autoTransferThreshold'],
      ),
      bonusEnabled: serializer.fromJson<bool>(json['bonusEnabled']),
      bonusDayOfWeek: serializer.fromJson<int>(json['bonusDayOfWeek']),
      bonusThreshold: serializer.fromJson<int>(json['bonusThreshold']),
      bonusAmount: serializer.fromJson<int>(json['bonusAmount']),
      interestEnabled: serializer.fromJson<bool>(json['interestEnabled']),
      interestPercent: serializer.fromJson<double>(json['interestPercent']),
      interestPeriod: serializer.fromJson<int>(json['interestPeriod']),
      interestUseBankRate: serializer.fromJson<bool>(
        json['interestUseBankRate'],
      ),
      interestMultiplier: serializer.fromJson<double>(
        json['interestMultiplier'],
      ),
      quizReward: serializer.fromJson<int>(json['quizReward']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'stockAccountLabel': serializer.toJson<String?>(stockAccountLabel),
      'avatarPath': serializer.toJson<String?>(avatarPath),
      'weeklyAllowanceDefault': serializer.toJson<int>(weeklyAllowanceDefault),
      'payDayOfWeek': serializer.toJson<int>(payDayOfWeek),
      'autoTransferThreshold': serializer.toJson<int>(autoTransferThreshold),
      'bonusEnabled': serializer.toJson<bool>(bonusEnabled),
      'bonusDayOfWeek': serializer.toJson<int>(bonusDayOfWeek),
      'bonusThreshold': serializer.toJson<int>(bonusThreshold),
      'bonusAmount': serializer.toJson<int>(bonusAmount),
      'interestEnabled': serializer.toJson<bool>(interestEnabled),
      'interestPercent': serializer.toJson<double>(interestPercent),
      'interestPeriod': serializer.toJson<int>(interestPeriod),
      'interestUseBankRate': serializer.toJson<bool>(interestUseBankRate),
      'interestMultiplier': serializer.toJson<double>(interestMultiplier),
      'quizReward': serializer.toJson<int>(quizReward),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Child copyWith({
    String? id,
    String? name,
    Value<String?> stockAccountLabel = const Value.absent(),
    Value<String?> avatarPath = const Value.absent(),
    int? weeklyAllowanceDefault,
    int? payDayOfWeek,
    int? autoTransferThreshold,
    bool? bonusEnabled,
    int? bonusDayOfWeek,
    int? bonusThreshold,
    int? bonusAmount,
    bool? interestEnabled,
    double? interestPercent,
    int? interestPeriod,
    bool? interestUseBankRate,
    double? interestMultiplier,
    int? quizReward,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Child(
    id: id ?? this.id,
    name: name ?? this.name,
    stockAccountLabel: stockAccountLabel.present
        ? stockAccountLabel.value
        : this.stockAccountLabel,
    avatarPath: avatarPath.present ? avatarPath.value : this.avatarPath,
    weeklyAllowanceDefault:
        weeklyAllowanceDefault ?? this.weeklyAllowanceDefault,
    payDayOfWeek: payDayOfWeek ?? this.payDayOfWeek,
    autoTransferThreshold: autoTransferThreshold ?? this.autoTransferThreshold,
    bonusEnabled: bonusEnabled ?? this.bonusEnabled,
    bonusDayOfWeek: bonusDayOfWeek ?? this.bonusDayOfWeek,
    bonusThreshold: bonusThreshold ?? this.bonusThreshold,
    bonusAmount: bonusAmount ?? this.bonusAmount,
    interestEnabled: interestEnabled ?? this.interestEnabled,
    interestPercent: interestPercent ?? this.interestPercent,
    interestPeriod: interestPeriod ?? this.interestPeriod,
    interestUseBankRate: interestUseBankRate ?? this.interestUseBankRate,
    interestMultiplier: interestMultiplier ?? this.interestMultiplier,
    quizReward: quizReward ?? this.quizReward,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Child copyWithCompanion(ChildrenCompanion data) {
    return Child(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      stockAccountLabel: data.stockAccountLabel.present
          ? data.stockAccountLabel.value
          : this.stockAccountLabel,
      avatarPath: data.avatarPath.present
          ? data.avatarPath.value
          : this.avatarPath,
      weeklyAllowanceDefault: data.weeklyAllowanceDefault.present
          ? data.weeklyAllowanceDefault.value
          : this.weeklyAllowanceDefault,
      payDayOfWeek: data.payDayOfWeek.present
          ? data.payDayOfWeek.value
          : this.payDayOfWeek,
      autoTransferThreshold: data.autoTransferThreshold.present
          ? data.autoTransferThreshold.value
          : this.autoTransferThreshold,
      bonusEnabled: data.bonusEnabled.present
          ? data.bonusEnabled.value
          : this.bonusEnabled,
      bonusDayOfWeek: data.bonusDayOfWeek.present
          ? data.bonusDayOfWeek.value
          : this.bonusDayOfWeek,
      bonusThreshold: data.bonusThreshold.present
          ? data.bonusThreshold.value
          : this.bonusThreshold,
      bonusAmount: data.bonusAmount.present
          ? data.bonusAmount.value
          : this.bonusAmount,
      interestEnabled: data.interestEnabled.present
          ? data.interestEnabled.value
          : this.interestEnabled,
      interestPercent: data.interestPercent.present
          ? data.interestPercent.value
          : this.interestPercent,
      interestPeriod: data.interestPeriod.present
          ? data.interestPeriod.value
          : this.interestPeriod,
      interestUseBankRate: data.interestUseBankRate.present
          ? data.interestUseBankRate.value
          : this.interestUseBankRate,
      interestMultiplier: data.interestMultiplier.present
          ? data.interestMultiplier.value
          : this.interestMultiplier,
      quizReward: data.quizReward.present
          ? data.quizReward.value
          : this.quizReward,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Child(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stockAccountLabel: $stockAccountLabel, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('weeklyAllowanceDefault: $weeklyAllowanceDefault, ')
          ..write('payDayOfWeek: $payDayOfWeek, ')
          ..write('autoTransferThreshold: $autoTransferThreshold, ')
          ..write('bonusEnabled: $bonusEnabled, ')
          ..write('bonusDayOfWeek: $bonusDayOfWeek, ')
          ..write('bonusThreshold: $bonusThreshold, ')
          ..write('bonusAmount: $bonusAmount, ')
          ..write('interestEnabled: $interestEnabled, ')
          ..write('interestPercent: $interestPercent, ')
          ..write('interestPeriod: $interestPeriod, ')
          ..write('interestUseBankRate: $interestUseBankRate, ')
          ..write('interestMultiplier: $interestMultiplier, ')
          ..write('quizReward: $quizReward, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    stockAccountLabel,
    avatarPath,
    weeklyAllowanceDefault,
    payDayOfWeek,
    autoTransferThreshold,
    bonusEnabled,
    bonusDayOfWeek,
    bonusThreshold,
    bonusAmount,
    interestEnabled,
    interestPercent,
    interestPeriod,
    interestUseBankRate,
    interestMultiplier,
    quizReward,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Child &&
          other.id == this.id &&
          other.name == this.name &&
          other.stockAccountLabel == this.stockAccountLabel &&
          other.avatarPath == this.avatarPath &&
          other.weeklyAllowanceDefault == this.weeklyAllowanceDefault &&
          other.payDayOfWeek == this.payDayOfWeek &&
          other.autoTransferThreshold == this.autoTransferThreshold &&
          other.bonusEnabled == this.bonusEnabled &&
          other.bonusDayOfWeek == this.bonusDayOfWeek &&
          other.bonusThreshold == this.bonusThreshold &&
          other.bonusAmount == this.bonusAmount &&
          other.interestEnabled == this.interestEnabled &&
          other.interestPercent == this.interestPercent &&
          other.interestPeriod == this.interestPeriod &&
          other.interestUseBankRate == this.interestUseBankRate &&
          other.interestMultiplier == this.interestMultiplier &&
          other.quizReward == this.quizReward &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ChildrenCompanion extends UpdateCompanion<Child> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> stockAccountLabel;
  final Value<String?> avatarPath;
  final Value<int> weeklyAllowanceDefault;
  final Value<int> payDayOfWeek;
  final Value<int> autoTransferThreshold;
  final Value<bool> bonusEnabled;
  final Value<int> bonusDayOfWeek;
  final Value<int> bonusThreshold;
  final Value<int> bonusAmount;
  final Value<bool> interestEnabled;
  final Value<double> interestPercent;
  final Value<int> interestPeriod;
  final Value<bool> interestUseBankRate;
  final Value<double> interestMultiplier;
  final Value<int> quizReward;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ChildrenCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.stockAccountLabel = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.weeklyAllowanceDefault = const Value.absent(),
    this.payDayOfWeek = const Value.absent(),
    this.autoTransferThreshold = const Value.absent(),
    this.bonusEnabled = const Value.absent(),
    this.bonusDayOfWeek = const Value.absent(),
    this.bonusThreshold = const Value.absent(),
    this.bonusAmount = const Value.absent(),
    this.interestEnabled = const Value.absent(),
    this.interestPercent = const Value.absent(),
    this.interestPeriod = const Value.absent(),
    this.interestUseBankRate = const Value.absent(),
    this.interestMultiplier = const Value.absent(),
    this.quizReward = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChildrenCompanion.insert({
    required String id,
    required String name,
    this.stockAccountLabel = const Value.absent(),
    this.avatarPath = const Value.absent(),
    this.weeklyAllowanceDefault = const Value.absent(),
    this.payDayOfWeek = const Value.absent(),
    this.autoTransferThreshold = const Value.absent(),
    this.bonusEnabled = const Value.absent(),
    this.bonusDayOfWeek = const Value.absent(),
    this.bonusThreshold = const Value.absent(),
    this.bonusAmount = const Value.absent(),
    this.interestEnabled = const Value.absent(),
    this.interestPercent = const Value.absent(),
    this.interestPeriod = const Value.absent(),
    this.interestUseBankRate = const Value.absent(),
    this.interestMultiplier = const Value.absent(),
    this.quizReward = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Child> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? stockAccountLabel,
    Expression<String>? avatarPath,
    Expression<int>? weeklyAllowanceDefault,
    Expression<int>? payDayOfWeek,
    Expression<int>? autoTransferThreshold,
    Expression<bool>? bonusEnabled,
    Expression<int>? bonusDayOfWeek,
    Expression<int>? bonusThreshold,
    Expression<int>? bonusAmount,
    Expression<bool>? interestEnabled,
    Expression<double>? interestPercent,
    Expression<int>? interestPeriod,
    Expression<bool>? interestUseBankRate,
    Expression<double>? interestMultiplier,
    Expression<int>? quizReward,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (stockAccountLabel != null) 'stock_account_label': stockAccountLabel,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (weeklyAllowanceDefault != null)
        'weekly_allowance_default': weeklyAllowanceDefault,
      if (payDayOfWeek != null) 'pay_day_of_week': payDayOfWeek,
      if (autoTransferThreshold != null)
        'auto_transfer_threshold': autoTransferThreshold,
      if (bonusEnabled != null) 'bonus_enabled': bonusEnabled,
      if (bonusDayOfWeek != null) 'bonus_day_of_week': bonusDayOfWeek,
      if (bonusThreshold != null) 'bonus_threshold': bonusThreshold,
      if (bonusAmount != null) 'bonus_amount': bonusAmount,
      if (interestEnabled != null) 'interest_enabled': interestEnabled,
      if (interestPercent != null) 'interest_percent': interestPercent,
      if (interestPeriod != null) 'interest_period': interestPeriod,
      if (interestUseBankRate != null)
        'interest_use_bank_rate': interestUseBankRate,
      if (interestMultiplier != null) 'interest_multiplier': interestMultiplier,
      if (quizReward != null) 'quiz_reward': quizReward,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChildrenCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? stockAccountLabel,
    Value<String?>? avatarPath,
    Value<int>? weeklyAllowanceDefault,
    Value<int>? payDayOfWeek,
    Value<int>? autoTransferThreshold,
    Value<bool>? bonusEnabled,
    Value<int>? bonusDayOfWeek,
    Value<int>? bonusThreshold,
    Value<int>? bonusAmount,
    Value<bool>? interestEnabled,
    Value<double>? interestPercent,
    Value<int>? interestPeriod,
    Value<bool>? interestUseBankRate,
    Value<double>? interestMultiplier,
    Value<int>? quizReward,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ChildrenCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      stockAccountLabel: stockAccountLabel ?? this.stockAccountLabel,
      avatarPath: avatarPath ?? this.avatarPath,
      weeklyAllowanceDefault:
          weeklyAllowanceDefault ?? this.weeklyAllowanceDefault,
      payDayOfWeek: payDayOfWeek ?? this.payDayOfWeek,
      autoTransferThreshold:
          autoTransferThreshold ?? this.autoTransferThreshold,
      bonusEnabled: bonusEnabled ?? this.bonusEnabled,
      bonusDayOfWeek: bonusDayOfWeek ?? this.bonusDayOfWeek,
      bonusThreshold: bonusThreshold ?? this.bonusThreshold,
      bonusAmount: bonusAmount ?? this.bonusAmount,
      interestEnabled: interestEnabled ?? this.interestEnabled,
      interestPercent: interestPercent ?? this.interestPercent,
      interestPeriod: interestPeriod ?? this.interestPeriod,
      interestUseBankRate: interestUseBankRate ?? this.interestUseBankRate,
      interestMultiplier: interestMultiplier ?? this.interestMultiplier,
      quizReward: quizReward ?? this.quizReward,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (stockAccountLabel.present) {
      map['stock_account_label'] = Variable<String>(stockAccountLabel.value);
    }
    if (avatarPath.present) {
      map['avatar_path'] = Variable<String>(avatarPath.value);
    }
    if (weeklyAllowanceDefault.present) {
      map['weekly_allowance_default'] = Variable<int>(
        weeklyAllowanceDefault.value,
      );
    }
    if (payDayOfWeek.present) {
      map['pay_day_of_week'] = Variable<int>(payDayOfWeek.value);
    }
    if (autoTransferThreshold.present) {
      map['auto_transfer_threshold'] = Variable<int>(
        autoTransferThreshold.value,
      );
    }
    if (bonusEnabled.present) {
      map['bonus_enabled'] = Variable<bool>(bonusEnabled.value);
    }
    if (bonusDayOfWeek.present) {
      map['bonus_day_of_week'] = Variable<int>(bonusDayOfWeek.value);
    }
    if (bonusThreshold.present) {
      map['bonus_threshold'] = Variable<int>(bonusThreshold.value);
    }
    if (bonusAmount.present) {
      map['bonus_amount'] = Variable<int>(bonusAmount.value);
    }
    if (interestEnabled.present) {
      map['interest_enabled'] = Variable<bool>(interestEnabled.value);
    }
    if (interestPercent.present) {
      map['interest_percent'] = Variable<double>(interestPercent.value);
    }
    if (interestPeriod.present) {
      map['interest_period'] = Variable<int>(interestPeriod.value);
    }
    if (interestUseBankRate.present) {
      map['interest_use_bank_rate'] = Variable<bool>(interestUseBankRate.value);
    }
    if (interestMultiplier.present) {
      map['interest_multiplier'] = Variable<double>(interestMultiplier.value);
    }
    if (quizReward.present) {
      map['quiz_reward'] = Variable<int>(quizReward.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChildrenCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('stockAccountLabel: $stockAccountLabel, ')
          ..write('avatarPath: $avatarPath, ')
          ..write('weeklyAllowanceDefault: $weeklyAllowanceDefault, ')
          ..write('payDayOfWeek: $payDayOfWeek, ')
          ..write('autoTransferThreshold: $autoTransferThreshold, ')
          ..write('bonusEnabled: $bonusEnabled, ')
          ..write('bonusDayOfWeek: $bonusDayOfWeek, ')
          ..write('bonusThreshold: $bonusThreshold, ')
          ..write('bonusAmount: $bonusAmount, ')
          ..write('interestEnabled: $interestEnabled, ')
          ..write('interestPercent: $interestPercent, ')
          ..write('interestPeriod: $interestPeriod, ')
          ..write('interestUseBankRate: $interestUseBankRate, ')
          ..write('interestMultiplier: $interestMultiplier, ')
          ..write('quizReward: $quizReward, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AllowanceSchedulesTable extends AllowanceSchedules
    with TableInfo<$AllowanceSchedulesTable, AllowanceSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AllowanceSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta(
    'scheduledDate',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>(
        'scheduled_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
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
  static const VerificationMeta _isPaidMeta = const VerificationMeta('isPaid');
  @override
  late final GeneratedColumn<bool> isPaid = GeneratedColumn<bool>(
    'is_paid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_paid" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _paidDateMeta = const VerificationMeta(
    'paidDate',
  );
  @override
  late final GeneratedColumn<DateTime> paidDate = GeneratedColumn<DateTime>(
    'paid_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _editedByMeta = const VerificationMeta(
    'editedBy',
  );
  @override
  late final GeneratedColumn<String> editedBy = GeneratedColumn<String>(
    'edited_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    scheduledDate,
    amount,
    isPaid,
    paidDate,
    editedBy,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'allowance_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<AllowanceSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(
          data['scheduled_date']!,
          _scheduledDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledDateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('is_paid')) {
      context.handle(
        _isPaidMeta,
        isPaid.isAcceptableOrUnknown(data['is_paid']!, _isPaidMeta),
      );
    }
    if (data.containsKey('paid_date')) {
      context.handle(
        _paidDateMeta,
        paidDate.isAcceptableOrUnknown(data['paid_date']!, _paidDateMeta),
      );
    }
    if (data.containsKey('edited_by')) {
      context.handle(
        _editedByMeta,
        editedBy.isAcceptableOrUnknown(data['edited_by']!, _editedByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AllowanceSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AllowanceSchedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      )!,
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_date'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      isPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_paid'],
      )!,
      paidDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_date'],
      ),
      editedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edited_by'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $AllowanceSchedulesTable createAlias(String alias) {
    return $AllowanceSchedulesTable(attachedDatabase, alias);
  }
}

class AllowanceSchedule extends DataClass
    implements Insertable<AllowanceSchedule> {
  final String id;
  final String childId;
  final DateTime scheduledDate;
  final int amount;
  final bool isPaid;
  final DateTime? paidDate;
  final String editedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const AllowanceSchedule({
    required this.id,
    required this.childId,
    required this.scheduledDate,
    required this.amount,
    required this.isPaid,
    this.paidDate,
    required this.editedBy,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    map['amount'] = Variable<int>(amount);
    map['is_paid'] = Variable<bool>(isPaid);
    if (!nullToAbsent || paidDate != null) {
      map['paid_date'] = Variable<DateTime>(paidDate);
    }
    map['edited_by'] = Variable<String>(editedBy);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  AllowanceSchedulesCompanion toCompanion(bool nullToAbsent) {
    return AllowanceSchedulesCompanion(
      id: Value(id),
      childId: Value(childId),
      scheduledDate: Value(scheduledDate),
      amount: Value(amount),
      isPaid: Value(isPaid),
      paidDate: paidDate == null && nullToAbsent
          ? const Value.absent()
          : Value(paidDate),
      editedBy: Value(editedBy),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory AllowanceSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AllowanceSchedule(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      scheduledDate: serializer.fromJson<DateTime>(json['scheduledDate']),
      amount: serializer.fromJson<int>(json['amount']),
      isPaid: serializer.fromJson<bool>(json['isPaid']),
      paidDate: serializer.fromJson<DateTime?>(json['paidDate']),
      editedBy: serializer.fromJson<String>(json['editedBy']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'scheduledDate': serializer.toJson<DateTime>(scheduledDate),
      'amount': serializer.toJson<int>(amount),
      'isPaid': serializer.toJson<bool>(isPaid),
      'paidDate': serializer.toJson<DateTime?>(paidDate),
      'editedBy': serializer.toJson<String>(editedBy),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  AllowanceSchedule copyWith({
    String? id,
    String? childId,
    DateTime? scheduledDate,
    int? amount,
    bool? isPaid,
    Value<DateTime?> paidDate = const Value.absent(),
    String? editedBy,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => AllowanceSchedule(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    scheduledDate: scheduledDate ?? this.scheduledDate,
    amount: amount ?? this.amount,
    isPaid: isPaid ?? this.isPaid,
    paidDate: paidDate.present ? paidDate.value : this.paidDate,
    editedBy: editedBy ?? this.editedBy,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  AllowanceSchedule copyWithCompanion(AllowanceSchedulesCompanion data) {
    return AllowanceSchedule(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
      amount: data.amount.present ? data.amount.value : this.amount,
      isPaid: data.isPaid.present ? data.isPaid.value : this.isPaid,
      paidDate: data.paidDate.present ? data.paidDate.value : this.paidDate,
      editedBy: data.editedBy.present ? data.editedBy.value : this.editedBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AllowanceSchedule(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('amount: $amount, ')
          ..write('isPaid: $isPaid, ')
          ..write('paidDate: $paidDate, ')
          ..write('editedBy: $editedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    childId,
    scheduledDate,
    amount,
    isPaid,
    paidDate,
    editedBy,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AllowanceSchedule &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.scheduledDate == this.scheduledDate &&
          other.amount == this.amount &&
          other.isPaid == this.isPaid &&
          other.paidDate == this.paidDate &&
          other.editedBy == this.editedBy &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class AllowanceSchedulesCompanion extends UpdateCompanion<AllowanceSchedule> {
  final Value<String> id;
  final Value<String> childId;
  final Value<DateTime> scheduledDate;
  final Value<int> amount;
  final Value<bool> isPaid;
  final Value<DateTime?> paidDate;
  final Value<String> editedBy;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const AllowanceSchedulesCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.amount = const Value.absent(),
    this.isPaid = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.editedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AllowanceSchedulesCompanion.insert({
    required String id,
    required String childId,
    required DateTime scheduledDate,
    required int amount,
    this.isPaid = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.editedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       childId = Value(childId),
       scheduledDate = Value(scheduledDate),
       amount = Value(amount);
  static Insertable<AllowanceSchedule> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<DateTime>? scheduledDate,
    Expression<int>? amount,
    Expression<bool>? isPaid,
    Expression<DateTime>? paidDate,
    Expression<String>? editedBy,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (amount != null) 'amount': amount,
      if (isPaid != null) 'is_paid': isPaid,
      if (paidDate != null) 'paid_date': paidDate,
      if (editedBy != null) 'edited_by': editedBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AllowanceSchedulesCompanion copyWith({
    Value<String>? id,
    Value<String>? childId,
    Value<DateTime>? scheduledDate,
    Value<int>? amount,
    Value<bool>? isPaid,
    Value<DateTime?>? paidDate,
    Value<String>? editedBy,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return AllowanceSchedulesCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
      paidDate: paidDate ?? this.paidDate,
      editedBy: editedBy ?? this.editedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (isPaid.present) {
      map['is_paid'] = Variable<bool>(isPaid.value);
    }
    if (paidDate.present) {
      map['paid_date'] = Variable<DateTime>(paidDate.value);
    }
    if (editedBy.present) {
      map['edited_by'] = Variable<String>(editedBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AllowanceSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('amount: $amount, ')
          ..write('isPaid: $isPaid, ')
          ..write('paidDate: $paidDate, ')
          ..write('editedBy: $editedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionEntriesTable extends TransactionEntries
    with TableInfo<$TransactionEntriesTable, TransactionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _flowMeta = const VerificationMeta('flow');
  @override
  late final GeneratedColumn<String> flow = GeneratedColumn<String>(
    'flow',
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
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedScheduleIdMeta = const VerificationMeta(
    'linkedScheduleId',
  );
  @override
  late final GeneratedColumn<String> linkedScheduleId = GeneratedColumn<String>(
    'linked_schedule_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _giverMeta = const VerificationMeta('giver');
  @override
  late final GeneratedColumn<String> giver = GeneratedColumn<String>(
    'giver',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _editedByMeta = const VerificationMeta(
    'editedBy',
  );
  @override
  late final GeneratedColumn<String> editedBy = GeneratedColumn<String>(
    'edited_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    date,
    flow,
    category,
    amount,
    memo,
    linkedScheduleId,
    giver,
    editedBy,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('flow')) {
      context.handle(
        _flowMeta,
        flow.isAcceptableOrUnknown(data['flow']!, _flowMeta),
      );
    } else if (isInserting) {
      context.missing(_flowMeta);
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
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('linked_schedule_id')) {
      context.handle(
        _linkedScheduleIdMeta,
        linkedScheduleId.isAcceptableOrUnknown(
          data['linked_schedule_id']!,
          _linkedScheduleIdMeta,
        ),
      );
    }
    if (data.containsKey('giver')) {
      context.handle(
        _giverMeta,
        giver.isAcceptableOrUnknown(data['giver']!, _giverMeta),
      );
    }
    if (data.containsKey('edited_by')) {
      context.handle(
        _editedByMeta,
        editedBy.isAcceptableOrUnknown(data['edited_by']!, _editedByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      flow: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flow'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      linkedScheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_schedule_id'],
      ),
      giver: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}giver'],
      ),
      editedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edited_by'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TransactionEntriesTable createAlias(String alias) {
    return $TransactionEntriesTable(attachedDatabase, alias);
  }
}

class TransactionEntry extends DataClass
    implements Insertable<TransactionEntry> {
  final String id;
  final String childId;
  final DateTime date;
  final String flow;
  final String category;
  final int amount;
  final String? memo;
  final String? linkedScheduleId;

  /// 특별 수입일 때 "누가 줬는지" (엄마/아빠/할머니 등). 정기용돈·지출에는 사용 안 함.
  final String? giver;
  final String editedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TransactionEntry({
    required this.id,
    required this.childId,
    required this.date,
    required this.flow,
    required this.category,
    required this.amount,
    this.memo,
    this.linkedScheduleId,
    this.giver,
    required this.editedBy,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['date'] = Variable<DateTime>(date);
    map['flow'] = Variable<String>(flow);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    if (!nullToAbsent || linkedScheduleId != null) {
      map['linked_schedule_id'] = Variable<String>(linkedScheduleId);
    }
    if (!nullToAbsent || giver != null) {
      map['giver'] = Variable<String>(giver);
    }
    map['edited_by'] = Variable<String>(editedBy);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TransactionEntriesCompanion toCompanion(bool nullToAbsent) {
    return TransactionEntriesCompanion(
      id: Value(id),
      childId: Value(childId),
      date: Value(date),
      flow: Value(flow),
      category: Value(category),
      amount: Value(amount),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      linkedScheduleId: linkedScheduleId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedScheduleId),
      giver: giver == null && nullToAbsent
          ? const Value.absent()
          : Value(giver),
      editedBy: Value(editedBy),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TransactionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionEntry(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      date: serializer.fromJson<DateTime>(json['date']),
      flow: serializer.fromJson<String>(json['flow']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<int>(json['amount']),
      memo: serializer.fromJson<String?>(json['memo']),
      linkedScheduleId: serializer.fromJson<String?>(json['linkedScheduleId']),
      giver: serializer.fromJson<String?>(json['giver']),
      editedBy: serializer.fromJson<String>(json['editedBy']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'date': serializer.toJson<DateTime>(date),
      'flow': serializer.toJson<String>(flow),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<int>(amount),
      'memo': serializer.toJson<String?>(memo),
      'linkedScheduleId': serializer.toJson<String?>(linkedScheduleId),
      'giver': serializer.toJson<String?>(giver),
      'editedBy': serializer.toJson<String>(editedBy),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TransactionEntry copyWith({
    String? id,
    String? childId,
    DateTime? date,
    String? flow,
    String? category,
    int? amount,
    Value<String?> memo = const Value.absent(),
    Value<String?> linkedScheduleId = const Value.absent(),
    Value<String?> giver = const Value.absent(),
    String? editedBy,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TransactionEntry(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    date: date ?? this.date,
    flow: flow ?? this.flow,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    memo: memo.present ? memo.value : this.memo,
    linkedScheduleId: linkedScheduleId.present
        ? linkedScheduleId.value
        : this.linkedScheduleId,
    giver: giver.present ? giver.value : this.giver,
    editedBy: editedBy ?? this.editedBy,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TransactionEntry copyWithCompanion(TransactionEntriesCompanion data) {
    return TransactionEntry(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      date: data.date.present ? data.date.value : this.date,
      flow: data.flow.present ? data.flow.value : this.flow,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      memo: data.memo.present ? data.memo.value : this.memo,
      linkedScheduleId: data.linkedScheduleId.present
          ? data.linkedScheduleId.value
          : this.linkedScheduleId,
      giver: data.giver.present ? data.giver.value : this.giver,
      editedBy: data.editedBy.present ? data.editedBy.value : this.editedBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionEntry(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('date: $date, ')
          ..write('flow: $flow, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('memo: $memo, ')
          ..write('linkedScheduleId: $linkedScheduleId, ')
          ..write('giver: $giver, ')
          ..write('editedBy: $editedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    childId,
    date,
    flow,
    category,
    amount,
    memo,
    linkedScheduleId,
    giver,
    editedBy,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionEntry &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.date == this.date &&
          other.flow == this.flow &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.memo == this.memo &&
          other.linkedScheduleId == this.linkedScheduleId &&
          other.giver == this.giver &&
          other.editedBy == this.editedBy &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TransactionEntriesCompanion extends UpdateCompanion<TransactionEntry> {
  final Value<String> id;
  final Value<String> childId;
  final Value<DateTime> date;
  final Value<String> flow;
  final Value<String> category;
  final Value<int> amount;
  final Value<String?> memo;
  final Value<String?> linkedScheduleId;
  final Value<String?> giver;
  final Value<String> editedBy;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TransactionEntriesCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.date = const Value.absent(),
    this.flow = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.memo = const Value.absent(),
    this.linkedScheduleId = const Value.absent(),
    this.giver = const Value.absent(),
    this.editedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionEntriesCompanion.insert({
    required String id,
    required String childId,
    required DateTime date,
    required String flow,
    required String category,
    required int amount,
    this.memo = const Value.absent(),
    this.linkedScheduleId = const Value.absent(),
    this.giver = const Value.absent(),
    this.editedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       childId = Value(childId),
       date = Value(date),
       flow = Value(flow),
       category = Value(category),
       amount = Value(amount);
  static Insertable<TransactionEntry> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<DateTime>? date,
    Expression<String>? flow,
    Expression<String>? category,
    Expression<int>? amount,
    Expression<String>? memo,
    Expression<String>? linkedScheduleId,
    Expression<String>? giver,
    Expression<String>? editedBy,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (date != null) 'date': date,
      if (flow != null) 'flow': flow,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (memo != null) 'memo': memo,
      if (linkedScheduleId != null) 'linked_schedule_id': linkedScheduleId,
      if (giver != null) 'giver': giver,
      if (editedBy != null) 'edited_by': editedBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? childId,
    Value<DateTime>? date,
    Value<String>? flow,
    Value<String>? category,
    Value<int>? amount,
    Value<String?>? memo,
    Value<String?>? linkedScheduleId,
    Value<String?>? giver,
    Value<String>? editedBy,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TransactionEntriesCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      date: date ?? this.date,
      flow: flow ?? this.flow,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      memo: memo ?? this.memo,
      linkedScheduleId: linkedScheduleId ?? this.linkedScheduleId,
      giver: giver ?? this.giver,
      editedBy: editedBy ?? this.editedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (flow.present) {
      map['flow'] = Variable<String>(flow.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (linkedScheduleId.present) {
      map['linked_schedule_id'] = Variable<String>(linkedScheduleId.value);
    }
    if (giver.present) {
      map['giver'] = Variable<String>(giver.value);
    }
    if (editedBy.present) {
      map['edited_by'] = Variable<String>(editedBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionEntriesCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('date: $date, ')
          ..write('flow: $flow, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('memo: $memo, ')
          ..write('linkedScheduleId: $linkedScheduleId, ')
          ..write('giver: $giver, ')
          ..write('editedBy: $editedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockTransfersTable extends StockTransfers
    with TableInfo<$StockTransfersTable, StockTransfer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockTransfersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _tickerMeta = const VerificationMeta('ticker');
  @override
  late final GeneratedColumn<String> ticker = GeneratedColumn<String>(
    'ticker',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _companyNameMeta = const VerificationMeta(
    'companyName',
  );
  @override
  late final GeneratedColumn<String> companyName = GeneratedColumn<String>(
    'company_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _editedByMeta = const VerificationMeta(
    'editedBy',
  );
  @override
  late final GeneratedColumn<String> editedBy = GeneratedColumn<String>(
    'edited_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    date,
    amount,
    memo,
    ticker,
    companyName,
    shares,
    editedBy,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_transfers';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockTransfer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('ticker')) {
      context.handle(
        _tickerMeta,
        ticker.isAcceptableOrUnknown(data['ticker']!, _tickerMeta),
      );
    }
    if (data.containsKey('company_name')) {
      context.handle(
        _companyNameMeta,
        companyName.isAcceptableOrUnknown(
          data['company_name']!,
          _companyNameMeta,
        ),
      );
    }
    if (data.containsKey('shares')) {
      context.handle(
        _sharesMeta,
        shares.isAcceptableOrUnknown(data['shares']!, _sharesMeta),
      );
    }
    if (data.containsKey('edited_by')) {
      context.handle(
        _editedByMeta,
        editedBy.isAcceptableOrUnknown(data['edited_by']!, _editedByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockTransfer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockTransfer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      ticker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ticker'],
      ),
      companyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company_name'],
      ),
      shares: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}shares'],
      ),
      editedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edited_by'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $StockTransfersTable createAlias(String alias) {
    return $StockTransfersTable(attachedDatabase, alias);
  }
}

class StockTransfer extends DataClass implements Insertable<StockTransfer> {
  final String id;
  final String childId;
  final DateTime date;
  final int amount;
  final String? memo;
  final String? ticker;
  final String? companyName;
  final double? shares;
  final String editedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const StockTransfer({
    required this.id,
    required this.childId,
    required this.date,
    required this.amount,
    this.memo,
    this.ticker,
    this.companyName,
    this.shares,
    required this.editedBy,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['date'] = Variable<DateTime>(date);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    if (!nullToAbsent || ticker != null) {
      map['ticker'] = Variable<String>(ticker);
    }
    if (!nullToAbsent || companyName != null) {
      map['company_name'] = Variable<String>(companyName);
    }
    if (!nullToAbsent || shares != null) {
      map['shares'] = Variable<double>(shares);
    }
    map['edited_by'] = Variable<String>(editedBy);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  StockTransfersCompanion toCompanion(bool nullToAbsent) {
    return StockTransfersCompanion(
      id: Value(id),
      childId: Value(childId),
      date: Value(date),
      amount: Value(amount),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      ticker: ticker == null && nullToAbsent
          ? const Value.absent()
          : Value(ticker),
      companyName: companyName == null && nullToAbsent
          ? const Value.absent()
          : Value(companyName),
      shares: shares == null && nullToAbsent
          ? const Value.absent()
          : Value(shares),
      editedBy: Value(editedBy),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory StockTransfer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockTransfer(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      date: serializer.fromJson<DateTime>(json['date']),
      amount: serializer.fromJson<int>(json['amount']),
      memo: serializer.fromJson<String?>(json['memo']),
      ticker: serializer.fromJson<String?>(json['ticker']),
      companyName: serializer.fromJson<String?>(json['companyName']),
      shares: serializer.fromJson<double?>(json['shares']),
      editedBy: serializer.fromJson<String>(json['editedBy']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'date': serializer.toJson<DateTime>(date),
      'amount': serializer.toJson<int>(amount),
      'memo': serializer.toJson<String?>(memo),
      'ticker': serializer.toJson<String?>(ticker),
      'companyName': serializer.toJson<String?>(companyName),
      'shares': serializer.toJson<double?>(shares),
      'editedBy': serializer.toJson<String>(editedBy),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  StockTransfer copyWith({
    String? id,
    String? childId,
    DateTime? date,
    int? amount,
    Value<String?> memo = const Value.absent(),
    Value<String?> ticker = const Value.absent(),
    Value<String?> companyName = const Value.absent(),
    Value<double?> shares = const Value.absent(),
    String? editedBy,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => StockTransfer(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    date: date ?? this.date,
    amount: amount ?? this.amount,
    memo: memo.present ? memo.value : this.memo,
    ticker: ticker.present ? ticker.value : this.ticker,
    companyName: companyName.present ? companyName.value : this.companyName,
    shares: shares.present ? shares.value : this.shares,
    editedBy: editedBy ?? this.editedBy,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  StockTransfer copyWithCompanion(StockTransfersCompanion data) {
    return StockTransfer(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      date: data.date.present ? data.date.value : this.date,
      amount: data.amount.present ? data.amount.value : this.amount,
      memo: data.memo.present ? data.memo.value : this.memo,
      ticker: data.ticker.present ? data.ticker.value : this.ticker,
      companyName: data.companyName.present
          ? data.companyName.value
          : this.companyName,
      shares: data.shares.present ? data.shares.value : this.shares,
      editedBy: data.editedBy.present ? data.editedBy.value : this.editedBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockTransfer(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('memo: $memo, ')
          ..write('ticker: $ticker, ')
          ..write('companyName: $companyName, ')
          ..write('shares: $shares, ')
          ..write('editedBy: $editedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    childId,
    date,
    amount,
    memo,
    ticker,
    companyName,
    shares,
    editedBy,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockTransfer &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.date == this.date &&
          other.amount == this.amount &&
          other.memo == this.memo &&
          other.ticker == this.ticker &&
          other.companyName == this.companyName &&
          other.shares == this.shares &&
          other.editedBy == this.editedBy &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class StockTransfersCompanion extends UpdateCompanion<StockTransfer> {
  final Value<String> id;
  final Value<String> childId;
  final Value<DateTime> date;
  final Value<int> amount;
  final Value<String?> memo;
  final Value<String?> ticker;
  final Value<String?> companyName;
  final Value<double?> shares;
  final Value<String> editedBy;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const StockTransfersCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.date = const Value.absent(),
    this.amount = const Value.absent(),
    this.memo = const Value.absent(),
    this.ticker = const Value.absent(),
    this.companyName = const Value.absent(),
    this.shares = const Value.absent(),
    this.editedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockTransfersCompanion.insert({
    required String id,
    required String childId,
    required DateTime date,
    required int amount,
    this.memo = const Value.absent(),
    this.ticker = const Value.absent(),
    this.companyName = const Value.absent(),
    this.shares = const Value.absent(),
    this.editedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       childId = Value(childId),
       date = Value(date),
       amount = Value(amount);
  static Insertable<StockTransfer> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<DateTime>? date,
    Expression<int>? amount,
    Expression<String>? memo,
    Expression<String>? ticker,
    Expression<String>? companyName,
    Expression<double>? shares,
    Expression<String>? editedBy,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (date != null) 'date': date,
      if (amount != null) 'amount': amount,
      if (memo != null) 'memo': memo,
      if (ticker != null) 'ticker': ticker,
      if (companyName != null) 'company_name': companyName,
      if (shares != null) 'shares': shares,
      if (editedBy != null) 'edited_by': editedBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockTransfersCompanion copyWith({
    Value<String>? id,
    Value<String>? childId,
    Value<DateTime>? date,
    Value<int>? amount,
    Value<String?>? memo,
    Value<String?>? ticker,
    Value<String?>? companyName,
    Value<double?>? shares,
    Value<String>? editedBy,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return StockTransfersCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      memo: memo ?? this.memo,
      ticker: ticker ?? this.ticker,
      companyName: companyName ?? this.companyName,
      shares: shares ?? this.shares,
      editedBy: editedBy ?? this.editedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (ticker.present) {
      map['ticker'] = Variable<String>(ticker.value);
    }
    if (companyName.present) {
      map['company_name'] = Variable<String>(companyName.value);
    }
    if (shares.present) {
      map['shares'] = Variable<double>(shares.value);
    }
    if (editedBy.present) {
      map['edited_by'] = Variable<String>(editedBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockTransfersCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('memo: $memo, ')
          ..write('ticker: $ticker, ')
          ..write('companyName: $companyName, ')
          ..write('shares: $shares, ')
          ..write('editedBy: $editedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChangeLogsTable extends ChangeLogs
    with TableInfo<$ChangeLogsTable, ChangeLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChangeLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _editedByMeta = const VerificationMeta(
    'editedBy',
  );
  @override
  late final GeneratedColumn<String> editedBy = GeneratedColumn<String>(
    'edited_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changedAtMeta = const VerificationMeta(
    'changedAt',
  );
  @override
  late final GeneratedColumn<DateTime> changedAt = GeneratedColumn<DateTime>(
    'changed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    editedBy,
    changedAt,
    summary,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'change_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChangeLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('edited_by')) {
      context.handle(
        _editedByMeta,
        editedBy.isAcceptableOrUnknown(data['edited_by']!, _editedByMeta),
      );
    } else if (isInserting) {
      context.missing(_editedByMeta);
    }
    if (data.containsKey('changed_at')) {
      context.handle(
        _changedAtMeta,
        changedAt.isAcceptableOrUnknown(data['changed_at']!, _changedAtMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChangeLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChangeLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      editedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edited_by'],
      )!,
      changedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}changed_at'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
    );
  }

  @override
  $ChangeLogsTable createAlias(String alias) {
    return $ChangeLogsTable(attachedDatabase, alias);
  }
}

class ChangeLog extends DataClass implements Insertable<ChangeLog> {
  final String id;
  final String entityType;
  final String entityId;
  final String editedBy;
  final DateTime changedAt;
  final String summary;
  const ChangeLog({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.editedBy,
    required this.changedAt,
    required this.summary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['edited_by'] = Variable<String>(editedBy);
    map['changed_at'] = Variable<DateTime>(changedAt);
    map['summary'] = Variable<String>(summary);
    return map;
  }

  ChangeLogsCompanion toCompanion(bool nullToAbsent) {
    return ChangeLogsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      editedBy: Value(editedBy),
      changedAt: Value(changedAt),
      summary: Value(summary),
    );
  }

  factory ChangeLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChangeLog(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      editedBy: serializer.fromJson<String>(json['editedBy']),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
      summary: serializer.fromJson<String>(json['summary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'editedBy': serializer.toJson<String>(editedBy),
      'changedAt': serializer.toJson<DateTime>(changedAt),
      'summary': serializer.toJson<String>(summary),
    };
  }

  ChangeLog copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? editedBy,
    DateTime? changedAt,
    String? summary,
  }) => ChangeLog(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    editedBy: editedBy ?? this.editedBy,
    changedAt: changedAt ?? this.changedAt,
    summary: summary ?? this.summary,
  );
  ChangeLog copyWithCompanion(ChangeLogsCompanion data) {
    return ChangeLog(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      editedBy: data.editedBy.present ? data.editedBy.value : this.editedBy,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
      summary: data.summary.present ? data.summary.value : this.summary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChangeLog(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('editedBy: $editedBy, ')
          ..write('changedAt: $changedAt, ')
          ..write('summary: $summary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entityType, entityId, editedBy, changedAt, summary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChangeLog &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.editedBy == this.editedBy &&
          other.changedAt == this.changedAt &&
          other.summary == this.summary);
}

class ChangeLogsCompanion extends UpdateCompanion<ChangeLog> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> editedBy;
  final Value<DateTime> changedAt;
  final Value<String> summary;
  final Value<int> rowid;
  const ChangeLogsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.editedBy = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.summary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChangeLogsCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String editedBy,
    this.changedAt = const Value.absent(),
    required String summary,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       editedBy = Value(editedBy),
       summary = Value(summary);
  static Insertable<ChangeLog> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? editedBy,
    Expression<DateTime>? changedAt,
    Expression<String>? summary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (editedBy != null) 'edited_by': editedBy,
      if (changedAt != null) 'changed_at': changedAt,
      if (summary != null) 'summary': summary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChangeLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? editedBy,
    Value<DateTime>? changedAt,
    Value<String>? summary,
    Value<int>? rowid,
  }) {
    return ChangeLogsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      editedBy: editedBy ?? this.editedBy,
      changedAt: changedAt ?? this.changedAt,
      summary: summary ?? this.summary,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (editedBy.present) {
      map['edited_by'] = Variable<String>(editedBy.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<DateTime>(changedAt.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChangeLogsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('editedBy: $editedBy, ')
          ..write('changedAt: $changedAt, ')
          ..write('summary: $summary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetAmountMeta = const VerificationMeta(
    'targetAmount',
  );
  @override
  late final GeneratedColumn<int> targetAmount = GeneratedColumn<int>(
    'target_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _achievedAtMeta = const VerificationMeta(
    'achievedAt',
  );
  @override
  late final GeneratedColumn<DateTime> achievedAt = GeneratedColumn<DateTime>(
    'achieved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _editedByMeta = const VerificationMeta(
    'editedBy',
  );
  @override
  late final GeneratedColumn<String> editedBy = GeneratedColumn<String>(
    'edited_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    title,
    targetAmount,
    createdAt,
    achievedAt,
    editedBy,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Goal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
        _targetAmountMeta,
        targetAmount.isAcceptableOrUnknown(
          data['target_amount']!,
          _targetAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('achieved_at')) {
      context.handle(
        _achievedAtMeta,
        achievedAt.isAcceptableOrUnknown(data['achieved_at']!, _achievedAtMeta),
      );
    }
    if (data.containsKey('edited_by')) {
      context.handle(
        _editedByMeta,
        editedBy.isAcceptableOrUnknown(data['edited_by']!, _editedByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      targetAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_amount'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      achievedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}achieved_at'],
      ),
      editedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edited_by'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final String id;
  final String childId;
  final String title;
  final int targetAmount;
  final DateTime createdAt;
  final DateTime? achievedAt;
  final String editedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Goal({
    required this.id,
    required this.childId,
    required this.title,
    required this.targetAmount,
    required this.createdAt,
    this.achievedAt,
    required this.editedBy,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['title'] = Variable<String>(title);
    map['target_amount'] = Variable<int>(targetAmount);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || achievedAt != null) {
      map['achieved_at'] = Variable<DateTime>(achievedAt);
    }
    map['edited_by'] = Variable<String>(editedBy);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      childId: Value(childId),
      title: Value(title),
      targetAmount: Value(targetAmount),
      createdAt: Value(createdAt),
      achievedAt: achievedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(achievedAt),
      editedBy: Value(editedBy),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Goal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      title: serializer.fromJson<String>(json['title']),
      targetAmount: serializer.fromJson<int>(json['targetAmount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      achievedAt: serializer.fromJson<DateTime?>(json['achievedAt']),
      editedBy: serializer.fromJson<String>(json['editedBy']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'title': serializer.toJson<String>(title),
      'targetAmount': serializer.toJson<int>(targetAmount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'achievedAt': serializer.toJson<DateTime?>(achievedAt),
      'editedBy': serializer.toJson<String>(editedBy),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Goal copyWith({
    String? id,
    String? childId,
    String? title,
    int? targetAmount,
    DateTime? createdAt,
    Value<DateTime?> achievedAt = const Value.absent(),
    String? editedBy,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Goal(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    title: title ?? this.title,
    targetAmount: targetAmount ?? this.targetAmount,
    createdAt: createdAt ?? this.createdAt,
    achievedAt: achievedAt.present ? achievedAt.value : this.achievedAt,
    editedBy: editedBy ?? this.editedBy,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      title: data.title.present ? data.title.value : this.title,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      achievedAt: data.achievedAt.present
          ? data.achievedAt.value
          : this.achievedAt,
      editedBy: data.editedBy.present ? data.editedBy.value : this.editedBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('title: $title, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('editedBy: $editedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    childId,
    title,
    targetAmount,
    createdAt,
    achievedAt,
    editedBy,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.title == this.title &&
          other.targetAmount == this.targetAmount &&
          other.createdAt == this.createdAt &&
          other.achievedAt == this.achievedAt &&
          other.editedBy == this.editedBy &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<String> id;
  final Value<String> childId;
  final Value<String> title;
  final Value<int> targetAmount;
  final Value<DateTime> createdAt;
  final Value<DateTime?> achievedAt;
  final Value<String> editedBy;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.title = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.editedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String id,
    required String childId,
    required String title,
    required int targetAmount,
    this.createdAt = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.editedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       childId = Value(childId),
       title = Value(title),
       targetAmount = Value(targetAmount);
  static Insertable<Goal> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<String>? title,
    Expression<int>? targetAmount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? achievedAt,
    Expression<String>? editedBy,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (title != null) 'title': title,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (createdAt != null) 'created_at': createdAt,
      if (achievedAt != null) 'achieved_at': achievedAt,
      if (editedBy != null) 'edited_by': editedBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? childId,
    Value<String>? title,
    Value<int>? targetAmount,
    Value<DateTime>? createdAt,
    Value<DateTime?>? achievedAt,
    Value<String>? editedBy,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      createdAt: createdAt ?? this.createdAt,
      achievedAt: achievedAt ?? this.achievedAt,
      editedBy: editedBy ?? this.editedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<int>(targetAmount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<DateTime>(achievedAt.value);
    }
    if (editedBy.present) {
      map['edited_by'] = Variable<String>(editedBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('title: $title, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('editedBy: $editedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AllowanceRatesTable extends AllowanceRates
    with TableInfo<$AllowanceRatesTable, AllowanceRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AllowanceRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
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
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _changedAtMeta = const VerificationMeta(
    'changedAt',
  );
  @override
  late final GeneratedColumn<DateTime> changedAt = GeneratedColumn<DateTime>(
    'changed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _editedByMeta = const VerificationMeta(
    'editedBy',
  );
  @override
  late final GeneratedColumn<String> editedBy = GeneratedColumn<String>(
    'edited_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    amount,
    note,
    changedAt,
    editedBy,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'allowance_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<AllowanceRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('changed_at')) {
      context.handle(
        _changedAtMeta,
        changedAt.isAcceptableOrUnknown(data['changed_at']!, _changedAtMeta),
      );
    }
    if (data.containsKey('edited_by')) {
      context.handle(
        _editedByMeta,
        editedBy.isAcceptableOrUnknown(data['edited_by']!, _editedByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AllowanceRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AllowanceRate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      changedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}changed_at'],
      )!,
      editedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edited_by'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $AllowanceRatesTable createAlias(String alias) {
    return $AllowanceRatesTable(attachedDatabase, alias);
  }
}

class AllowanceRate extends DataClass implements Insertable<AllowanceRate> {
  final String id;
  final String childId;
  final int amount;
  final String? note;
  final DateTime changedAt;
  final String editedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const AllowanceRate({
    required this.id,
    required this.childId,
    required this.amount,
    this.note,
    required this.changedAt,
    required this.editedBy,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['changed_at'] = Variable<DateTime>(changedAt);
    map['edited_by'] = Variable<String>(editedBy);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  AllowanceRatesCompanion toCompanion(bool nullToAbsent) {
    return AllowanceRatesCompanion(
      id: Value(id),
      childId: Value(childId),
      amount: Value(amount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      changedAt: Value(changedAt),
      editedBy: Value(editedBy),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory AllowanceRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AllowanceRate(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      amount: serializer.fromJson<int>(json['amount']),
      note: serializer.fromJson<String?>(json['note']),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
      editedBy: serializer.fromJson<String>(json['editedBy']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'amount': serializer.toJson<int>(amount),
      'note': serializer.toJson<String?>(note),
      'changedAt': serializer.toJson<DateTime>(changedAt),
      'editedBy': serializer.toJson<String>(editedBy),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  AllowanceRate copyWith({
    String? id,
    String? childId,
    int? amount,
    Value<String?> note = const Value.absent(),
    DateTime? changedAt,
    String? editedBy,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => AllowanceRate(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    amount: amount ?? this.amount,
    note: note.present ? note.value : this.note,
    changedAt: changedAt ?? this.changedAt,
    editedBy: editedBy ?? this.editedBy,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  AllowanceRate copyWithCompanion(AllowanceRatesCompanion data) {
    return AllowanceRate(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      amount: data.amount.present ? data.amount.value : this.amount,
      note: data.note.present ? data.note.value : this.note,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
      editedBy: data.editedBy.present ? data.editedBy.value : this.editedBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AllowanceRate(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('changedAt: $changedAt, ')
          ..write('editedBy: $editedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    childId,
    amount,
    note,
    changedAt,
    editedBy,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AllowanceRate &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.amount == this.amount &&
          other.note == this.note &&
          other.changedAt == this.changedAt &&
          other.editedBy == this.editedBy &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class AllowanceRatesCompanion extends UpdateCompanion<AllowanceRate> {
  final Value<String> id;
  final Value<String> childId;
  final Value<int> amount;
  final Value<String?> note;
  final Value<DateTime> changedAt;
  final Value<String> editedBy;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const AllowanceRatesCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.editedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AllowanceRatesCompanion.insert({
    required String id,
    required String childId,
    required int amount,
    this.note = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.editedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       childId = Value(childId),
       amount = Value(amount);
  static Insertable<AllowanceRate> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<int>? amount,
    Expression<String>? note,
    Expression<DateTime>? changedAt,
    Expression<String>? editedBy,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (changedAt != null) 'changed_at': changedAt,
      if (editedBy != null) 'edited_by': editedBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AllowanceRatesCompanion copyWith({
    Value<String>? id,
    Value<String>? childId,
    Value<int>? amount,
    Value<String?>? note,
    Value<DateTime>? changedAt,
    Value<String>? editedBy,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return AllowanceRatesCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      changedAt: changedAt ?? this.changedAt,
      editedBy: editedBy ?? this.editedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<DateTime>(changedAt.value);
    }
    if (editedBy.present) {
      map['edited_by'] = Variable<String>(editedBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AllowanceRatesCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('changedAt: $changedAt, ')
          ..write('editedBy: $editedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RequestsTable extends Requests with TableInfo<$RequestsTable, Request> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _resolvedByMeta = const VerificationMeta(
    'resolvedBy',
  );
  @override
  late final GeneratedColumn<String> resolvedBy = GeneratedColumn<String>(
    'resolved_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _editedByMeta = const VerificationMeta(
    'editedBy',
  );
  @override
  late final GeneratedColumn<String> editedBy = GeneratedColumn<String>(
    'edited_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    type,
    title,
    amount,
    memo,
    status,
    createdBy,
    createdAt,
    resolvedBy,
    resolvedAt,
    editedBy,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<Request> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('resolved_by')) {
      context.handle(
        _resolvedByMeta,
        resolvedBy.isAcceptableOrUnknown(data['resolved_by']!, _resolvedByMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('edited_by')) {
      context.handle(
        _editedByMeta,
        editedBy.isAcceptableOrUnknown(data['edited_by']!, _editedByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Request map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Request(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      resolvedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolved_by'],
      ),
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
      editedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edited_by'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $RequestsTable createAlias(String alias) {
    return $RequestsTable(attachedDatabase, alias);
  }
}

class Request extends DataClass implements Insertable<Request> {
  final String id;
  final String childId;
  final String type;
  final String? title;
  final int amount;
  final String? memo;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final String? resolvedBy;
  final DateTime? resolvedAt;
  final String editedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Request({
    required this.id,
    required this.childId,
    required this.type,
    this.title,
    required this.amount,
    this.memo,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.resolvedBy,
    this.resolvedAt,
    required this.editedBy,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['status'] = Variable<String>(status);
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || resolvedBy != null) {
      map['resolved_by'] = Variable<String>(resolvedBy);
    }
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    map['edited_by'] = Variable<String>(editedBy);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  RequestsCompanion toCompanion(bool nullToAbsent) {
    return RequestsCompanion(
      id: Value(id),
      childId: Value(childId),
      type: Value(type),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      amount: Value(amount),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      status: Value(status),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      resolvedBy: resolvedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedBy),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      editedBy: Value(editedBy),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Request.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Request(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String?>(json['title']),
      amount: serializer.fromJson<int>(json['amount']),
      memo: serializer.fromJson<String?>(json['memo']),
      status: serializer.fromJson<String>(json['status']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      resolvedBy: serializer.fromJson<String?>(json['resolvedBy']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      editedBy: serializer.fromJson<String>(json['editedBy']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String?>(title),
      'amount': serializer.toJson<int>(amount),
      'memo': serializer.toJson<String?>(memo),
      'status': serializer.toJson<String>(status),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'resolvedBy': serializer.toJson<String?>(resolvedBy),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'editedBy': serializer.toJson<String>(editedBy),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Request copyWith({
    String? id,
    String? childId,
    String? type,
    Value<String?> title = const Value.absent(),
    int? amount,
    Value<String?> memo = const Value.absent(),
    String? status,
    String? createdBy,
    DateTime? createdAt,
    Value<String?> resolvedBy = const Value.absent(),
    Value<DateTime?> resolvedAt = const Value.absent(),
    String? editedBy,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Request(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    type: type ?? this.type,
    title: title.present ? title.value : this.title,
    amount: amount ?? this.amount,
    memo: memo.present ? memo.value : this.memo,
    status: status ?? this.status,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    resolvedBy: resolvedBy.present ? resolvedBy.value : this.resolvedBy,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    editedBy: editedBy ?? this.editedBy,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Request copyWithCompanion(RequestsCompanion data) {
    return Request(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      memo: data.memo.present ? data.memo.value : this.memo,
      status: data.status.present ? data.status.value : this.status,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      resolvedBy: data.resolvedBy.present
          ? data.resolvedBy.value
          : this.resolvedBy,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      editedBy: data.editedBy.present ? data.editedBy.value : this.editedBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Request(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('memo: $memo, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedBy: $resolvedBy, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('editedBy: $editedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    childId,
    type,
    title,
    amount,
    memo,
    status,
    createdBy,
    createdAt,
    resolvedBy,
    resolvedAt,
    editedBy,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Request &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.type == this.type &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.memo == this.memo &&
          other.status == this.status &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.resolvedBy == this.resolvedBy &&
          other.resolvedAt == this.resolvedAt &&
          other.editedBy == this.editedBy &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class RequestsCompanion extends UpdateCompanion<Request> {
  final Value<String> id;
  final Value<String> childId;
  final Value<String> type;
  final Value<String?> title;
  final Value<int> amount;
  final Value<String?> memo;
  final Value<String> status;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<String?> resolvedBy;
  final Value<DateTime?> resolvedAt;
  final Value<String> editedBy;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const RequestsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.memo = const Value.absent(),
    this.status = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.resolvedBy = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.editedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RequestsCompanion.insert({
    required String id,
    required String childId,
    required String type,
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.memo = const Value.absent(),
    this.status = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.resolvedBy = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.editedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       childId = Value(childId),
       type = Value(type);
  static Insertable<Request> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<int>? amount,
    Expression<String>? memo,
    Expression<String>? status,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<String>? resolvedBy,
    Expression<DateTime>? resolvedAt,
    Expression<String>? editedBy,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (memo != null) 'memo': memo,
      if (status != null) 'status': status,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (resolvedBy != null) 'resolved_by': resolvedBy,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (editedBy != null) 'edited_by': editedBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RequestsCompanion copyWith({
    Value<String>? id,
    Value<String>? childId,
    Value<String>? type,
    Value<String?>? title,
    Value<int>? amount,
    Value<String?>? memo,
    Value<String>? status,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<String?>? resolvedBy,
    Value<DateTime?>? resolvedAt,
    Value<String>? editedBy,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return RequestsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      type: type ?? this.type,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      memo: memo ?? this.memo,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      editedBy: editedBy ?? this.editedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (resolvedBy.present) {
      map['resolved_by'] = Variable<String>(resolvedBy.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (editedBy.present) {
      map['edited_by'] = Variable<String>(editedBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RequestsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('memo: $memo, ')
          ..write('status: $status, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedBy: $resolvedBy, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('editedBy: $editedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TiersTable extends Tiers with TableInfo<$TiersTable, Tier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TiersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thresholdMeta = const VerificationMeta(
    'threshold',
  );
  @override
  late final GeneratedColumn<int> threshold = GeneratedColumn<int>(
    'threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rewardMeta = const VerificationMeta('reward');
  @override
  late final GeneratedColumn<String> reward = GeneratedColumn<String>(
    'reward',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    sortOrder,
    threshold,
    title,
    icon,
    reward,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tiers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tier> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('threshold')) {
      context.handle(
        _thresholdMeta,
        threshold.isAcceptableOrUnknown(data['threshold']!, _thresholdMeta),
      );
    } else if (isInserting) {
      context.missing(_thresholdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('reward')) {
      context.handle(
        _rewardMeta,
        reward.isAcceptableOrUnknown(data['reward']!, _rewardMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tier(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      threshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}threshold'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      reward: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reward'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TiersTable createAlias(String alias) {
    return $TiersTable(attachedDatabase, alias);
  }
}

class Tier extends DataClass implements Insertable<Tier> {
  final String id;
  final String kind;
  final int sortOrder;
  final int threshold;
  final String title;
  final String icon;
  final String? reward;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Tier({
    required this.id,
    required this.kind,
    required this.sortOrder,
    required this.threshold,
    required this.title,
    required this.icon,
    this.reward,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['sort_order'] = Variable<int>(sortOrder);
    map['threshold'] = Variable<int>(threshold);
    map['title'] = Variable<String>(title);
    map['icon'] = Variable<String>(icon);
    if (!nullToAbsent || reward != null) {
      map['reward'] = Variable<String>(reward);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TiersCompanion toCompanion(bool nullToAbsent) {
    return TiersCompanion(
      id: Value(id),
      kind: Value(kind),
      sortOrder: Value(sortOrder),
      threshold: Value(threshold),
      title: Value(title),
      icon: Value(icon),
      reward: reward == null && nullToAbsent
          ? const Value.absent()
          : Value(reward),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Tier.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tier(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      threshold: serializer.fromJson<int>(json['threshold']),
      title: serializer.fromJson<String>(json['title']),
      icon: serializer.fromJson<String>(json['icon']),
      reward: serializer.fromJson<String?>(json['reward']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'threshold': serializer.toJson<int>(threshold),
      'title': serializer.toJson<String>(title),
      'icon': serializer.toJson<String>(icon),
      'reward': serializer.toJson<String?>(reward),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Tier copyWith({
    String? id,
    String? kind,
    int? sortOrder,
    int? threshold,
    String? title,
    String? icon,
    Value<String?> reward = const Value.absent(),
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Tier(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    sortOrder: sortOrder ?? this.sortOrder,
    threshold: threshold ?? this.threshold,
    title: title ?? this.title,
    icon: icon ?? this.icon,
    reward: reward.present ? reward.value : this.reward,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Tier copyWithCompanion(TiersCompanion data) {
    return Tier(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      threshold: data.threshold.present ? data.threshold.value : this.threshold,
      title: data.title.present ? data.title.value : this.title,
      icon: data.icon.present ? data.icon.value : this.icon,
      reward: data.reward.present ? data.reward.value : this.reward,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tier(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('threshold: $threshold, ')
          ..write('title: $title, ')
          ..write('icon: $icon, ')
          ..write('reward: $reward, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    sortOrder,
    threshold,
    title,
    icon,
    reward,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tier &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.sortOrder == this.sortOrder &&
          other.threshold == this.threshold &&
          other.title == this.title &&
          other.icon == this.icon &&
          other.reward == this.reward &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TiersCompanion extends UpdateCompanion<Tier> {
  final Value<String> id;
  final Value<String> kind;
  final Value<int> sortOrder;
  final Value<int> threshold;
  final Value<String> title;
  final Value<String> icon;
  final Value<String?> reward;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TiersCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.threshold = const Value.absent(),
    this.title = const Value.absent(),
    this.icon = const Value.absent(),
    this.reward = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TiersCompanion.insert({
    required String id,
    required String kind,
    required int sortOrder,
    required int threshold,
    required String title,
    required String icon,
    this.reward = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kind = Value(kind),
       sortOrder = Value(sortOrder),
       threshold = Value(threshold),
       title = Value(title),
       icon = Value(icon);
  static Insertable<Tier> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<int>? sortOrder,
    Expression<int>? threshold,
    Expression<String>? title,
    Expression<String>? icon,
    Expression<String>? reward,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (threshold != null) 'threshold': threshold,
      if (title != null) 'title': title,
      if (icon != null) 'icon': icon,
      if (reward != null) 'reward': reward,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TiersCompanion copyWith({
    Value<String>? id,
    Value<String>? kind,
    Value<int>? sortOrder,
    Value<int>? threshold,
    Value<String>? title,
    Value<String>? icon,
    Value<String?>? reward,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TiersCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      sortOrder: sortOrder ?? this.sortOrder,
      threshold: threshold ?? this.threshold,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      reward: reward ?? this.reward,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (threshold.present) {
      map['threshold'] = Variable<int>(threshold.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (reward.present) {
      map['reward'] = Variable<String>(reward.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TiersCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('threshold: $threshold, ')
          ..write('title: $title, ')
          ..write('icon: $icon, ')
          ..write('reward: $reward, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PromisesTable extends Promises with TableInfo<$PromisesTable, Promise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bonusPercentMeta = const VerificationMeta(
    'bonusPercent',
  );
  @override
  late final GeneratedColumn<double> bonusPercent = GeneratedColumn<double>(
    'bonus_percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.3),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    title,
    bonusPercent,
    enabled,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'promises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Promise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('bonus_percent')) {
      context.handle(
        _bonusPercentMeta,
        bonusPercent.isAcceptableOrUnknown(
          data['bonus_percent']!,
          _bonusPercentMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Promise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Promise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      bonusPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bonus_percent'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PromisesTable createAlias(String alias) {
    return $PromisesTable(attachedDatabase, alias);
  }
}

class Promise extends DataClass implements Insertable<Promise> {
  final String id;
  final String childId;
  final String title;
  final double bonusPercent;
  final bool enabled;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Promise({
    required this.id,
    required this.childId,
    required this.title,
    required this.bonusPercent,
    required this.enabled,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['title'] = Variable<String>(title);
    map['bonus_percent'] = Variable<double>(bonusPercent);
    map['enabled'] = Variable<bool>(enabled);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PromisesCompanion toCompanion(bool nullToAbsent) {
    return PromisesCompanion(
      id: Value(id),
      childId: Value(childId),
      title: Value(title),
      bonusPercent: Value(bonusPercent),
      enabled: Value(enabled),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Promise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Promise(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      title: serializer.fromJson<String>(json['title']),
      bonusPercent: serializer.fromJson<double>(json['bonusPercent']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'title': serializer.toJson<String>(title),
      'bonusPercent': serializer.toJson<double>(bonusPercent),
      'enabled': serializer.toJson<bool>(enabled),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Promise copyWith({
    String? id,
    String? childId,
    String? title,
    double? bonusPercent,
    bool? enabled,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Promise(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    title: title ?? this.title,
    bonusPercent: bonusPercent ?? this.bonusPercent,
    enabled: enabled ?? this.enabled,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Promise copyWithCompanion(PromisesCompanion data) {
    return Promise(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      title: data.title.present ? data.title.value : this.title,
      bonusPercent: data.bonusPercent.present
          ? data.bonusPercent.value
          : this.bonusPercent,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Promise(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('title: $title, ')
          ..write('bonusPercent: $bonusPercent, ')
          ..write('enabled: $enabled, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    childId,
    title,
    bonusPercent,
    enabled,
    sortOrder,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Promise &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.title == this.title &&
          other.bonusPercent == this.bonusPercent &&
          other.enabled == this.enabled &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PromisesCompanion extends UpdateCompanion<Promise> {
  final Value<String> id;
  final Value<String> childId;
  final Value<String> title;
  final Value<double> bonusPercent;
  final Value<bool> enabled;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PromisesCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.title = const Value.absent(),
    this.bonusPercent = const Value.absent(),
    this.enabled = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PromisesCompanion.insert({
    required String id,
    required String childId,
    required String title,
    this.bonusPercent = const Value.absent(),
    this.enabled = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       childId = Value(childId),
       title = Value(title);
  static Insertable<Promise> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<String>? title,
    Expression<double>? bonusPercent,
    Expression<bool>? enabled,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (title != null) 'title': title,
      if (bonusPercent != null) 'bonus_percent': bonusPercent,
      if (enabled != null) 'enabled': enabled,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PromisesCompanion copyWith({
    Value<String>? id,
    Value<String>? childId,
    Value<String>? title,
    Value<double>? bonusPercent,
    Value<bool>? enabled,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PromisesCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      title: title ?? this.title,
      bonusPercent: bonusPercent ?? this.bonusPercent,
      enabled: enabled ?? this.enabled,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (bonusPercent.present) {
      map['bonus_percent'] = Variable<double>(bonusPercent.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromisesCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('title: $title, ')
          ..write('bonusPercent: $bonusPercent, ')
          ..write('enabled: $enabled, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PromiseCommentsTable extends PromiseComments
    with TableInfo<$PromiseCommentsTable, PromiseComment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PromiseCommentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promiseIdMeta = const VerificationMeta(
    'promiseId',
  );
  @override
  late final GeneratedColumn<String> promiseId = GeneratedColumn<String>(
    'promise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('comment'),
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusEnabledMeta = const VerificationMeta(
    'statusEnabled',
  );
  @override
  late final GeneratedColumn<bool> statusEnabled = GeneratedColumn<bool>(
    'status_enabled',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("status_enabled" IN (0, 1))',
    ),
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    promiseId,
    childId,
    author,
    kind,
    message,
    statusEnabled,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'promise_comments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PromiseComment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('promise_id')) {
      context.handle(
        _promiseIdMeta,
        promiseId.isAcceptableOrUnknown(data['promise_id']!, _promiseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_promiseIdMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    if (data.containsKey('status_enabled')) {
      context.handle(
        _statusEnabledMeta,
        statusEnabled.isAcceptableOrUnknown(
          data['status_enabled']!,
          _statusEnabledMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PromiseComment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PromiseComment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      promiseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}promise_id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      ),
      statusEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}status_enabled'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PromiseCommentsTable createAlias(String alias) {
    return $PromiseCommentsTable(attachedDatabase, alias);
  }
}

class PromiseComment extends DataClass implements Insertable<PromiseComment> {
  final String id;
  final String promiseId;
  final String childId;
  final String author;
  final String kind;
  final String? message;
  final bool? statusEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const PromiseComment({
    required this.id,
    required this.promiseId,
    required this.childId,
    required this.author,
    required this.kind,
    this.message,
    this.statusEnabled,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['promise_id'] = Variable<String>(promiseId);
    map['child_id'] = Variable<String>(childId);
    map['author'] = Variable<String>(author);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    if (!nullToAbsent || statusEnabled != null) {
      map['status_enabled'] = Variable<bool>(statusEnabled);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PromiseCommentsCompanion toCompanion(bool nullToAbsent) {
    return PromiseCommentsCompanion(
      id: Value(id),
      promiseId: Value(promiseId),
      childId: Value(childId),
      author: Value(author),
      kind: Value(kind),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
      statusEnabled: statusEnabled == null && nullToAbsent
          ? const Value.absent()
          : Value(statusEnabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory PromiseComment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PromiseComment(
      id: serializer.fromJson<String>(json['id']),
      promiseId: serializer.fromJson<String>(json['promiseId']),
      childId: serializer.fromJson<String>(json['childId']),
      author: serializer.fromJson<String>(json['author']),
      kind: serializer.fromJson<String>(json['kind']),
      message: serializer.fromJson<String?>(json['message']),
      statusEnabled: serializer.fromJson<bool?>(json['statusEnabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'promiseId': serializer.toJson<String>(promiseId),
      'childId': serializer.toJson<String>(childId),
      'author': serializer.toJson<String>(author),
      'kind': serializer.toJson<String>(kind),
      'message': serializer.toJson<String?>(message),
      'statusEnabled': serializer.toJson<bool?>(statusEnabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  PromiseComment copyWith({
    String? id,
    String? promiseId,
    String? childId,
    String? author,
    String? kind,
    Value<String?> message = const Value.absent(),
    Value<bool?> statusEnabled = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => PromiseComment(
    id: id ?? this.id,
    promiseId: promiseId ?? this.promiseId,
    childId: childId ?? this.childId,
    author: author ?? this.author,
    kind: kind ?? this.kind,
    message: message.present ? message.value : this.message,
    statusEnabled: statusEnabled.present
        ? statusEnabled.value
        : this.statusEnabled,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  PromiseComment copyWithCompanion(PromiseCommentsCompanion data) {
    return PromiseComment(
      id: data.id.present ? data.id.value : this.id,
      promiseId: data.promiseId.present ? data.promiseId.value : this.promiseId,
      childId: data.childId.present ? data.childId.value : this.childId,
      author: data.author.present ? data.author.value : this.author,
      kind: data.kind.present ? data.kind.value : this.kind,
      message: data.message.present ? data.message.value : this.message,
      statusEnabled: data.statusEnabled.present
          ? data.statusEnabled.value
          : this.statusEnabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PromiseComment(')
          ..write('id: $id, ')
          ..write('promiseId: $promiseId, ')
          ..write('childId: $childId, ')
          ..write('author: $author, ')
          ..write('kind: $kind, ')
          ..write('message: $message, ')
          ..write('statusEnabled: $statusEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    promiseId,
    childId,
    author,
    kind,
    message,
    statusEnabled,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PromiseComment &&
          other.id == this.id &&
          other.promiseId == this.promiseId &&
          other.childId == this.childId &&
          other.author == this.author &&
          other.kind == this.kind &&
          other.message == this.message &&
          other.statusEnabled == this.statusEnabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PromiseCommentsCompanion extends UpdateCompanion<PromiseComment> {
  final Value<String> id;
  final Value<String> promiseId;
  final Value<String> childId;
  final Value<String> author;
  final Value<String> kind;
  final Value<String?> message;
  final Value<bool?> statusEnabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PromiseCommentsCompanion({
    this.id = const Value.absent(),
    this.promiseId = const Value.absent(),
    this.childId = const Value.absent(),
    this.author = const Value.absent(),
    this.kind = const Value.absent(),
    this.message = const Value.absent(),
    this.statusEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PromiseCommentsCompanion.insert({
    required String id,
    required String promiseId,
    required String childId,
    this.author = const Value.absent(),
    this.kind = const Value.absent(),
    this.message = const Value.absent(),
    this.statusEnabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       promiseId = Value(promiseId),
       childId = Value(childId);
  static Insertable<PromiseComment> custom({
    Expression<String>? id,
    Expression<String>? promiseId,
    Expression<String>? childId,
    Expression<String>? author,
    Expression<String>? kind,
    Expression<String>? message,
    Expression<bool>? statusEnabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (promiseId != null) 'promise_id': promiseId,
      if (childId != null) 'child_id': childId,
      if (author != null) 'author': author,
      if (kind != null) 'kind': kind,
      if (message != null) 'message': message,
      if (statusEnabled != null) 'status_enabled': statusEnabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PromiseCommentsCompanion copyWith({
    Value<String>? id,
    Value<String>? promiseId,
    Value<String>? childId,
    Value<String>? author,
    Value<String>? kind,
    Value<String?>? message,
    Value<bool?>? statusEnabled,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PromiseCommentsCompanion(
      id: id ?? this.id,
      promiseId: promiseId ?? this.promiseId,
      childId: childId ?? this.childId,
      author: author ?? this.author,
      kind: kind ?? this.kind,
      message: message ?? this.message,
      statusEnabled: statusEnabled ?? this.statusEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (promiseId.present) {
      map['promise_id'] = Variable<String>(promiseId.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (statusEnabled.present) {
      map['status_enabled'] = Variable<bool>(statusEnabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PromiseCommentsCompanion(')
          ..write('id: $id, ')
          ..write('promiseId: $promiseId, ')
          ..write('childId: $childId, ')
          ..write('author: $author, ')
          ..write('kind: $kind, ')
          ..write('message: $message, ')
          ..write('statusEnabled: $statusEnabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuizAttemptsTable extends QuizAttempts
    with TableInfo<$QuizAttemptsTable, QuizAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuizAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  @override
  late final GeneratedColumn<DateTime> weekStart = GeneratedColumn<DateTime>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstTryMeta = const VerificationMeta(
    'firstTry',
  );
  @override
  late final GeneratedColumn<bool> firstTry = GeneratedColumn<bool>(
    'first_try',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("first_try" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _correctMeta = const VerificationMeta(
    'correct',
  );
  @override
  late final GeneratedColumn<bool> correct = GeneratedColumn<bool>(
    'correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("correct" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pickedIndexMeta = const VerificationMeta(
    'pickedIndex',
  );
  @override
  late final GeneratedColumn<int> pickedIndex = GeneratedColumn<int>(
    'picked_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rewardMeta = const VerificationMeta('reward');
  @override
  late final GeneratedColumn<int> reward = GeneratedColumn<int>(
    'reward',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
    'answered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    questionId,
    weekStart,
    firstTry,
    correct,
    pickedIndex,
    reward,
    answeredAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuizAttempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    if (data.containsKey('first_try')) {
      context.handle(
        _firstTryMeta,
        firstTry.isAcceptableOrUnknown(data['first_try']!, _firstTryMeta),
      );
    }
    if (data.containsKey('correct')) {
      context.handle(
        _correctMeta,
        correct.isAcceptableOrUnknown(data['correct']!, _correctMeta),
      );
    }
    if (data.containsKey('picked_index')) {
      context.handle(
        _pickedIndexMeta,
        pickedIndex.isAcceptableOrUnknown(
          data['picked_index']!,
          _pickedIndexMeta,
        ),
      );
    }
    if (data.containsKey('reward')) {
      context.handle(
        _rewardMeta,
        reward.isAcceptableOrUnknown(data['reward']!, _rewardMeta),
      );
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuizAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizAttempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}week_start'],
      )!,
      firstTry: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}first_try'],
      )!,
      correct: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}correct'],
      )!,
      pickedIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}picked_index'],
      ),
      reward: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reward'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $QuizAttemptsTable createAlias(String alias) {
    return $QuizAttemptsTable(attachedDatabase, alias);
  }
}

class QuizAttempt extends DataClass implements Insertable<QuizAttempt> {
  final String id;
  final String childId;
  final String questionId;

  /// 그 주의 월요일(주차 식별용).
  final DateTime weekStart;

  /// 첫 시도에 맞췄는지 (true면 전액, 해설 보고 재시도로 맞추면 false)
  final bool firstTry;
  final bool correct;

  /// 마지막으로 고른 보기 번호(기록 화면에서 "내가 뭘 골랐는지" 보여주려고 저장).
  final int? pickedIndex;
  final int reward;
  final DateTime answeredAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const QuizAttempt({
    required this.id,
    required this.childId,
    required this.questionId,
    required this.weekStart,
    required this.firstTry,
    required this.correct,
    this.pickedIndex,
    required this.reward,
    required this.answeredAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['question_id'] = Variable<String>(questionId);
    map['week_start'] = Variable<DateTime>(weekStart);
    map['first_try'] = Variable<bool>(firstTry);
    map['correct'] = Variable<bool>(correct);
    if (!nullToAbsent || pickedIndex != null) {
      map['picked_index'] = Variable<int>(pickedIndex);
    }
    map['reward'] = Variable<int>(reward);
    map['answered_at'] = Variable<DateTime>(answeredAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  QuizAttemptsCompanion toCompanion(bool nullToAbsent) {
    return QuizAttemptsCompanion(
      id: Value(id),
      childId: Value(childId),
      questionId: Value(questionId),
      weekStart: Value(weekStart),
      firstTry: Value(firstTry),
      correct: Value(correct),
      pickedIndex: pickedIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(pickedIndex),
      reward: Value(reward),
      answeredAt: Value(answeredAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory QuizAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizAttempt(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      weekStart: serializer.fromJson<DateTime>(json['weekStart']),
      firstTry: serializer.fromJson<bool>(json['firstTry']),
      correct: serializer.fromJson<bool>(json['correct']),
      pickedIndex: serializer.fromJson<int?>(json['pickedIndex']),
      reward: serializer.fromJson<int>(json['reward']),
      answeredAt: serializer.fromJson<DateTime>(json['answeredAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'questionId': serializer.toJson<String>(questionId),
      'weekStart': serializer.toJson<DateTime>(weekStart),
      'firstTry': serializer.toJson<bool>(firstTry),
      'correct': serializer.toJson<bool>(correct),
      'pickedIndex': serializer.toJson<int?>(pickedIndex),
      'reward': serializer.toJson<int>(reward),
      'answeredAt': serializer.toJson<DateTime>(answeredAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  QuizAttempt copyWith({
    String? id,
    String? childId,
    String? questionId,
    DateTime? weekStart,
    bool? firstTry,
    bool? correct,
    Value<int?> pickedIndex = const Value.absent(),
    int? reward,
    DateTime? answeredAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => QuizAttempt(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    questionId: questionId ?? this.questionId,
    weekStart: weekStart ?? this.weekStart,
    firstTry: firstTry ?? this.firstTry,
    correct: correct ?? this.correct,
    pickedIndex: pickedIndex.present ? pickedIndex.value : this.pickedIndex,
    reward: reward ?? this.reward,
    answeredAt: answeredAt ?? this.answeredAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  QuizAttempt copyWithCompanion(QuizAttemptsCompanion data) {
    return QuizAttempt(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      firstTry: data.firstTry.present ? data.firstTry.value : this.firstTry,
      correct: data.correct.present ? data.correct.value : this.correct,
      pickedIndex: data.pickedIndex.present
          ? data.pickedIndex.value
          : this.pickedIndex,
      reward: data.reward.present ? data.reward.value : this.reward,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizAttempt(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('questionId: $questionId, ')
          ..write('weekStart: $weekStart, ')
          ..write('firstTry: $firstTry, ')
          ..write('correct: $correct, ')
          ..write('pickedIndex: $pickedIndex, ')
          ..write('reward: $reward, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    childId,
    questionId,
    weekStart,
    firstTry,
    correct,
    pickedIndex,
    reward,
    answeredAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizAttempt &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.questionId == this.questionId &&
          other.weekStart == this.weekStart &&
          other.firstTry == this.firstTry &&
          other.correct == this.correct &&
          other.pickedIndex == this.pickedIndex &&
          other.reward == this.reward &&
          other.answeredAt == this.answeredAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class QuizAttemptsCompanion extends UpdateCompanion<QuizAttempt> {
  final Value<String> id;
  final Value<String> childId;
  final Value<String> questionId;
  final Value<DateTime> weekStart;
  final Value<bool> firstTry;
  final Value<bool> correct;
  final Value<int?> pickedIndex;
  final Value<int> reward;
  final Value<DateTime> answeredAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const QuizAttemptsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.firstTry = const Value.absent(),
    this.correct = const Value.absent(),
    this.pickedIndex = const Value.absent(),
    this.reward = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuizAttemptsCompanion.insert({
    required String id,
    required String childId,
    required String questionId,
    required DateTime weekStart,
    this.firstTry = const Value.absent(),
    this.correct = const Value.absent(),
    this.pickedIndex = const Value.absent(),
    this.reward = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       childId = Value(childId),
       questionId = Value(questionId),
       weekStart = Value(weekStart);
  static Insertable<QuizAttempt> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<String>? questionId,
    Expression<DateTime>? weekStart,
    Expression<bool>? firstTry,
    Expression<bool>? correct,
    Expression<int>? pickedIndex,
    Expression<int>? reward,
    Expression<DateTime>? answeredAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (questionId != null) 'question_id': questionId,
      if (weekStart != null) 'week_start': weekStart,
      if (firstTry != null) 'first_try': firstTry,
      if (correct != null) 'correct': correct,
      if (pickedIndex != null) 'picked_index': pickedIndex,
      if (reward != null) 'reward': reward,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuizAttemptsCompanion copyWith({
    Value<String>? id,
    Value<String>? childId,
    Value<String>? questionId,
    Value<DateTime>? weekStart,
    Value<bool>? firstTry,
    Value<bool>? correct,
    Value<int?>? pickedIndex,
    Value<int>? reward,
    Value<DateTime>? answeredAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return QuizAttemptsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      questionId: questionId ?? this.questionId,
      weekStart: weekStart ?? this.weekStart,
      firstTry: firstTry ?? this.firstTry,
      correct: correct ?? this.correct,
      pickedIndex: pickedIndex ?? this.pickedIndex,
      reward: reward ?? this.reward,
      answeredAt: answeredAt ?? this.answeredAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<DateTime>(weekStart.value);
    }
    if (firstTry.present) {
      map['first_try'] = Variable<bool>(firstTry.value);
    }
    if (correct.present) {
      map['correct'] = Variable<bool>(correct.value);
    }
    if (pickedIndex.present) {
      map['picked_index'] = Variable<int>(pickedIndex.value);
    }
    if (reward.present) {
      map['reward'] = Variable<int>(reward.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('questionId: $questionId, ')
          ..write('weekStart: $weekStart, ')
          ..write('firstTry: $firstTry, ')
          ..write('correct: $correct, ')
          ..write('pickedIndex: $pickedIndex, ')
          ..write('reward: $reward, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChildrenTable children = $ChildrenTable(this);
  late final $AllowanceSchedulesTable allowanceSchedules =
      $AllowanceSchedulesTable(this);
  late final $TransactionEntriesTable transactionEntries =
      $TransactionEntriesTable(this);
  late final $StockTransfersTable stockTransfers = $StockTransfersTable(this);
  late final $ChangeLogsTable changeLogs = $ChangeLogsTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $AllowanceRatesTable allowanceRates = $AllowanceRatesTable(this);
  late final $RequestsTable requests = $RequestsTable(this);
  late final $TiersTable tiers = $TiersTable(this);
  late final $PromisesTable promises = $PromisesTable(this);
  late final $PromiseCommentsTable promiseComments = $PromiseCommentsTable(
    this,
  );
  late final $QuizAttemptsTable quizAttempts = $QuizAttemptsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    children,
    allowanceSchedules,
    transactionEntries,
    stockTransfers,
    changeLogs,
    goals,
    allowanceRates,
    requests,
    tiers,
    promises,
    promiseComments,
    quizAttempts,
  ];
}

typedef $$ChildrenTableCreateCompanionBuilder =
    ChildrenCompanion Function({
      required String id,
      required String name,
      Value<String?> stockAccountLabel,
      Value<String?> avatarPath,
      Value<int> weeklyAllowanceDefault,
      Value<int> payDayOfWeek,
      Value<int> autoTransferThreshold,
      Value<bool> bonusEnabled,
      Value<int> bonusDayOfWeek,
      Value<int> bonusThreshold,
      Value<int> bonusAmount,
      Value<bool> interestEnabled,
      Value<double> interestPercent,
      Value<int> interestPeriod,
      Value<bool> interestUseBankRate,
      Value<double> interestMultiplier,
      Value<int> quizReward,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$ChildrenTableUpdateCompanionBuilder =
    ChildrenCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> stockAccountLabel,
      Value<String?> avatarPath,
      Value<int> weeklyAllowanceDefault,
      Value<int> payDayOfWeek,
      Value<int> autoTransferThreshold,
      Value<bool> bonusEnabled,
      Value<int> bonusDayOfWeek,
      Value<int> bonusThreshold,
      Value<int> bonusAmount,
      Value<bool> interestEnabled,
      Value<double> interestPercent,
      Value<int> interestPeriod,
      Value<bool> interestUseBankRate,
      Value<double> interestMultiplier,
      Value<int> quizReward,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$ChildrenTableFilterComposer
    extends Composer<_$AppDatabase, $ChildrenTable> {
  $$ChildrenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stockAccountLabel => $composableBuilder(
    column: $table.stockAccountLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weeklyAllowanceDefault => $composableBuilder(
    column: $table.weeklyAllowanceDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get payDayOfWeek => $composableBuilder(
    column: $table.payDayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get autoTransferThreshold => $composableBuilder(
    column: $table.autoTransferThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get bonusEnabled => $composableBuilder(
    column: $table.bonusEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bonusDayOfWeek => $composableBuilder(
    column: $table.bonusDayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bonusThreshold => $composableBuilder(
    column: $table.bonusThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bonusAmount => $composableBuilder(
    column: $table.bonusAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get interestEnabled => $composableBuilder(
    column: $table.interestEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get interestPercent => $composableBuilder(
    column: $table.interestPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interestPeriod => $composableBuilder(
    column: $table.interestPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get interestUseBankRate => $composableBuilder(
    column: $table.interestUseBankRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get interestMultiplier => $composableBuilder(
    column: $table.interestMultiplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quizReward => $composableBuilder(
    column: $table.quizReward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChildrenTableOrderingComposer
    extends Composer<_$AppDatabase, $ChildrenTable> {
  $$ChildrenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stockAccountLabel => $composableBuilder(
    column: $table.stockAccountLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weeklyAllowanceDefault => $composableBuilder(
    column: $table.weeklyAllowanceDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get payDayOfWeek => $composableBuilder(
    column: $table.payDayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get autoTransferThreshold => $composableBuilder(
    column: $table.autoTransferThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get bonusEnabled => $composableBuilder(
    column: $table.bonusEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bonusDayOfWeek => $composableBuilder(
    column: $table.bonusDayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bonusThreshold => $composableBuilder(
    column: $table.bonusThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bonusAmount => $composableBuilder(
    column: $table.bonusAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get interestEnabled => $composableBuilder(
    column: $table.interestEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get interestPercent => $composableBuilder(
    column: $table.interestPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interestPeriod => $composableBuilder(
    column: $table.interestPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get interestUseBankRate => $composableBuilder(
    column: $table.interestUseBankRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get interestMultiplier => $composableBuilder(
    column: $table.interestMultiplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quizReward => $composableBuilder(
    column: $table.quizReward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChildrenTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChildrenTable> {
  $$ChildrenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get stockAccountLabel => $composableBuilder(
    column: $table.stockAccountLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarPath => $composableBuilder(
    column: $table.avatarPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weeklyAllowanceDefault => $composableBuilder(
    column: $table.weeklyAllowanceDefault,
    builder: (column) => column,
  );

  GeneratedColumn<int> get payDayOfWeek => $composableBuilder(
    column: $table.payDayOfWeek,
    builder: (column) => column,
  );

  GeneratedColumn<int> get autoTransferThreshold => $composableBuilder(
    column: $table.autoTransferThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get bonusEnabled => $composableBuilder(
    column: $table.bonusEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bonusDayOfWeek => $composableBuilder(
    column: $table.bonusDayOfWeek,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bonusThreshold => $composableBuilder(
    column: $table.bonusThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bonusAmount => $composableBuilder(
    column: $table.bonusAmount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get interestEnabled => $composableBuilder(
    column: $table.interestEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<double> get interestPercent => $composableBuilder(
    column: $table.interestPercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get interestPeriod => $composableBuilder(
    column: $table.interestPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get interestUseBankRate => $composableBuilder(
    column: $table.interestUseBankRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get interestMultiplier => $composableBuilder(
    column: $table.interestMultiplier,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quizReward => $composableBuilder(
    column: $table.quizReward,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$ChildrenTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChildrenTable,
          Child,
          $$ChildrenTableFilterComposer,
          $$ChildrenTableOrderingComposer,
          $$ChildrenTableAnnotationComposer,
          $$ChildrenTableCreateCompanionBuilder,
          $$ChildrenTableUpdateCompanionBuilder,
          (Child, BaseReferences<_$AppDatabase, $ChildrenTable, Child>),
          Child,
          PrefetchHooks Function()
        > {
  $$ChildrenTableTableManager(_$AppDatabase db, $ChildrenTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChildrenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChildrenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChildrenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> stockAccountLabel = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<int> weeklyAllowanceDefault = const Value.absent(),
                Value<int> payDayOfWeek = const Value.absent(),
                Value<int> autoTransferThreshold = const Value.absent(),
                Value<bool> bonusEnabled = const Value.absent(),
                Value<int> bonusDayOfWeek = const Value.absent(),
                Value<int> bonusThreshold = const Value.absent(),
                Value<int> bonusAmount = const Value.absent(),
                Value<bool> interestEnabled = const Value.absent(),
                Value<double> interestPercent = const Value.absent(),
                Value<int> interestPeriod = const Value.absent(),
                Value<bool> interestUseBankRate = const Value.absent(),
                Value<double> interestMultiplier = const Value.absent(),
                Value<int> quizReward = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChildrenCompanion(
                id: id,
                name: name,
                stockAccountLabel: stockAccountLabel,
                avatarPath: avatarPath,
                weeklyAllowanceDefault: weeklyAllowanceDefault,
                payDayOfWeek: payDayOfWeek,
                autoTransferThreshold: autoTransferThreshold,
                bonusEnabled: bonusEnabled,
                bonusDayOfWeek: bonusDayOfWeek,
                bonusThreshold: bonusThreshold,
                bonusAmount: bonusAmount,
                interestEnabled: interestEnabled,
                interestPercent: interestPercent,
                interestPeriod: interestPeriod,
                interestUseBankRate: interestUseBankRate,
                interestMultiplier: interestMultiplier,
                quizReward: quizReward,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> stockAccountLabel = const Value.absent(),
                Value<String?> avatarPath = const Value.absent(),
                Value<int> weeklyAllowanceDefault = const Value.absent(),
                Value<int> payDayOfWeek = const Value.absent(),
                Value<int> autoTransferThreshold = const Value.absent(),
                Value<bool> bonusEnabled = const Value.absent(),
                Value<int> bonusDayOfWeek = const Value.absent(),
                Value<int> bonusThreshold = const Value.absent(),
                Value<int> bonusAmount = const Value.absent(),
                Value<bool> interestEnabled = const Value.absent(),
                Value<double> interestPercent = const Value.absent(),
                Value<int> interestPeriod = const Value.absent(),
                Value<bool> interestUseBankRate = const Value.absent(),
                Value<double> interestMultiplier = const Value.absent(),
                Value<int> quizReward = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChildrenCompanion.insert(
                id: id,
                name: name,
                stockAccountLabel: stockAccountLabel,
                avatarPath: avatarPath,
                weeklyAllowanceDefault: weeklyAllowanceDefault,
                payDayOfWeek: payDayOfWeek,
                autoTransferThreshold: autoTransferThreshold,
                bonusEnabled: bonusEnabled,
                bonusDayOfWeek: bonusDayOfWeek,
                bonusThreshold: bonusThreshold,
                bonusAmount: bonusAmount,
                interestEnabled: interestEnabled,
                interestPercent: interestPercent,
                interestPeriod: interestPeriod,
                interestUseBankRate: interestUseBankRate,
                interestMultiplier: interestMultiplier,
                quizReward: quizReward,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChildrenTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChildrenTable,
      Child,
      $$ChildrenTableFilterComposer,
      $$ChildrenTableOrderingComposer,
      $$ChildrenTableAnnotationComposer,
      $$ChildrenTableCreateCompanionBuilder,
      $$ChildrenTableUpdateCompanionBuilder,
      (Child, BaseReferences<_$AppDatabase, $ChildrenTable, Child>),
      Child,
      PrefetchHooks Function()
    >;
typedef $$AllowanceSchedulesTableCreateCompanionBuilder =
    AllowanceSchedulesCompanion Function({
      required String id,
      required String childId,
      required DateTime scheduledDate,
      required int amount,
      Value<bool> isPaid,
      Value<DateTime?> paidDate,
      Value<String> editedBy,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$AllowanceSchedulesTableUpdateCompanionBuilder =
    AllowanceSchedulesCompanion Function({
      Value<String> id,
      Value<String> childId,
      Value<DateTime> scheduledDate,
      Value<int> amount,
      Value<bool> isPaid,
      Value<DateTime?> paidDate,
      Value<String> editedBy,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$AllowanceSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $AllowanceSchedulesTable> {
  $$AllowanceSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPaid => $composableBuilder(
    column: $table.isPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidDate => $composableBuilder(
    column: $table.paidDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get editedBy => $composableBuilder(
    column: $table.editedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AllowanceSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $AllowanceSchedulesTable> {
  $$AllowanceSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPaid => $composableBuilder(
    column: $table.isPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidDate => $composableBuilder(
    column: $table.paidDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get editedBy => $composableBuilder(
    column: $table.editedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AllowanceSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AllowanceSchedulesTable> {
  $$AllowanceSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<bool> get isPaid =>
      $composableBuilder(column: $table.isPaid, builder: (column) => column);

  GeneratedColumn<DateTime> get paidDate =>
      $composableBuilder(column: $table.paidDate, builder: (column) => column);

  GeneratedColumn<String> get editedBy =>
      $composableBuilder(column: $table.editedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$AllowanceSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AllowanceSchedulesTable,
          AllowanceSchedule,
          $$AllowanceSchedulesTableFilterComposer,
          $$AllowanceSchedulesTableOrderingComposer,
          $$AllowanceSchedulesTableAnnotationComposer,
          $$AllowanceSchedulesTableCreateCompanionBuilder,
          $$AllowanceSchedulesTableUpdateCompanionBuilder,
          (
            AllowanceSchedule,
            BaseReferences<
              _$AppDatabase,
              $AllowanceSchedulesTable,
              AllowanceSchedule
            >,
          ),
          AllowanceSchedule,
          PrefetchHooks Function()
        > {
  $$AllowanceSchedulesTableTableManager(
    _$AppDatabase db,
    $AllowanceSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AllowanceSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AllowanceSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AllowanceSchedulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> childId = const Value.absent(),
                Value<DateTime> scheduledDate = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<bool> isPaid = const Value.absent(),
                Value<DateTime?> paidDate = const Value.absent(),
                Value<String> editedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AllowanceSchedulesCompanion(
                id: id,
                childId: childId,
                scheduledDate: scheduledDate,
                amount: amount,
                isPaid: isPaid,
                paidDate: paidDate,
                editedBy: editedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String childId,
                required DateTime scheduledDate,
                required int amount,
                Value<bool> isPaid = const Value.absent(),
                Value<DateTime?> paidDate = const Value.absent(),
                Value<String> editedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AllowanceSchedulesCompanion.insert(
                id: id,
                childId: childId,
                scheduledDate: scheduledDate,
                amount: amount,
                isPaid: isPaid,
                paidDate: paidDate,
                editedBy: editedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AllowanceSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AllowanceSchedulesTable,
      AllowanceSchedule,
      $$AllowanceSchedulesTableFilterComposer,
      $$AllowanceSchedulesTableOrderingComposer,
      $$AllowanceSchedulesTableAnnotationComposer,
      $$AllowanceSchedulesTableCreateCompanionBuilder,
      $$AllowanceSchedulesTableUpdateCompanionBuilder,
      (
        AllowanceSchedule,
        BaseReferences<
          _$AppDatabase,
          $AllowanceSchedulesTable,
          AllowanceSchedule
        >,
      ),
      AllowanceSchedule,
      PrefetchHooks Function()
    >;
typedef $$TransactionEntriesTableCreateCompanionBuilder =
    TransactionEntriesCompanion Function({
      required String id,
      required String childId,
      required DateTime date,
      required String flow,
      required String category,
      required int amount,
      Value<String?> memo,
      Value<String?> linkedScheduleId,
      Value<String?> giver,
      Value<String> editedBy,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TransactionEntriesTableUpdateCompanionBuilder =
    TransactionEntriesCompanion Function({
      Value<String> id,
      Value<String> childId,
      Value<DateTime> date,
      Value<String> flow,
      Value<String> category,
      Value<int> amount,
      Value<String?> memo,
      Value<String?> linkedScheduleId,
      Value<String?> giver,
      Value<String> editedBy,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$TransactionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionEntriesTable> {
  $$TransactionEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flow => $composableBuilder(
    column: $table.flow,
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

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedScheduleId => $composableBuilder(
    column: $table.linkedScheduleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get giver => $composableBuilder(
    column: $table.giver,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get editedBy => $composableBuilder(
    column: $table.editedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionEntriesTable> {
  $$TransactionEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flow => $composableBuilder(
    column: $table.flow,
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

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedScheduleId => $composableBuilder(
    column: $table.linkedScheduleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get giver => $composableBuilder(
    column: $table.giver,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get editedBy => $composableBuilder(
    column: $table.editedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionEntriesTable> {
  $$TransactionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get flow =>
      $composableBuilder(column: $table.flow, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get linkedScheduleId => $composableBuilder(
    column: $table.linkedScheduleId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get giver =>
      $composableBuilder(column: $table.giver, builder: (column) => column);

  GeneratedColumn<String> get editedBy =>
      $composableBuilder(column: $table.editedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TransactionEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionEntriesTable,
          TransactionEntry,
          $$TransactionEntriesTableFilterComposer,
          $$TransactionEntriesTableOrderingComposer,
          $$TransactionEntriesTableAnnotationComposer,
          $$TransactionEntriesTableCreateCompanionBuilder,
          $$TransactionEntriesTableUpdateCompanionBuilder,
          (
            TransactionEntry,
            BaseReferences<
              _$AppDatabase,
              $TransactionEntriesTable,
              TransactionEntry
            >,
          ),
          TransactionEntry,
          PrefetchHooks Function()
        > {
  $$TransactionEntriesTableTableManager(
    _$AppDatabase db,
    $TransactionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> childId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> flow = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String?> linkedScheduleId = const Value.absent(),
                Value<String?> giver = const Value.absent(),
                Value<String> editedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionEntriesCompanion(
                id: id,
                childId: childId,
                date: date,
                flow: flow,
                category: category,
                amount: amount,
                memo: memo,
                linkedScheduleId: linkedScheduleId,
                giver: giver,
                editedBy: editedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String childId,
                required DateTime date,
                required String flow,
                required String category,
                required int amount,
                Value<String?> memo = const Value.absent(),
                Value<String?> linkedScheduleId = const Value.absent(),
                Value<String?> giver = const Value.absent(),
                Value<String> editedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionEntriesCompanion.insert(
                id: id,
                childId: childId,
                date: date,
                flow: flow,
                category: category,
                amount: amount,
                memo: memo,
                linkedScheduleId: linkedScheduleId,
                giver: giver,
                editedBy: editedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionEntriesTable,
      TransactionEntry,
      $$TransactionEntriesTableFilterComposer,
      $$TransactionEntriesTableOrderingComposer,
      $$TransactionEntriesTableAnnotationComposer,
      $$TransactionEntriesTableCreateCompanionBuilder,
      $$TransactionEntriesTableUpdateCompanionBuilder,
      (
        TransactionEntry,
        BaseReferences<
          _$AppDatabase,
          $TransactionEntriesTable,
          TransactionEntry
        >,
      ),
      TransactionEntry,
      PrefetchHooks Function()
    >;
typedef $$StockTransfersTableCreateCompanionBuilder =
    StockTransfersCompanion Function({
      required String id,
      required String childId,
      required DateTime date,
      required int amount,
      Value<String?> memo,
      Value<String?> ticker,
      Value<String?> companyName,
      Value<double?> shares,
      Value<String> editedBy,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$StockTransfersTableUpdateCompanionBuilder =
    StockTransfersCompanion Function({
      Value<String> id,
      Value<String> childId,
      Value<DateTime> date,
      Value<int> amount,
      Value<String?> memo,
      Value<String?> ticker,
      Value<String?> companyName,
      Value<double?> shares,
      Value<String> editedBy,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$StockTransfersTableFilterComposer
    extends Composer<_$AppDatabase, $StockTransfersTable> {
  $$StockTransfersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ticker => $composableBuilder(
    column: $table.ticker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get shares => $composableBuilder(
    column: $table.shares,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get editedBy => $composableBuilder(
    column: $table.editedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StockTransfersTableOrderingComposer
    extends Composer<_$AppDatabase, $StockTransfersTable> {
  $$StockTransfersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ticker => $composableBuilder(
    column: $table.ticker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get shares => $composableBuilder(
    column: $table.shares,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get editedBy => $composableBuilder(
    column: $table.editedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StockTransfersTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockTransfersTable> {
  $$StockTransfersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get ticker =>
      $composableBuilder(column: $table.ticker, builder: (column) => column);

  GeneratedColumn<String> get companyName => $composableBuilder(
    column: $table.companyName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get shares =>
      $composableBuilder(column: $table.shares, builder: (column) => column);

  GeneratedColumn<String> get editedBy =>
      $composableBuilder(column: $table.editedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$StockTransfersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockTransfersTable,
          StockTransfer,
          $$StockTransfersTableFilterComposer,
          $$StockTransfersTableOrderingComposer,
          $$StockTransfersTableAnnotationComposer,
          $$StockTransfersTableCreateCompanionBuilder,
          $$StockTransfersTableUpdateCompanionBuilder,
          (
            StockTransfer,
            BaseReferences<_$AppDatabase, $StockTransfersTable, StockTransfer>,
          ),
          StockTransfer,
          PrefetchHooks Function()
        > {
  $$StockTransfersTableTableManager(
    _$AppDatabase db,
    $StockTransfersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockTransfersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockTransfersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockTransfersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> childId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String?> ticker = const Value.absent(),
                Value<String?> companyName = const Value.absent(),
                Value<double?> shares = const Value.absent(),
                Value<String> editedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockTransfersCompanion(
                id: id,
                childId: childId,
                date: date,
                amount: amount,
                memo: memo,
                ticker: ticker,
                companyName: companyName,
                shares: shares,
                editedBy: editedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String childId,
                required DateTime date,
                required int amount,
                Value<String?> memo = const Value.absent(),
                Value<String?> ticker = const Value.absent(),
                Value<String?> companyName = const Value.absent(),
                Value<double?> shares = const Value.absent(),
                Value<String> editedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockTransfersCompanion.insert(
                id: id,
                childId: childId,
                date: date,
                amount: amount,
                memo: memo,
                ticker: ticker,
                companyName: companyName,
                shares: shares,
                editedBy: editedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StockTransfersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockTransfersTable,
      StockTransfer,
      $$StockTransfersTableFilterComposer,
      $$StockTransfersTableOrderingComposer,
      $$StockTransfersTableAnnotationComposer,
      $$StockTransfersTableCreateCompanionBuilder,
      $$StockTransfersTableUpdateCompanionBuilder,
      (
        StockTransfer,
        BaseReferences<_$AppDatabase, $StockTransfersTable, StockTransfer>,
      ),
      StockTransfer,
      PrefetchHooks Function()
    >;
typedef $$ChangeLogsTableCreateCompanionBuilder =
    ChangeLogsCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      required String editedBy,
      Value<DateTime> changedAt,
      required String summary,
      Value<int> rowid,
    });
typedef $$ChangeLogsTableUpdateCompanionBuilder =
    ChangeLogsCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> editedBy,
      Value<DateTime> changedAt,
      Value<String> summary,
      Value<int> rowid,
    });

class $$ChangeLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ChangeLogsTable> {
  $$ChangeLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get editedBy => $composableBuilder(
    column: $table.editedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChangeLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChangeLogsTable> {
  $$ChangeLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get editedBy => $composableBuilder(
    column: $table.editedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChangeLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChangeLogsTable> {
  $$ChangeLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get editedBy =>
      $composableBuilder(column: $table.editedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);
}

class $$ChangeLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChangeLogsTable,
          ChangeLog,
          $$ChangeLogsTableFilterComposer,
          $$ChangeLogsTableOrderingComposer,
          $$ChangeLogsTableAnnotationComposer,
          $$ChangeLogsTableCreateCompanionBuilder,
          $$ChangeLogsTableUpdateCompanionBuilder,
          (
            ChangeLog,
            BaseReferences<_$AppDatabase, $ChangeLogsTable, ChangeLog>,
          ),
          ChangeLog,
          PrefetchHooks Function()
        > {
  $$ChangeLogsTableTableManager(_$AppDatabase db, $ChangeLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChangeLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChangeLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChangeLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> editedBy = const Value.absent(),
                Value<DateTime> changedAt = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChangeLogsCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                editedBy: editedBy,
                changedAt: changedAt,
                summary: summary,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required String editedBy,
                Value<DateTime> changedAt = const Value.absent(),
                required String summary,
                Value<int> rowid = const Value.absent(),
              }) => ChangeLogsCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                editedBy: editedBy,
                changedAt: changedAt,
                summary: summary,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChangeLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChangeLogsTable,
      ChangeLog,
      $$ChangeLogsTableFilterComposer,
      $$ChangeLogsTableOrderingComposer,
      $$ChangeLogsTableAnnotationComposer,
      $$ChangeLogsTableCreateCompanionBuilder,
      $$ChangeLogsTableUpdateCompanionBuilder,
      (ChangeLog, BaseReferences<_$AppDatabase, $ChangeLogsTable, ChangeLog>),
      ChangeLog,
      PrefetchHooks Function()
    >;
typedef $$GoalsTableCreateCompanionBuilder =
    GoalsCompanion Function({
      required String id,
      required String childId,
      required String title,
      required int targetAmount,
      Value<DateTime> createdAt,
      Value<DateTime?> achievedAt,
      Value<String> editedBy,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$GoalsTableUpdateCompanionBuilder =
    GoalsCompanion Function({
      Value<String> id,
      Value<String> childId,
      Value<String> title,
      Value<int> targetAmount,
      Value<DateTime> createdAt,
      Value<DateTime?> achievedAt,
      Value<String> editedBy,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get editedBy => $composableBuilder(
    column: $table.editedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get editedBy => $composableBuilder(
    column: $table.editedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get editedBy =>
      $composableBuilder(column: $table.editedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          Goal,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
          Goal,
          PrefetchHooks Function()
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> childId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> targetAmount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> achievedAt = const Value.absent(),
                Value<String> editedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                childId: childId,
                title: title,
                targetAmount: targetAmount,
                createdAt: createdAt,
                achievedAt: achievedAt,
                editedBy: editedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String childId,
                required String title,
                required int targetAmount,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> achievedAt = const Value.absent(),
                Value<String> editedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                childId: childId,
                title: title,
                targetAmount: targetAmount,
                createdAt: createdAt,
                achievedAt: achievedAt,
                editedBy: editedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      Goal,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
      Goal,
      PrefetchHooks Function()
    >;
typedef $$AllowanceRatesTableCreateCompanionBuilder =
    AllowanceRatesCompanion Function({
      required String id,
      required String childId,
      required int amount,
      Value<String?> note,
      Value<DateTime> changedAt,
      Value<String> editedBy,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$AllowanceRatesTableUpdateCompanionBuilder =
    AllowanceRatesCompanion Function({
      Value<String> id,
      Value<String> childId,
      Value<int> amount,
      Value<String?> note,
      Value<DateTime> changedAt,
      Value<String> editedBy,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$AllowanceRatesTableFilterComposer
    extends Composer<_$AppDatabase, $AllowanceRatesTable> {
  $$AllowanceRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get editedBy => $composableBuilder(
    column: $table.editedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AllowanceRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $AllowanceRatesTable> {
  $$AllowanceRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get editedBy => $composableBuilder(
    column: $table.editedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AllowanceRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AllowanceRatesTable> {
  $$AllowanceRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);

  GeneratedColumn<String> get editedBy =>
      $composableBuilder(column: $table.editedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$AllowanceRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AllowanceRatesTable,
          AllowanceRate,
          $$AllowanceRatesTableFilterComposer,
          $$AllowanceRatesTableOrderingComposer,
          $$AllowanceRatesTableAnnotationComposer,
          $$AllowanceRatesTableCreateCompanionBuilder,
          $$AllowanceRatesTableUpdateCompanionBuilder,
          (
            AllowanceRate,
            BaseReferences<_$AppDatabase, $AllowanceRatesTable, AllowanceRate>,
          ),
          AllowanceRate,
          PrefetchHooks Function()
        > {
  $$AllowanceRatesTableTableManager(
    _$AppDatabase db,
    $AllowanceRatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AllowanceRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AllowanceRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AllowanceRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> childId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> changedAt = const Value.absent(),
                Value<String> editedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AllowanceRatesCompanion(
                id: id,
                childId: childId,
                amount: amount,
                note: note,
                changedAt: changedAt,
                editedBy: editedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String childId,
                required int amount,
                Value<String?> note = const Value.absent(),
                Value<DateTime> changedAt = const Value.absent(),
                Value<String> editedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AllowanceRatesCompanion.insert(
                id: id,
                childId: childId,
                amount: amount,
                note: note,
                changedAt: changedAt,
                editedBy: editedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AllowanceRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AllowanceRatesTable,
      AllowanceRate,
      $$AllowanceRatesTableFilterComposer,
      $$AllowanceRatesTableOrderingComposer,
      $$AllowanceRatesTableAnnotationComposer,
      $$AllowanceRatesTableCreateCompanionBuilder,
      $$AllowanceRatesTableUpdateCompanionBuilder,
      (
        AllowanceRate,
        BaseReferences<_$AppDatabase, $AllowanceRatesTable, AllowanceRate>,
      ),
      AllowanceRate,
      PrefetchHooks Function()
    >;
typedef $$RequestsTableCreateCompanionBuilder =
    RequestsCompanion Function({
      required String id,
      required String childId,
      required String type,
      Value<String?> title,
      Value<int> amount,
      Value<String?> memo,
      Value<String> status,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<String?> resolvedBy,
      Value<DateTime?> resolvedAt,
      Value<String> editedBy,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$RequestsTableUpdateCompanionBuilder =
    RequestsCompanion Function({
      Value<String> id,
      Value<String> childId,
      Value<String> type,
      Value<String?> title,
      Value<int> amount,
      Value<String?> memo,
      Value<String> status,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<String?> resolvedBy,
      Value<DateTime?> resolvedAt,
      Value<String> editedBy,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$RequestsTableFilterComposer
    extends Composer<_$AppDatabase, $RequestsTable> {
  $$RequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolvedBy => $composableBuilder(
    column: $table.resolvedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get editedBy => $composableBuilder(
    column: $table.editedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $RequestsTable> {
  $$RequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolvedBy => $composableBuilder(
    column: $table.resolvedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get editedBy => $composableBuilder(
    column: $table.editedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RequestsTable> {
  $$RequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get resolvedBy => $composableBuilder(
    column: $table.resolvedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get editedBy =>
      $composableBuilder(column: $table.editedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$RequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RequestsTable,
          Request,
          $$RequestsTableFilterComposer,
          $$RequestsTableOrderingComposer,
          $$RequestsTableAnnotationComposer,
          $$RequestsTableCreateCompanionBuilder,
          $$RequestsTableUpdateCompanionBuilder,
          (Request, BaseReferences<_$AppDatabase, $RequestsTable, Request>),
          Request,
          PrefetchHooks Function()
        > {
  $$RequestsTableTableManager(_$AppDatabase db, $RequestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> childId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> resolvedBy = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<String> editedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RequestsCompanion(
                id: id,
                childId: childId,
                type: type,
                title: title,
                amount: amount,
                memo: memo,
                status: status,
                createdBy: createdBy,
                createdAt: createdAt,
                resolvedBy: resolvedBy,
                resolvedAt: resolvedAt,
                editedBy: editedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String childId,
                required String type,
                Value<String?> title = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> resolvedBy = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<String> editedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RequestsCompanion.insert(
                id: id,
                childId: childId,
                type: type,
                title: title,
                amount: amount,
                memo: memo,
                status: status,
                createdBy: createdBy,
                createdAt: createdAt,
                resolvedBy: resolvedBy,
                resolvedAt: resolvedAt,
                editedBy: editedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RequestsTable,
      Request,
      $$RequestsTableFilterComposer,
      $$RequestsTableOrderingComposer,
      $$RequestsTableAnnotationComposer,
      $$RequestsTableCreateCompanionBuilder,
      $$RequestsTableUpdateCompanionBuilder,
      (Request, BaseReferences<_$AppDatabase, $RequestsTable, Request>),
      Request,
      PrefetchHooks Function()
    >;
typedef $$TiersTableCreateCompanionBuilder =
    TiersCompanion Function({
      required String id,
      required String kind,
      required int sortOrder,
      required int threshold,
      required String title,
      required String icon,
      Value<String?> reward,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TiersTableUpdateCompanionBuilder =
    TiersCompanion Function({
      Value<String> id,
      Value<String> kind,
      Value<int> sortOrder,
      Value<int> threshold,
      Value<String> title,
      Value<String> icon,
      Value<String?> reward,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$TiersTableFilterComposer extends Composer<_$AppDatabase, $TiersTable> {
  $$TiersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get threshold => $composableBuilder(
    column: $table.threshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reward => $composableBuilder(
    column: $table.reward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TiersTableOrderingComposer
    extends Composer<_$AppDatabase, $TiersTable> {
  $$TiersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get threshold => $composableBuilder(
    column: $table.threshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reward => $composableBuilder(
    column: $table.reward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TiersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TiersTable> {
  $$TiersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get threshold =>
      $composableBuilder(column: $table.threshold, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get reward =>
      $composableBuilder(column: $table.reward, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TiersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TiersTable,
          Tier,
          $$TiersTableFilterComposer,
          $$TiersTableOrderingComposer,
          $$TiersTableAnnotationComposer,
          $$TiersTableCreateCompanionBuilder,
          $$TiersTableUpdateCompanionBuilder,
          (Tier, BaseReferences<_$AppDatabase, $TiersTable, Tier>),
          Tier,
          PrefetchHooks Function()
        > {
  $$TiersTableTableManager(_$AppDatabase db, $TiersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TiersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TiersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TiersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> threshold = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String?> reward = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TiersCompanion(
                id: id,
                kind: kind,
                sortOrder: sortOrder,
                threshold: threshold,
                title: title,
                icon: icon,
                reward: reward,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kind,
                required int sortOrder,
                required int threshold,
                required String title,
                required String icon,
                Value<String?> reward = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TiersCompanion.insert(
                id: id,
                kind: kind,
                sortOrder: sortOrder,
                threshold: threshold,
                title: title,
                icon: icon,
                reward: reward,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TiersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TiersTable,
      Tier,
      $$TiersTableFilterComposer,
      $$TiersTableOrderingComposer,
      $$TiersTableAnnotationComposer,
      $$TiersTableCreateCompanionBuilder,
      $$TiersTableUpdateCompanionBuilder,
      (Tier, BaseReferences<_$AppDatabase, $TiersTable, Tier>),
      Tier,
      PrefetchHooks Function()
    >;
typedef $$PromisesTableCreateCompanionBuilder =
    PromisesCompanion Function({
      required String id,
      required String childId,
      required String title,
      Value<double> bonusPercent,
      Value<bool> enabled,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$PromisesTableUpdateCompanionBuilder =
    PromisesCompanion Function({
      Value<String> id,
      Value<String> childId,
      Value<String> title,
      Value<double> bonusPercent,
      Value<bool> enabled,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$PromisesTableFilterComposer
    extends Composer<_$AppDatabase, $PromisesTable> {
  $$PromisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bonusPercent => $composableBuilder(
    column: $table.bonusPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PromisesTableOrderingComposer
    extends Composer<_$AppDatabase, $PromisesTable> {
  $$PromisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bonusPercent => $composableBuilder(
    column: $table.bonusPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PromisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromisesTable> {
  $$PromisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get bonusPercent => $composableBuilder(
    column: $table.bonusPercent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PromisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PromisesTable,
          Promise,
          $$PromisesTableFilterComposer,
          $$PromisesTableOrderingComposer,
          $$PromisesTableAnnotationComposer,
          $$PromisesTableCreateCompanionBuilder,
          $$PromisesTableUpdateCompanionBuilder,
          (Promise, BaseReferences<_$AppDatabase, $PromisesTable, Promise>),
          Promise,
          PrefetchHooks Function()
        > {
  $$PromisesTableTableManager(_$AppDatabase db, $PromisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PromisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> childId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<double> bonusPercent = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PromisesCompanion(
                id: id,
                childId: childId,
                title: title,
                bonusPercent: bonusPercent,
                enabled: enabled,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String childId,
                required String title,
                Value<double> bonusPercent = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PromisesCompanion.insert(
                id: id,
                childId: childId,
                title: title,
                bonusPercent: bonusPercent,
                enabled: enabled,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PromisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PromisesTable,
      Promise,
      $$PromisesTableFilterComposer,
      $$PromisesTableOrderingComposer,
      $$PromisesTableAnnotationComposer,
      $$PromisesTableCreateCompanionBuilder,
      $$PromisesTableUpdateCompanionBuilder,
      (Promise, BaseReferences<_$AppDatabase, $PromisesTable, Promise>),
      Promise,
      PrefetchHooks Function()
    >;
typedef $$PromiseCommentsTableCreateCompanionBuilder =
    PromiseCommentsCompanion Function({
      required String id,
      required String promiseId,
      required String childId,
      Value<String> author,
      Value<String> kind,
      Value<String?> message,
      Value<bool?> statusEnabled,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$PromiseCommentsTableUpdateCompanionBuilder =
    PromiseCommentsCompanion Function({
      Value<String> id,
      Value<String> promiseId,
      Value<String> childId,
      Value<String> author,
      Value<String> kind,
      Value<String?> message,
      Value<bool?> statusEnabled,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$PromiseCommentsTableFilterComposer
    extends Composer<_$AppDatabase, $PromiseCommentsTable> {
  $$PromiseCommentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promiseId => $composableBuilder(
    column: $table.promiseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get statusEnabled => $composableBuilder(
    column: $table.statusEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PromiseCommentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PromiseCommentsTable> {
  $$PromiseCommentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promiseId => $composableBuilder(
    column: $table.promiseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get statusEnabled => $composableBuilder(
    column: $table.statusEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PromiseCommentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PromiseCommentsTable> {
  $$PromiseCommentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get promiseId =>
      $composableBuilder(column: $table.promiseId, builder: (column) => column);

  GeneratedColumn<String> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<bool> get statusEnabled => $composableBuilder(
    column: $table.statusEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PromiseCommentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PromiseCommentsTable,
          PromiseComment,
          $$PromiseCommentsTableFilterComposer,
          $$PromiseCommentsTableOrderingComposer,
          $$PromiseCommentsTableAnnotationComposer,
          $$PromiseCommentsTableCreateCompanionBuilder,
          $$PromiseCommentsTableUpdateCompanionBuilder,
          (
            PromiseComment,
            BaseReferences<
              _$AppDatabase,
              $PromiseCommentsTable,
              PromiseComment
            >,
          ),
          PromiseComment,
          PrefetchHooks Function()
        > {
  $$PromiseCommentsTableTableManager(
    _$AppDatabase db,
    $PromiseCommentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PromiseCommentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PromiseCommentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PromiseCommentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> promiseId = const Value.absent(),
                Value<String> childId = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<bool?> statusEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PromiseCommentsCompanion(
                id: id,
                promiseId: promiseId,
                childId: childId,
                author: author,
                kind: kind,
                message: message,
                statusEnabled: statusEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String promiseId,
                required String childId,
                Value<String> author = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<bool?> statusEnabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PromiseCommentsCompanion.insert(
                id: id,
                promiseId: promiseId,
                childId: childId,
                author: author,
                kind: kind,
                message: message,
                statusEnabled: statusEnabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PromiseCommentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PromiseCommentsTable,
      PromiseComment,
      $$PromiseCommentsTableFilterComposer,
      $$PromiseCommentsTableOrderingComposer,
      $$PromiseCommentsTableAnnotationComposer,
      $$PromiseCommentsTableCreateCompanionBuilder,
      $$PromiseCommentsTableUpdateCompanionBuilder,
      (
        PromiseComment,
        BaseReferences<_$AppDatabase, $PromiseCommentsTable, PromiseComment>,
      ),
      PromiseComment,
      PrefetchHooks Function()
    >;
typedef $$QuizAttemptsTableCreateCompanionBuilder =
    QuizAttemptsCompanion Function({
      required String id,
      required String childId,
      required String questionId,
      required DateTime weekStart,
      Value<bool> firstTry,
      Value<bool> correct,
      Value<int?> pickedIndex,
      Value<int> reward,
      Value<DateTime> answeredAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$QuizAttemptsTableUpdateCompanionBuilder =
    QuizAttemptsCompanion Function({
      Value<String> id,
      Value<String> childId,
      Value<String> questionId,
      Value<DateTime> weekStart,
      Value<bool> firstTry,
      Value<bool> correct,
      Value<int?> pickedIndex,
      Value<int> reward,
      Value<DateTime> answeredAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$QuizAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $QuizAttemptsTable> {
  $$QuizAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get firstTry => $composableBuilder(
    column: $table.firstTry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pickedIndex => $composableBuilder(
    column: $table.pickedIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reward => $composableBuilder(
    column: $table.reward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuizAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuizAttemptsTable> {
  $$QuizAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get firstTry => $composableBuilder(
    column: $table.firstTry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pickedIndex => $composableBuilder(
    column: $table.pickedIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reward => $composableBuilder(
    column: $table.reward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuizAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuizAttemptsTable> {
  $$QuizAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<bool> get firstTry =>
      $composableBuilder(column: $table.firstTry, builder: (column) => column);

  GeneratedColumn<bool> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<int> get pickedIndex => $composableBuilder(
    column: $table.pickedIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reward =>
      $composableBuilder(column: $table.reward, builder: (column) => column);

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$QuizAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuizAttemptsTable,
          QuizAttempt,
          $$QuizAttemptsTableFilterComposer,
          $$QuizAttemptsTableOrderingComposer,
          $$QuizAttemptsTableAnnotationComposer,
          $$QuizAttemptsTableCreateCompanionBuilder,
          $$QuizAttemptsTableUpdateCompanionBuilder,
          (
            QuizAttempt,
            BaseReferences<_$AppDatabase, $QuizAttemptsTable, QuizAttempt>,
          ),
          QuizAttempt,
          PrefetchHooks Function()
        > {
  $$QuizAttemptsTableTableManager(_$AppDatabase db, $QuizAttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuizAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuizAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuizAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> childId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<DateTime> weekStart = const Value.absent(),
                Value<bool> firstTry = const Value.absent(),
                Value<bool> correct = const Value.absent(),
                Value<int?> pickedIndex = const Value.absent(),
                Value<int> reward = const Value.absent(),
                Value<DateTime> answeredAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuizAttemptsCompanion(
                id: id,
                childId: childId,
                questionId: questionId,
                weekStart: weekStart,
                firstTry: firstTry,
                correct: correct,
                pickedIndex: pickedIndex,
                reward: reward,
                answeredAt: answeredAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String childId,
                required String questionId,
                required DateTime weekStart,
                Value<bool> firstTry = const Value.absent(),
                Value<bool> correct = const Value.absent(),
                Value<int?> pickedIndex = const Value.absent(),
                Value<int> reward = const Value.absent(),
                Value<DateTime> answeredAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuizAttemptsCompanion.insert(
                id: id,
                childId: childId,
                questionId: questionId,
                weekStart: weekStart,
                firstTry: firstTry,
                correct: correct,
                pickedIndex: pickedIndex,
                reward: reward,
                answeredAt: answeredAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuizAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuizAttemptsTable,
      QuizAttempt,
      $$QuizAttemptsTableFilterComposer,
      $$QuizAttemptsTableOrderingComposer,
      $$QuizAttemptsTableAnnotationComposer,
      $$QuizAttemptsTableCreateCompanionBuilder,
      $$QuizAttemptsTableUpdateCompanionBuilder,
      (
        QuizAttempt,
        BaseReferences<_$AppDatabase, $QuizAttemptsTable, QuizAttempt>,
      ),
      QuizAttempt,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChildrenTableTableManager get children =>
      $$ChildrenTableTableManager(_db, _db.children);
  $$AllowanceSchedulesTableTableManager get allowanceSchedules =>
      $$AllowanceSchedulesTableTableManager(_db, _db.allowanceSchedules);
  $$TransactionEntriesTableTableManager get transactionEntries =>
      $$TransactionEntriesTableTableManager(_db, _db.transactionEntries);
  $$StockTransfersTableTableManager get stockTransfers =>
      $$StockTransfersTableTableManager(_db, _db.stockTransfers);
  $$ChangeLogsTableTableManager get changeLogs =>
      $$ChangeLogsTableTableManager(_db, _db.changeLogs);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$AllowanceRatesTableTableManager get allowanceRates =>
      $$AllowanceRatesTableTableManager(_db, _db.allowanceRates);
  $$RequestsTableTableManager get requests =>
      $$RequestsTableTableManager(_db, _db.requests);
  $$TiersTableTableManager get tiers =>
      $$TiersTableTableManager(_db, _db.tiers);
  $$PromisesTableTableManager get promises =>
      $$PromisesTableTableManager(_db, _db.promises);
  $$PromiseCommentsTableTableManager get promiseComments =>
      $$PromiseCommentsTableTableManager(_db, _db.promiseComments);
  $$QuizAttemptsTableTableManager get quizAttempts =>
      $$QuizAttemptsTableTableManager(_db, _db.quizAttempts);
}
