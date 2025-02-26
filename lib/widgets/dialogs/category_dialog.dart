import 'package:flutter/material.dart';
import '../../category.dart';

// Диалог выбора категории
Future<String?> showCategorySelectDialog({
  required BuildContext context,
  required List<Category> categories,
  required String title,
}) async {
  return await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
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

// Диалог добавления категории
Future<void> showAddCategoryDialog({
  required BuildContext context,
  required Function(String) onAdd,
}) async {
  TextEditingController controller = TextEditingController();
  
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Добавить категорию'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Название категории'),
          autofocus: true,
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
              String categoryName = controller.text.trim();
              if (categoryName.isNotEmpty) {
                onAdd(categoryName);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}

// Диалог удаления категории
Future<void> showDeleteCategoryDialog({
  required BuildContext context,
  required String categoryName,
  required Function() onDelete,
}) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Удалить категорию'),
        content: Text("Вы уверены, что хотите удалить категорию '$categoryName' и все её слова?"),
        actions: <Widget>[
          TextButton(
            child: Text('Отмена'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Удалить'),
            onPressed: () {
              onDelete();
            },
          ),
        ],
      );
    },
  );
}