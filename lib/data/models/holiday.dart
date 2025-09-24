import 'package:hive/hive.dart';
part 'holiday.g.dart';

@HiveType(typeId: 0)
class Holiday extends HiveObject {
  @HiveField(0)
  final String nameEn;

  @HiveField(1)
  final String nameBn;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final bool isPublicHoliday;

  Holiday({
    required this.nameEn,
    required this.nameBn,
    required this.date,
    this.isPublicHoliday = true,
  });
}
