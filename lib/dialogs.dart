import 'package:flutter/material.dart';
import 'category.dart';
import 'word_card.dart';
import 'app_localizations.dart';

void showAddCardDialog(BuildContext context, List<Category> categories, String currentCategory, Function(WordCard) addWordCard) {
  TextEditingController germanController = TextEditingController();
  TextEditingController russianController = TextEditingController();
  String selectedCategory = currentCategory == 'Все категории' || currentCategory == 'Избранные' && categories.isNotEmpty
      ? categories.first.name
      : currentCategory;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context).add_card),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: germanController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).german_word),
            ),
            TextField(
              controller: russianController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).russian_word),
            ),
            DropdownButton<String>(
              value: selectedCategory,
              onChanged: (String? newValue) {
                selectedCategory = newValue!;
              },
              items: categories.map<DropdownMenuItem<String>>((Category category) {
                return DropdownMenuItem<String>(
                  value: category.name,
                  child: Text(category.name),
                );
              }).toList(),
            ),
          ],
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
              if (germanController.text.isNotEmpty && russianController.text.isNotEmpty) {
                addWordCard(WordCard(
                  german: germanController.text,
                  russian: russianController.text,
                  category: selectedCategory,
                  isFavorite: currentCategory == 'Избранные',
                ));
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Пожалуйста, заполните все поля'),
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

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

void showEditCardDialog(BuildContext context, int index, WordCard card, Function(int, WordCard) updateWordCard) {
  TextEditingController germanController = TextEditingController(text: card.german);
  TextEditingController russianController = TextEditingController(text: card.russian);
  TextEditingController categoryController = TextEditingController(text: card.category);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context).edit_card),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: germanController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).german_word),
            ),
            TextField(
              controller: russianController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).russian_word),
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context).category),
            ),
          ],
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
              if (germanController.text.isNotEmpty &&
                  russianController.text.isNotEmpty &&
                  categoryController.text.isNotEmpty) {
                updateWordCard(
                  index,
                  WordCard(
                    german: germanController.text,
                    russian: russianController.text,
                    category: categoryController.text,
                    isFavorite: card.isFavorite,
                  ),
                );
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Пожалуйста, заполните все поля'),
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
