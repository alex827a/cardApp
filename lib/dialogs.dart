// lib/dialogs.dart

import 'package:flutter/material.dart';
import 'category.dart';
import 'word_card.dart';
import 'package:my_web_app/genetated/app_localizations.dart';

// Диалог для добавления нового слова (используется из home_screen.dart)
void showAddSingleWordDialog(BuildContext context, List<Category> categories, String currentCategory, Function(WordCard) addWordCard) async {
  String? selectedCategory = currentCategory;

  // Если текущая категория - "Все категории" или "Избранные", попросим выбрать категорию
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
    return;
  }

  // Контроллеры для ввода слов
  TextEditingController germanController = TextEditingController();
  TextEditingController russianController = TextEditingController();

  // Показываем диалог для ввода одного слова
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

              // Добавляем новое слово
              addWordCard(WordCard(
                german: germanWord,
                russian: russianWord,
                category: selectedCategory!,
                isFavorite: false,
                isFlipped: false, // Можно задать начальное состояние переворота
              ));

              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// Диалог для добавления списка слов (используется из home_screen.dart)
void showAddWordListDialog(BuildContext context, List<Category> categories, String currentCategory, Function(String, String) addWordsFromList) async {
  String? selectedCategory = currentCategory;

  // Если текущая категория - "Все категории" или "Избранные", попросим выбрать категорию
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
    return;
  }

  // Контроллер для ввода списка слов
  TextEditingController listController = TextEditingController();

  // Показываем диалог для ввода списка слов
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

              // Передаём текст для парсинга и добавления
              addWordsFromList(selectedCategory!, inputText);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// Диалог для добавления новой категории
void showAddCategoryDialog(BuildContext context, Function(Category) addCategory) {
  TextEditingController categoryController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context).add_category),
        content: TextField(
          controller: categoryController,
          decoration: InputDecoration(labelText: AppLocalizations.of(context).category),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(AppLocalizations.of(context).cancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(AppLocalizations.of(context).save),
            onPressed: () {
              if (categoryController.text.isNotEmpty) {
                addCategory(Category(name: categoryController.text));
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}

// Диалог для удаления категории
void showDeleteCategoryDialog(BuildContext context, String categoryName, Function(String) deleteCategory) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context).delete_category),
        content: Text(AppLocalizations.of(context).delete_category_confirm.replaceFirst('{category}', categoryName)),
        actions: <Widget>[
          TextButton(
            child: Text(AppLocalizations.of(context).cancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(AppLocalizations.of(context).delete),
            onPressed: () {
              deleteCategory(categoryName);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
