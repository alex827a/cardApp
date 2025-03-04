// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_statistics.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WordStatisticsAdapter extends TypeAdapter<WordStatistics> {
  @override
  final int typeId = 2;

  @override
  WordStatistics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WordStatistics(
      wordId: fields[0] as String,
      totalAttempts: fields[1] as int,
      correctAnswers: fields[2] as int,
      lastAttempt: fields[3] as DateTime,
      consecutiveCorrectAnswers: fields[4] as int,
      category: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WordStatistics obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.wordId)
      ..writeByte(1)
      ..write(obj.totalAttempts)
      ..writeByte(2)
      ..write(obj.correctAnswers)
      ..writeByte(3)
      ..write(obj.lastAttempt)
      ..writeByte(4)
      ..write(obj.consecutiveCorrectAnswers)
      ..writeByte(5)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordStatisticsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
