import 'package:flutter/material.dart';
import '../../word_card.dart';
import '../../category.dart';

Future<WordCard?> showAddWordDialog({
  required BuildContext context,
  required List<Category> categories,
  required String currentCategory,
  required bool isFlippedGlobally,
}) async {
  String? selectedCategory = currentCategory;
  
  // Если текущая категория - "Все категории" или "Избранные", выбираем категорию
  if (currentCategory == 'Все категории' || currentCategory == 'Избранные') {
    selectedCategory = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Выберите категорию'),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: categories
                  .where((c) => c.name != 'Все категории' && c.name != 'Избранные')
                  .map((category) {
                return ListTile(
                  title: Text(category.name),
                  onTap: () {
                    Navigator.of(context).pop(category.name);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  if (selectedCategory == null || selectedCategory.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Категория не выбрана')),
    );
    return null;
  }

  TextEditingController germanController = TextEditingController();
  TextEditingController russianController = TextEditingController();
  WordCard? result;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Добавить слово'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: germanController,
              decoration: InputDecoration(labelText: 'Иностранное слово'),
              autofocus: true,
            ),
            TextField(
              controller: russianController,
              decoration: InputDecoration(labelText: 'Родное слово'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Отмена'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Добавить'),
            onPressed: () {
              String germanWord = germanController.text.trim();
              String russianWord = russianController.text.trim();

              if (germanWord.isEmpty || russianWord.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Пожалуйста, заполните все поля')),
                );
                return;
              }

              result = WordCard(
                german: germanWord,
                russian: russianWord,
                category: selectedCategory!,
                isFavorite: false,
                isFlipped: isFlippedGlobally,
              );
              
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );

  return result;
}