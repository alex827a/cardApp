// Файл lib/word_card.dart

import 'package:hive/hive.dart';

part 'word_card.g.dart'; // Hive будет генерировать код адаптера в этот файл

@HiveType(typeId: 0) // Уникальный ID для Hive типа
class WordCard {
  @HiveField(0)
  String german;
  @HiveField(1)
  String russian;
  @HiveField(2)
  String category;

  WordCard({required this.german, required this.russian, required this.category});


  void updateWith({String? german, String? russian, String? category}) {
    if (german != null) this.german = german;
    if (russian != null) this.russian = russian;
    if (category != null) this.category = category;
  }
}
