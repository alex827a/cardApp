import 'package:hive/hive.dart';

part 'category.g.dart'; // Hive будет генерировать код адаптера в этот файл

@HiveType(typeId: 1)
class Category {
  @HiveField(0)
  String name;

  Category({required this.name});

  // Добавляем методы для сериализации
  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  // Добавляем статический метод для десериализации
  static Category fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] as String,
    );
  }
}
