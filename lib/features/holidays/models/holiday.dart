import 'package:hive/hive.dart';

// ─────────────────────────────────────────────────────────────
// GAZETTE TYPE
// HOW the government officially classifies the holiday
// ─────────────────────────────────────────────────────────────

/// The 7 official gazette types published by Bangladesh government
enum GazetteType {
  /// সাধারণ ছুটি — Mandatory for all govt offices
  mandatoryGeneral,

  /// নির্বাহী আদেশে ছুটি — Declared by executive order, mandatory for govt
  mandatoryExecutive,

  /// ঐচ্ছিক ছুটি (মুসলিম পর্ব) — Optional, Muslim community
  optionalMuslim,

  /// ঐচ্ছিক ছুটি (হিন্দু পর্ব) — Optional, Hindu community
  optionalHindu,

  /// ঐচ্ছিক ছুটি (খ্রিষ্টান পর্ব) — Optional, Christian community
  optionalChristian,

  /// ঐচ্ছিক ছুটি (বৌদ্ধ পর্ব) — Optional, Buddhist community
  optionalBuddhist,

  /// ঐচ্ছিক ছুটি (ক্ষুদ্র নৃ-গোষ্ঠী) — Optional, Ethnic minority community
  optionalEthnicMinority;

  /// Whether this is a mandatory govt holiday (shown on calendar)
  bool get isMandatory =>
      this == GazetteType.mandatoryGeneral ||
      this == GazetteType.mandatoryExecutive;

  /// Whether this is an optional holiday (shown in list only)
  bool get isOptional => !isMandatory;

  /// Display name in English
  String get displayName {
    switch (this) {
      case GazetteType.mandatoryGeneral:
        return 'General Holiday';
      case GazetteType.mandatoryExecutive:
        return 'Executive Order';
      case GazetteType.optionalMuslim:
        return 'Optional (Muslim)';
      case GazetteType.optionalHindu:
        return 'Optional (Hindu)';
      case GazetteType.optionalChristian:
        return 'Optional (Christian)';
      case GazetteType.optionalBuddhist:
        return 'Optional (Buddhist)';
      case GazetteType.optionalEthnicMinority:
        return 'Optional (Ethnic Minority)';
    }
  }

