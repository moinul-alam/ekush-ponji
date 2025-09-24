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
      nameEn: fields[0] as String,
      nameBn: fields[1] as String,
      date: fields[2] as DateTime,
      isPublicHoliday: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Holiday obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.nameEn)
      ..writeByte(1)
      ..write(obj.nameBn)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.isPublicHoliday);
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
