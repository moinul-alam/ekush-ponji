// lib/data/models/quote.dart

import 'package:hive/hive.dart';

class QuoteModel extends HiveObject {
  final String text;
  final String author;
  final String category;
  final int month;
  final int day;
  final bool isSaved;

  QuoteModel({
    required this.text,
    required this.author,
    required this.category,
    required this.month,
    required this.day,
    this.isSaved = false,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json,
      {bool isSaved = false}) {
    return QuoteModel(
      text: json['text'] as String,
      author: json['author'] as String,
      category: json['category'] as String,
      month: json['month'] as int,
      day: json['day'] as int,
      isSaved: isSaved,
    );
  }

  QuoteModel copyWith({
    String? text,
    String? author,
    String? category,
    int? month,
    int? day,
    bool? isSaved,
  }) {
    return QuoteModel(
      text: text ?? this.text,
      author: author ?? this.author,
      category: category ?? this.category,
      month: month ?? this.month,
      day: day ?? this.day,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  String get storageKey => text.hashCode.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuoteModel &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          author == other.author;

  @override
  int get hashCode => text.hashCode ^ author.hashCode;
}

class QuoteModelAdapter extends TypeAdapter<QuoteModel> {
  @override
  final int typeId = 10;

  @override
  QuoteModel read(BinaryReader reader) {
    return QuoteModel(
      text: reader.readString(),
      author: reader.readString(),
      category: reader.readString(),
      month: reader.readInt(),
      day: reader.readInt(),
      isSaved: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, QuoteModel obj) {
    writer.writeString(obj.text);
    writer.writeString(obj.author);
    writer.writeString(obj.category);
    writer.writeInt(obj.month);
    writer.writeInt(obj.day);
    writer.writeBool(obj.isSaved);
  }
}
