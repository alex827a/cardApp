import 'package:flutter/material.dart';
import '../../category.dart';
import '../../word_card.dart';
import '../../quiz_screen.dart';
import '../../write_answer_quiz_screen.dart';

Future<void> showTestCategoryDialog({
  required BuildContext context,
  required List<Category> categories,
  required List<WordCard> allCards,
  required List<WordCard> displayedCards,
  required bool isFlippedGlobally,
}) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Выберите категорию для теста'),
      content: Container(
        width: double.maxFinite,
        height: 300,
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: Icon(Icons.visibility),
              title: Text('Текущий выбор (${displayedCards.length} карточек)'),
              onTap: () {
                Navigator.pop(context);
                if (displayedCards.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Нет карточек в текущем выборе')),
                  );
                  return;
                }
                _showTestTypeDialog(context, displayedCards, isFlippedGlobally);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.all_inclusive),
              title: Text('Все карточки (${allCards.length})'),
              onTap: () {
                Navigator.pop(context);
                _showTestTypeDialog(context, allCards, isFlippedGlobally);
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Избранные (${allCards.where((card) => card.isFavorite).length})'),
              onTap: () {
                Navigator.pop(context);
                List<WordCard> favoriteCards = allCards.where((card) => card.isFavorite).toList();
                if (favoriteCards.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Нет избранных карточек')),
                  );
                  return;
                }
                _showTestTypeDialog(context, favoriteCards, isFlippedGlobally);
              },
            ),
            Divider(),
            ...categories
                .where((c) => c.name != 'Все категории' && c.name != 'Избранные')
                .map((category) {
              int count = allCards.where((card) => card.category == category.name).length;
              return ListTile(
                leading: Icon(Icons.category),
                title: Text('${category.name} ($count)'),
                onTap: () {
                  Navigator.pop(context);
                  List<WordCard> categoryCards = allCards
                      .where((card) => card.category == category.name)
                      .toList();
                  if (categoryCards.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Нет карточек в категории ${category.name}')),
                    );
                    return;
                  }
                  _showTestTypeDialog(context, categoryCards, isFlippedGlobally);
                },
              );
            }).toList(),
          ],
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
    ),
  );
}

void _showTestTypeDialog(BuildContext context, List<WordCard> cardsForTest, bool isFlippedGlobally) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Выберите тип теста'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.quiz),
            title: Text('Тест с вариантами ответов'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(
                    cards: cardsForTest,
                    isFlippedGlobally: isFlippedGlobally,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.spellcheck),
            title: Text('Тест с вводом ответа'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WriteAnswerQuizScreen(
                    cards: cardsForTest,
                    isFlippedGlobally: isFlippedGlobally,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}