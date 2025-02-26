import 'package:flutter/material.dart';
import '../../word_card.dart';

Future<WordCard?> showEditCardDialog(
  BuildContext context,
  WordCard card,
) async {
  TextEditingController germanController = TextEditingController(text: card.german);
  TextEditingController russianController = TextEditingController(text: card.russian);
  WordCard? result;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Редактировать карточку'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: germanController,
              decoration: InputDecoration(labelText: 'Иностранное слово'),
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
            child: Text('Сохранить'),
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
                category: card.category,
                isFavorite: card.isFavorite,
                isFlipped: card.isFlipped,
              );
              
              Navigator.of(context).pop(result);
            },
          ),
        ],
      );
    },
  );

  return result;
}