import 'package:hive/hive.dart';

part 'word_card.g.dart';

@HiveType(typeId: 0)
class WordCard extends HiveObject {
  @HiveField(0)
  final String german;

  @HiveField(1)
  final String russian;

  @HiveField(2)
  final String category;

  @HiveField(3)
  bool isFavorite;

  @HiveField(4)
  bool isFlipped; // Новое поле для переворота


  @HiveField(5)  // Добавляем новое поле
  String id;

  WordCard({
    required this.german,
    required this.russian,
    required this.category,
    this.isFavorite = false,
    this.isFlipped = false,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString(); // Генерируем уникальный ID

    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foreignWord': german,
      'nativeWord': russian,
      'isFavorite': isFavorite,
      'isFlipped': isFlipped,
      'category': category,
    };
  }

  static WordCard fromJson(Map<String, dynamic> json) {
    var card = WordCard(
      german: json['foreignWord'] as String,
      russian: json['nativeWord'] as String,
      isFavorite: json['isFavorite'] as bool,
      isFlipped: json['isFlipped'] as bool,
      category: json['category'] as String,
    );
    card.id = json['id'] as String;
    return card;
  }

  // ... существующий код ...
@override
WordCard read(BinaryReader reader) {
  final numOfFields = reader.readByte();
  final fields = <int, dynamic>{
    for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
  };
  return WordCard(
    german: fields[0] as String,
    russian: fields[1] as String,
    isFavorite: fields[2] as bool,
    isFlipped: fields[3] as bool,
    category: fields[4] as String,
  )..id = fields[5] as String;
}

@override
void write(BinaryWriter writer, WordCard obj) {
  writer
    ..writeByte(6)
    ..writeByte(0)
    ..write(obj.german)
    ..writeByte(1)
    ..write(obj.russian)
    ..writeByte(2)
    ..write(obj.isFavorite)
    ..writeByte(3)
    ..write(obj.isFlipped)
    ..writeByte(4)
    ..write(obj.category)
    ..writeByte(5)
    ..write(obj.id);
}
}
