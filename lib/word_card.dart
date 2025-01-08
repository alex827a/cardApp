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

  WordCard({
    required this.german,
    required this.russian,
    required this.category,
    this.isFavorite = false,
    this.isFlipped = false,
  });
}
