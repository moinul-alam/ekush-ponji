// lib/data/models/quote.dart

import 'package:hive/hive.dart';

class QuoteModel extends HiveObject {
  final String text;
  final String author;
  final String category;
  final bool isSaved;

  QuoteModel({
    required this.text,
    required this.author,
    required this.category,
    this.isSaved = false,
  });

  QuoteModel copyWith({
    String? text,
    String? author,
    String? category,
    bool? isSaved,
  }) {
    return QuoteModel(
      text: text ?? this.text,
      author: author ?? this.author,
      category: category ?? this.category,
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
      isSaved: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, QuoteModel obj) {
    writer.writeString(obj.text);
    writer.writeString(obj.author);
    writer.writeString(obj.category);
    writer.writeBool(obj.isSaved);
  }
}