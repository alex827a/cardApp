// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WordCardAdapter extends TypeAdapter<WordCard> {
  @override
  final int typeId = 0;

  @override
  WordCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WordCard(
      german: fields[0] as String,
      russian: fields[1] as String,
      category: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WordCard obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.german)
      ..writeByte(1)
      ..write(obj.russian)
      ..writeByte(2)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
