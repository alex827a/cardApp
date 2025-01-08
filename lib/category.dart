import 'package:hive/hive.dart';

part 'category.g.dart'; // Hive будет генерировать код адаптера в этот файл

@HiveType(typeId: 1) // Уникальный ID для Hive типа
class Category extends HiveObject {
  @HiveField(0)
  String name;

  Category({required this.name});
}
