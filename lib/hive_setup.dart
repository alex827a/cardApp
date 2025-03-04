// lib/hive_setup.dart

import 'package:hive/hive.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'category.dart';
import 'word_card.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/word_statistics.dart';

Future<void> setupHive() async {
  await Hive.initFlutter();
 // Регистрируем адаптеры
  Hive.registerAdapter(WordCardAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(WordStatisticsAdapter());  // Добавляем регистрацию адаптера
  
   // Открываем боксы
  await Future.wait([
    Hive.openBox<WordCard>('wordCards'),
    Hive.openBox<Category>('categories'),
    Hive.openBox<WordStatistics>('wordStats'),  // Добавляем открытие бокса
  ]);
  // Загрузка данных из JSON файла
  final categoriesBox = Hive.box<Category>('categories');
  final wordCardsBox = Hive.box<WordCard>('wordCards');

  if (categoriesBox.isEmpty) {
    final initialData = await rootBundle.loadString('assets/initial_data.json');
    final Map<String, dynamic> jsonData = json.decode(initialData);

    // Добавление категорий
    for (var category in jsonData['categories']) {
      categoriesBox.add(Category(name: category['name']));
    }

    // Добавление слов
    for (var word in jsonData['words']) {
      wordCardsBox.add(WordCard(
        german: word['german'],
        russian: word['russian'],
        category: word['category'],
      ));
    }
  }
}
