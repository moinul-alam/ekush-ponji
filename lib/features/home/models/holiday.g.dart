// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      date: fields[3] as DateTime,
      type: fields[4] as HolidayType,
      description: fields[5] as String?,
      descriptionbn: fields[6] as String?,
      isGovtHoliday: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Holiday obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.namebn)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.descriptionbn)
      ..writeByte(7)
      ..write(obj.isGovtHoliday);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HolidayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HolidayTypeAdapter extends TypeAdapter<HolidayType> {
  @override
  final int typeId = 1;

  @override
  HolidayType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HolidayType.national;
      case 1:
        return HolidayType.religious;
      case 2:
        return HolidayType.cultural;
      case 3:
        return HolidayType.optional;
      default:
        return HolidayType.national;
    }
  }

  @override
  void write(BinaryWriter writer, HolidayType obj) {
    switch (obj) {
      case HolidayType.national:
        writer.writeByte(0);
        break;
      case HolidayType.religious:
        writer.writeByte(1);
        break;
      case HolidayType.cultural:
        writer.writeByte(2);
        break;
      case HolidayType.optional:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HolidayTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
