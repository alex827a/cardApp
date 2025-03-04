import 'package:flutter/material.dart';
import 'dart:math';
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
  required String currentCategory,
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
                _showTestTypeDialog(context, displayedCards, isFlippedGlobally,'Текущий выбор');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.all_inclusive),
              title: Text('Все карточки (${allCards.length})'),
              onTap: () {
                Navigator.pop(context);
                _showTestTypeDialog(context, allCards, isFlippedGlobally,'Все категории');
              },
            ),
            // В test_dialog.dart
            ListTile(
              leading: Icon(Icons.all_inclusive),
              title: Text('Изучить все слова'),
              subtitle: Text('Последовательные тесты до полного изучения всех слов'),
              onTap: () {
                Navigator.pop(context);
                // Show category selection dialog first
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Выберите категорию для изучения'),
                    content: Container(
                      width: double.maxFinite,
                      height: 300,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          ListTile(
                            leading: Icon(Icons.all_inclusive),
                            title: Text('Все карточки (${allCards.length})'),
                            onTap: () {
                              Navigator.pop(context);
                              _startLearningAll(context, allCards, isFlippedGlobally, 'Все категории');
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
                                _startLearningAll(context, categoryCards, isFlippedGlobally, category.name);
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: Text('Отмена'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
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
                _showTestTypeDialog(context, favoriteCards, isFlippedGlobally,'Избранные');
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
                  _showTestTypeDialog(context, categoryCards, isFlippedGlobally,category.name);
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

void _startLearningAll(BuildContext context, List<WordCard> allCards, 
        bool isFlippedGlobally, String categoryName) {
      
      // Фильтруем карточки по категории, если она указана
      List<WordCard> cardsToStudy = categoryName == 'Все категории' 
          ? allCards 
          : allCards.where((card) => card.category == categoryName).toList();
      
      // Проверяем, есть ли карточки для изучения
      if (cardsToStudy.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Нет доступных карточек для изучения')),
        );
        return;
      }

      int wordsPerTest = 10;
      
      void launchTest(List<WordCard> cards) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(
              cards: cards,
              isFlippedGlobally: isFlippedGlobally,
              currentCategory: categoryName,
              wordCount: wordsPerTest,
              onComplete: (int correct, int total) {
                if (cards.length > wordsPerTest) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Сессия в процессе'),
                      content: Text('Вы изучили $wordsPerTest из ${cards.length} слов.\n'
                                  'Желаете продолжить изучение?'),
                      actions: [
                        TextButton(
                          child: Text('Завершить'),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: Text('Продолжить'),
                          onPressed: () {
                            Navigator.pop(context);
                            launchTest(cards.sublist(wordsPerTest));
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        );
      }
      
      // Запускаем первый тест с отфильтрованными карточками
      launchTest(cardsToStudy);
    }
  // Функция для последовательного изучения

void _showTestTypeDialog(
  BuildContext context, 
  List<WordCard> cardsForTest, 
  bool isFlippedGlobally,
  String categoryName
) {
  // Начальное значение - 10 слов или меньше, если карточек меньше 10
  int selectedWordCount = min(10, cardsForTest.length);
  // Максимальное значение - все карточки или 50 (что меньше)
  int maxWordCount = min(50, cardsForTest.length);

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder( // StatefulBuilder для обновления UI при изменении значения ползунка
      builder: (context, setStateDialog) => AlertDialog(
        title: Text('Выберите тип теста'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Информация о количестве слов
            Text('Количество слов для теста: $selectedWordCount', 
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            
            // Ползунок выбора количества
            Slider(
              min: 5,
              max: maxWordCount.toDouble(),
              divisions: maxWordCount > 5 ? maxWordCount - 5 : 1,
              value: selectedWordCount.toDouble(),
              onChanged: (value) {
                setStateDialog(() {
                  selectedWordCount = value.toInt();
                });
              },
              label: selectedWordCount.toString(),
            ),
            
            Divider(height: 24),
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
                      currentCategory: categoryName,
                      wordCount: selectedWordCount, // Передаем выбранное количество
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
                      currentCategory: categoryName,
                      wordCount: selectedWordCount, // Передаем выбранное количество
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );

    // Функция для последовательного изучения4
}