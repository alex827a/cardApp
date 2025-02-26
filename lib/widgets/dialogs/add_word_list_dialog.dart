import 'package:flutter/material.dart';
import '../../category.dart';

Future<Map<String, String>?> showAddWordListDialog({
  required BuildContext context,
  required List<Category> categories,
  required String currentCategory,
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
              children: categories.map((category) {
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

  TextEditingController listController = TextEditingController();
  String? wordList;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Добавить список слов'),
        content: SingleChildScrollView(
          child: TextField(
            controller: listController,
            decoration: InputDecoration(
              hintText: 'Например: Hallo:Привет;Danke:Спасибо;',
            ),
            maxLines: 10,
          ),
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
              String inputText = listController.text.trim();
              if (inputText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Список слов не может быть пустым')),
                );
                return;
              }
              
              wordList = inputText;
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );

  if (wordList == null) return null;
  
  return {
    'category': selectedCategory,
    'words': wordList!
  };
}