  /// Display name in Bengali
  String get displayNameBn {
    switch (this) {
      case GazetteType.mandatoryGeneral:
        return 'সাধারণ ছুটি';
      case GazetteType.mandatoryExecutive:
        return 'নির্বাহী আদেশে ছুটি';
      case GazetteType.optionalMuslim:
        return 'ঐচ্ছিক ছুটি (মুসলিম পর্ব)';
      case GazetteType.optionalHindu:
        return 'ঐচ্ছিক ছুটি (হিন্দু পর্ব)';
      case GazetteType.optionalChristian:
        return 'ঐচ্ছিক ছুটি (খ্রিষ্টান পর্ব)';
      case GazetteType.optionalBuddhist:
        return 'ঐচ্ছিক ছুটি (বৌদ্ধ পর্ব)';
      case GazetteType.optionalEthnicMinority:
        return 'ঐচ্ছিক ছুটি (ক্ষুদ্র নৃ-গোষ্ঠী)';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// HOLIDAY CATEGORY
// WHAT the holiday is about (independent of gazette classification)
// ─────────────────────────────────────────────────────────────

enum HolidayCategory {
  /// National day (Independence Day, Victory Day, etc.)
  national,

  /// Islamic religious holiday
  islamic,

  /// Hindu religious holiday
  hindu,

  /// Christian religious holiday
  christian,

  /// Buddhist religious holiday
  buddhist,

  /// Ethnic minority / indigenous festival
  ethnicMinority,

  /// Secular cultural holiday (Pohela Boishakh, May Day, etc.)
  cultural;

  String get displayName {
    switch (this) {
      case HolidayCategory.national:
        return 'National';
      case HolidayCategory.islamic:
        return 'Islamic';
      case HolidayCategory.hindu:
        return 'Hindu';
      case HolidayCategory.christian:
        return 'Christian';
      case HolidayCategory.buddhist:
        return 'Buddhist';
      case HolidayCategory.ethnicMinority:
        return 'Ethnic Minority';
      case HolidayCategory.cultural:
        return 'Cultural';
    }
  }

  String get displayNameBn {
    switch (this) {
      case HolidayCategory.national:
        return 'জাতীয়';
      case HolidayCategory.islamic:
        return 'ইসলামী';
      case HolidayCategory.hindu:
        return 'হিন্দু';
      case HolidayCategory.christian:
        return 'খ্রিষ্টান';
      case HolidayCategory.buddhist:
        return 'বৌদ্ধ';
      case HolidayCategory.ethnicMinority:
        return 'ক্ষুদ্র নৃ-গোষ্ঠী';
      case HolidayCategory.cultural:
        return 'সাংস্কৃতিক';
    }
  }
}

// ─────────────────────────────────────────────────────────────
// HOLIDAY MODEL
// ─────────────────────────────────────────────────────────────

class Holiday {
  final String id;
  final String name;
  final String namebn;
  final DateTime startDate;
  final DateTime? endDate; // null = single day holiday
  final GazetteType gazetteType;
  final HolidayCategory category;
  final String? description;
  final String? descriptionbn;

  /// True if the date depends on moon sighting and may shift ±1 day
  final bool isApproximate;

  /// True if the holiday is only applicable to a specific region
  /// e.g. Chaitra Sankranti for Hill Districts only
  final bool isRegional;

  /// Optional note about the holiday (e.g. "Hill Districts only")
  final String? regionNote;
  final String? regionNoteBn;

  Holiday({
    String? id,
    required this.name,
    required this.namebn,
    required this.startDate,
    this.endDate,
    required this.gazetteType,
    required this.category,
    this.description,
    this.descriptionbn,
    this.isApproximate = false,
    this.isRegional = false,
    this.regionNote,
    this.regionNoteBn,
  }) : id = id ??
            '${startDate.year}_${name.replaceAll(' ', '_').toLowerCase()}';

  // ─────────────────────────────────────────────────────────────
  // Convenience getters
  // ─────────────────────────────────────────────────────────────

  /// Mandatory govt holiday → show on calendar
  bool get isMandatory => gazetteType.isMandatory;

  /// Optional holiday → show in list only
  bool get isOptional => gazetteType.isOptional;

  /// Whether this holiday spans multiple days
  bool get isMultiDay => endDate != null;

  /// Total number of days for multi-day holidays
  int get durationDays {
    if (endDate == null) return 1;
    return endDate!.difference(startDate).inDays + 1;
  }

  /// Check if a given date falls within this holiday's range
  bool containsDate(DateTime target) {
    final t = _dateOnly(target);
    final s = _dateOnly(startDate);
    if (endDate == null) return t == s;
    final e = _dateOnly(endDate!);
    return !t.isBefore(s) && !t.isAfter(e);
  }

  bool get isToday => containsDate(DateTime.now());

  /// Days until this holiday starts (negative = already passed)
  int get daysUntil {
    final now = _dateOnly(DateTime.now());
    return _dateOnly(startDate).difference(now).inDays;
  }

  bool get isUpcoming {
    final d = daysUntil;
    return d >= 0 && d <= 30;
  }

  bool get hasPassed => daysUntil < 0;

  String getDaysUntilText() {
    if (daysUntil == 0) return 'Today';
    if (daysUntil == 1) return 'Tomorrow';
    if (daysUntil > 0) return 'In $daysUntil days';
    return 'Passed';
  }

  // ─────────────────────────────────────────────────────────────
  // Serialization
  // ─────────────────────────────────────────────────────────────

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'] as String?,
      name: json['name'] as String,
      namebn: json['namebn'] as String,
      startDate: _parseDate(json['startDate']),
      endDate: json['endDate'] != null ? _parseDate(json['endDate']) : null,
      gazetteType: GazetteType.values.firstWhere(
        (e) => e.name == json['gazetteType'],
        orElse: () => GazetteType.mandatoryGeneral,
      ),
      category: HolidayCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => HolidayCategory.national,
      ),
      description: json['description'] as String?,
      descriptionbn: json['descriptionbn'] as String?,
      isApproximate: _parseBool(json['isApproximate'], defaultValue: false),
      isRegional: _parseBool(json['isRegional'], defaultValue: false),
      regionNote: json['regionNote'] as String?,
      regionNoteBn: json['regionNoteBn'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'namebn': namebn,
      'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      'gazetteType': gazetteType.name,
      'category': category.name,
      if (description != null) 'description': description,
      if (descriptionbn != null) 'descriptionbn': descriptionbn,
      if (isApproximate) 'isApproximate': isApproximate,
      if (isRegional) 'isRegional': isRegional,
      if (regionNote != null) 'regionNote': regionNote,
      if (regionNoteBn != null) 'regionNoteBn': regionNoteBn,
    };
  }

  // ─────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static DateTime _parseDate(dynamic value) {
    if (value is String) return DateTime.parse(value);
    throw Exception('Unsupported date format: $value');
  }

