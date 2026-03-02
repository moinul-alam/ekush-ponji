// lib/data/models/word.dart

import 'package:hive/hive.dart';

class WordModel extends HiveObject {
  final String word;
  final String partOfSpeech;
  final String meaningEn;
  final String meaningBn;
  final String synonym;
  final String example;
  final String pronunciation;
  final bool isSaved;

  WordModel({
    required this.word,
    required this.partOfSpeech,
    required this.meaningEn,
    required this.meaningBn,
    required this.synonym,
    required this.example,
    required this.pronunciation,
    this.isSaved = false,
  });

  WordModel copyWith({
    String? word,
    String? partOfSpeech,
    String? meaningEn,
    String? meaningBn,
    String? synonym,
    String? example,
    String? pronunciation,
    bool? isSaved,
  }) {
    return WordModel(
      word: word ?? this.word,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      meaningEn: meaningEn ?? this.meaningEn,
      meaningBn: meaningBn ?? this.meaningBn,
      synonym: synonym ?? this.synonym,
      example: example ?? this.example,
      pronunciation: pronunciation ?? this.pronunciation,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  String get storageKey => word.toLowerCase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordModel &&
          runtimeType == other.runtimeType &&
          word == other.word;

  @override
  int get hashCode => word.hashCode;
}

class WordModelAdapter extends TypeAdapter<WordModel> {
  @override
  final int typeId = 11;

  @override
  WordModel read(BinaryReader reader) {
    return WordModel(
      word: reader.readString(),
      partOfSpeech: reader.readString(),
      meaningEn: reader.readString(),
      meaningBn: reader.readString(),
      synonym: reader.readString(),
      example: reader.readString(),
      pronunciation: reader.readString(),
      isSaved: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, WordModel obj) {
    writer.writeString(obj.word);
    writer.writeString(obj.partOfSpeech);
    writer.writeString(obj.meaningEn);
    writer.writeString(obj.meaningBn);
    writer.writeString(obj.synonym);
    writer.writeString(obj.example);
    writer.writeString(obj.pronunciation);
    writer.writeBool(obj.isSaved);
  }
}