  static bool _parseBool(dynamic value, {bool defaultValue = true}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    if (value is int) return value == 1;
    return defaultValue;
  }

  // ─────────────────────────────────────────────────────────────
  // Object overrides
  // ─────────────────────────────────────────────────────────────

  Holiday copyWith({
    String? id,
    String? name,
    String? namebn,
    DateTime? startDate,
    DateTime? endDate,
    GazetteType? gazetteType,
    HolidayCategory? category,
    String? description,
    String? descriptionbn,
    bool? isApproximate,
    bool? isRegional,
    String? regionNote,
    String? regionNoteBn,
  }) {
    return Holiday(
      id: id ?? this.id,
      name: name ?? this.name,
      namebn: namebn ?? this.namebn,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      gazetteType: gazetteType ?? this.gazetteType,
      category: category ?? this.category,
      description: description ?? this.description,
      descriptionbn: descriptionbn ?? this.descriptionbn,
      isApproximate: isApproximate ?? this.isApproximate,
      isRegional: isRegional ?? this.isRegional,
      regionNote: regionNote ?? this.regionNote,
      regionNoteBn: regionNoteBn ?? this.regionNoteBn,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Holiday && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Holiday(id: $id, name: $name, startDate: $startDate, endDate: $endDate, '
      'gazetteType: ${gazetteType.name}, category: ${category.name})';
}

// ─────────────────────────────────────────────────────────────
// HIVE ADAPTERS
// typeId 0 = Holiday, typeId 1 = GazetteType, typeId 2 = HolidayCategory
// NOTE: If you previously used typeId 1 for the old HolidayType enum,
// clear the Hive box on first upgrade to avoid conflicts.
// ─────────────────────────────────────────────────────────────

class GazetteTypeAdapter extends TypeAdapter<GazetteType> {
  @override
  final int typeId = 1;

  @override
  GazetteType read(BinaryReader reader) {
    final index = reader.readByte();
    return GazetteType.values[index];
  }

  @override
  void write(BinaryWriter writer, GazetteType obj) {
    writer.writeByte(obj.index);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GazetteTypeAdapter && typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class HolidayCategoryAdapter extends TypeAdapter<HolidayCategory> {
  @override
  final int typeId = 2;

  @override
  HolidayCategory read(BinaryReader reader) {
    final index = reader.readByte();
    return HolidayCategory.values[index];
  }

  @override
  void write(BinaryWriter writer, HolidayCategory obj) {
    writer.writeByte(obj.index);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HolidayCategoryAdapter && typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}

class HolidayAdapter extends TypeAdapter<Holiday> {
  @override
  final int typeId = 0;

  @override
  Holiday read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Holiday(
      id: fields[0] as String?,
      name: fields[1] as String,
      namebn: fields[2] as String,
      startDate: fields[3] as DateTime,
      endDate: fields[4] as DateTime?,
      gazetteType: fields[5] as GazetteType,
      category: fields[6] as HolidayCategory,
      description: fields[7] as String?,
      descriptionbn: fields[8] as String?,
      isApproximate: fields[9] as bool? ?? false,
      isRegional: fields[10] as bool? ?? false,
      regionNote: fields[11] as String?,
      regionNoteBn: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Holiday obj) {
    writer.writeByte(13); // total fields
    writer
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.namebn)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.gazetteType)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.descriptionbn)
      ..writeByte(9)
      ..write(obj.isApproximate)
      ..writeByte(10)
      ..write(obj.isRegional)
      ..writeByte(11)
      ..write(obj.regionNote)
      ..writeByte(12)
      ..write(obj.regionNoteBn);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HolidayAdapter && typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
