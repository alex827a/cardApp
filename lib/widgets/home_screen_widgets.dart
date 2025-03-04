import 'package:flutter/material.dart';
import '../category.dart';
import '../word_card.dart';
import '../services/card_service.dart';
import '../services/category_service.dart';
import '../widgets/dialogs/category_dialog.dart';
import '../widgets/dialogs/edit_card_dialog.dart';
import '../genetated/app_localizations.dart';
import '../card_swiper.dart';
import '../widgets/dialogs/test_dialog.dart';
import '../services/import_service.dart'; // Добавлен импорт
import '../widgets/dialogs/add_word_dialog.dart';
import '../widgets/dialogs/add_word_list_dialog.dart';
import '../services/backup_service.dart'; // Добавлен импорт
import '../services/statistics_service.dart';
import '../models/word_statistics.dart';

class HomeScreenWidgets {
  final BuildContext context;
  final List<Category> categories;
  final List<WordCard> displayedCards;
  final List<WordCard> allCards;
  final StatisticsService statisticsService;
  bool isFlippedGlobally; // Removed final keyword
  final TextEditingController searchController;
  final CardService cardService;
  final CategoryService categoryService;
  final ImportService importService; // Добавлено поле
  final String currentCategory; // Добавлено поле
  final Function(String) filterCards;
  final Function() loadCards;
  final Function() loadCategories;
  final Function(WordCard) toggleFavorite;
  final Function(Function()) setState; // Добавлено поле
  final Function() toggleFlip; // Добавляем новое поле
  final BackupService backupService; // Add this field

  HomeScreenWidgets({
    required this.context,
    required this.categories,
    required this.displayedCards,
    required this.allCards,
    required this.isFlippedGlobally,
    required this.searchController,
    required this.cardService,
    required this.categoryService,
    required this.importService, // Добавлен параметр
    required this.currentCategory, // Добавлен параметр
    required this.filterCards,
    required this.loadCards,
    required this.loadCategories,
    required this.toggleFavorite,
    required this.setState, // Добавлен параметр
    required this.toggleFlip,
	  required this.statisticsService,
    required this.backupService,
  });

  // Добавить метод для построения кнопки статистики
/*   Widget buildStatisticsButton() {
    return IconButton(
      icon: Icon(Icons.analytics),
      tooltip: 'Статистика',
      onPressed: () => showStatistics(),
    );
  } */
   void showStatistics(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Статистика изучения'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Общая статистика:', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildCategoryStatistics(),
            Divider(),
            Text('Сложные слова:', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildDifficultWords(),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Закрыть'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

  
  _buildCategoryStatistics() {
    Map<String, int> categoryStats = {};
  Map<String, int> categoryCorrect = {};
  Map<String, int> categoryTotalWords = {};
  Map<String, int> categoryTestedWords = {};

  /// Подсчитываем общее количество слов в каждой категории
  for (var category in categories) {
    var categoryCards = allCards.where((card) => card.category == category.name);
    categoryTotalWords[category.name] = categoryCards.length;
    
    // Подсчитываем только слова, которые были реально протестированы
    var testedCards = categoryCards.where((card) {
      var stats = statisticsService.getWordStatistics(card.id,category.name);
      // Проверяем, что слово действительно тестировалось и есть попытки
      return stats['totalAttempts'] != null && 
             stats['totalAttempts'] > 0 &&
             stats['correctAnswers'] != null;
    });

   // Добавляем дополнительную проверку перед подсчетом
    if (testedCards.isNotEmpty) {
      categoryTestedWords[category.name] = testedCards.length;
      
      // Подсчитываем статистику только для протестированных слов
      for (var card in testedCards) {
        var stats = statisticsService.getWordStatistics(card.id);
        int attempts = ((stats['totalAttempts'] ?? 0) as num).toInt();
        int correct = ((stats['correctAnswers'] ?? 0) as num).toInt();
        
        // Добавляем только если были реальные попытки
        if (attempts > 0) {
          categoryStats[category.name] = (categoryStats[category.name] ?? 0) + attempts;
          categoryCorrect[category.name] = (categoryCorrect[category.name] ?? 0) + correct;
        }
      }
    } else {
      // Если нет протестированных слов, устанавливаем нулевые значения
      categoryTestedWords[category.name] = 0;
      categoryStats[category.name] = 0;
      categoryCorrect[category.name] = 0;
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: categories.map((category) {
      int totalWords = categoryTotalWords[category.name] ?? 0;
      int testedWords = categoryTestedWords[category.name] ?? 0;
      int attempts = categoryStats[category.name] ?? 0;
      int correct = categoryCorrect[category.name] ?? 0;

      // Вычисляем прогресс только если есть протестированные слова
      double coverageProgress = totalWords > 0 ? testedWords / totalWords : 0;
      double accuracyProgress = attempts > 0 ? correct / attempts : 0;
      
      // Общий прогресс - это произведение охвата и точности
      double progress = coverageProgress * accuracyProgress;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${category.name} ${testedWords > 0 ? "" : "(не тестировалась)"}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              testedWords == 0 ? Colors.grey :
              progress > 0.7 ? Colors.green : 
              progress > 0.4 ? Colors.orange : Colors.red
            ),
          ),
          Text(
            testedWords > 0 
              ? '${(progress * 100).toStringAsFixed(1)}% ' +
                '(Изучено ${testedWords}/${totalWords} слов, ' +
                'успешность: ${(accuracyProgress * 100).toStringAsFixed(1)}%)'
              : 'Нет данных'
          ),
          SizedBox(height: 8),
        ],
      );
    }).toList(),
  );

}

  Widget _buildDifficultWords() {
    var difficultWords = allCards.where((card) {
      var stats = statisticsService.getWordStatistics(card.id);
      return (stats['successRate'] ?? 1.0) < 0.7 && (stats['totalAttempts'] ?? 0) > 0;
    }).toList();

    difficultWords.sort((a, b) {
      var statsA = statisticsService.getWordStatistics(a.id);
      var statsB = statisticsService.getWordStatistics(b.id);
      return (statsA['successRate'] ?? 1.0).compareTo(statsB['successRate'] ?? 1.0);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: difficultWords.take(5).map((card) {
        var stats = statisticsService.getWordStatistics(card.id);
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('${card.german} - ${card.russian}'),
          subtitle: Text(
            'Успешность: ${((stats['successRate'] ?? 0) * 100).toStringAsFixed(1)}% ' +
            '(${stats['correctAnswers']}/${stats['totalAttempts']})'
          ),
        );
      }).toList(),
    );
  }

  Widget showLanguageMenu(BuildContext context) {
    return PopupMenuButton<Locale>(
      onSelected: (locale) {
        // Implement language change logic
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
        PopupMenuItem<Locale>(
          value: Locale('en'),
          child: Text('English'),
        ),
        PopupMenuItem<Locale>(
          value: Locale('ru'),
          child: Text('Русский'),
        ),
      ],
    );
  }

  Widget buildLanguageMenu() {
  return AlertDialog(
    title: Text('Выберите язык'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text('Русский'),
          onTap: () {
            // Логика смены языка
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: Text('English'),
          onTap: () {
            // Логика смены языка
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

  Widget buildDrawerHeader(AppLocalizations localizations) {
    return DrawerHeader(
      decoration: BoxDecoration(color: Colors.blue),
      child: Text(
        localizations.categories,
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget buildCategoryTile(Category category) {
    return ListTile(
      title: Text(category.name),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => _handleDeleteCategory(category),
      ),
      onTap: () {
        Navigator.pop(context);
        filterCards(category.name);
      },
    );
  }

  Widget buildBackupButton() {
  return PopupMenuButton(
    icon: Icon(Icons.backup),
    itemBuilder: (context) => [
      PopupMenuItem(
        value: 'export',
        child: ListTile(
          leading: Icon(Icons.upload),
          title: Text('Экспортировать данные'),
        ),
      ),
      PopupMenuItem(
        value: 'import',
        child: ListTile(
          leading: Icon(Icons.download),
          title: Text('Импортировать данные'),
        ),
      ),
    ],
    onSelected: (value) async {
      final backupService = BackupService();
      
      if (value == 'export') {
        await backupService.exportData(categories, allCards);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Данные успешно экспортированы')),
        );
      } else if (value == 'import') {
        final data = await backupService.importData();
        if (data != null) {
          // Очистить текущие данные
          await categoryService.clearAll();
          await cardService.clearAll();

          // Импортировать новые данные
          final categories = data['categories'];
          if (categories != null) {
            for (var category in categories) {
              await categoryService.addCategory(category);
            }
          }
          
          final cards = data['cards'];
          if (cards != null) {
            for (var card in cards) {
              await cardService.addCard(card);
            }
          }

          // Обновить UI
          loadCategories();
          loadCards();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Данные успешно импортированы')),
          );
        }
      }
    },
  );
}

  List<Widget> buildCategoryItems() {
    return categories
        .where((c) => c.name != 'Все категории' && c.name != 'Избранные')
        .map(buildCategoryTile)
        .toList();
  }

  List<Widget> buildDefaultDrawerItems(AppLocalizations localizations) {
    return [
      ListTile(
        title: Text(localizations.all_categories),
        onTap: () {
          Navigator.pop(context);
          filterCards('Все категории');
        },
      ),
      ListTile(
        title: Text(localizations.favorites),
        onTap: () {
          Navigator.pop(context);
          filterCards('Избранные');
        },
      ),
      ListTile(
        title: Text(localizations.add_category),
        onTap: () {
          Navigator.pop(context);
          _showAddCategoryDialog();
        },
      ),
    ];
  }

  Widget buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          labelText: 'Поиск',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
  

  Widget buildCardList(AppLocalizations localizations) {
    return Expanded(
      child: displayedCards.isEmpty
          ? Center(child: Text(localizations.no_cards))
          : CardSwiperWidget(
              cards: displayedCards,
              onEditCard: _handleEditCard,
              onDeleteCard: _handleDeleteCard,
              toggleFavorite: toggleFavorite,
              isFlippedGlobally: isFlippedGlobally,
            ),
    );
  }
  Widget buildTestButton() {
  return IconButton(
    icon: Icon(Icons.quiz),
    tooltip: 'Тестирование',
    onPressed: () {
      if (allCards.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Нет карточек для тестирования')),
        );
        return;
      }
      
      showTestCategoryDialog(
        context: context,
        categories: categories,
        allCards: allCards,
        displayedCards: displayedCards,
        isFlippedGlobally: isFlippedGlobally,
        currentCategory: currentCategory, 
      );
    },
  );
}
Widget buildUploadButton() {  // Переименовываем метод для консистентности
  return PopupMenuButton(
    icon: Icon(Icons.upload_file),
    tooltip: 'Загрузить слова',
    itemBuilder: (context) => [
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.add_to_photos),
          title: Text('Добавить одно слово'),
          onTap: () async {
            Navigator.pop(context);
            WordCard? newCard = await showAddWordDialog(
              context: context,
              categories: categories,
              currentCategory: currentCategory,
              isFlippedGlobally: isFlippedGlobally,
            );
            
            if (newCard != null) {
              await cardService.addCard(newCard);
              await loadCards();
            }
          },
        ),
      ),
      PopupMenuItem(
        child: ListTile(
          leading: Icon(Icons.upload_file),
          title: Text('Загрузить список слов'),
          onTap: () async {
            Navigator.pop(context);
            String? categoryName = await showCategorySelectDialog(
              context: context,
              categories: categories,
              title: 'Выберите категорию',
            );

            if (categoryName != null && categoryName.trim().isNotEmpty) {
              if (!categoryService.categoryExists(categoryName)) {
                await categoryService.addCategory(Category(name: categoryName));
                loadCategories();
              }

              String? fileContent = await importService.pickAndReadFile();
              if (fileContent != null) {
                List<WordCard> newCards = await importService.parseWordsFromText(
                  fileContent,
                  categoryName,
                  isFlippedGlobally,
                );
                
                for (var card in newCards) {
                  await cardService.addCard(card);
                }
                
                loadCards();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Слова успешно загружены!')),
                );
              }
            }
          },
        ),
      ),
    ],
  );
}
 Widget buildFlipButton() {
    return IconButton(
      icon: Icon(Icons.swap_horiz),
      tooltip: 'Изменить порядок слов',
      onPressed: () {
        toggleFlip();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFlippedGlobally
                ? 'Порядок слов изменен: родное → иностранное'
                : 'Порядок слов изменен: иностранное → родное'),
          ),
        );
      },
    );
  }

Widget buildAddButton() {
  return FloatingActionButton(
    onPressed: () {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Добавить одно слово'),
                  onTap: () async {
                    Navigator.pop(context);
                    WordCard? newCard = await showAddWordDialog(
                      context: context,
                      categories: categories,
                      currentCategory: currentCategory,
                      isFlippedGlobally: isFlippedGlobally,
                    );
                    
                    if (newCard != null) {
                      await cardService.addCard(newCard);
                      await loadCards();
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.list),
                  title: Text('Добавить список слов'),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await showAddWordListDialog(
                      context: context,
                      categories: categories,
                      currentCategory: currentCategory,
                    );
                    
                    if (result != null) {
                      String categoryName = result['category'] as String? ?? '';
                      String wordList = result['words'] as String? ?? '';
                      
                      List<WordCard> newCards = await importService.parseWordsFromText(
                        wordList,
                        categoryName,
                        isFlippedGlobally,
                      );
                      
                      for (var card in newCards) {
                        await cardService.addCard(card);
                      }
                      
                      await loadCards();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Слова успешно добавлены!')),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      );
    },
    tooltip: 'Добавить карточку',
    child: Icon(Icons.add),
  );
}



  void _handleEditCard(int index, WordCard card) async {
    WordCard? editedCard = await showEditCardDialog(context, card);
    if (editedCard != null) {
      WordCard originalCard = displayedCards[index];
      int actualIndex = allCards.indexOf(originalCard);
      if (actualIndex != -1) {
        cardService.updateCard(actualIndex, editedCard);
        loadCards();
      }
    }
  }

  void _handleDeleteCard(int index) async {
    WordCard cardToDelete = displayedCards[index];
    await cardService.deleteCard(cardToDelete);
    loadCards();
  }


  void showBackupOptions(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Резервное копирование'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.file_download),
            title: Text('Экспортировать данные'),
            onTap: () async {
              Navigator.pop(context);
              await backupService.exportData(categories, allCards);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Данные успешно экспортированы')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.file_upload),
            title: Text('Импортировать данные'),
            onTap: () async {
              Navigator.pop(context);
              final data = await backupService.importData();
              if (data != null) {
                // Очистить текущие данные
                await categoryService.clearAll();
                await cardService.clearAll();

                // Импортировать новые данные
                final categories = data['categories'];
                final cards = data['cards'];
                
                if (categories != null) {
                  for (var category in categories) {
                    await categoryService.addCategory(category);
                  }
                }
                if (cards != null) {
                  for (var card in cards) {
                    await cardService.addCard(card);
                  }
                }
                
                loadCards();
                loadCategories();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Данные успешно импортированы')),
                );
              }
            },
          ),
        ],
      ),
    ),
  );
}

  void _handleDeleteCategory(Category category) {
     showDeleteCategoryDialog(
                      context: context,
                      categoryName: category.name,
                      onDelete: () async {
                         categoryService.deleteCategory(category.name);
                        loadCategories();
                        loadCards();
                        Navigator.pop(context); // закрыть диалог
                      },
    );
  }

  void _showAddCategoryDialog() {
    showAddCategoryDialog(
      context: context,
      onAdd: (String categoryName) async {
        if (!categoryService.categoryExists(categoryName)) {
                  categoryService.addCategory(Category(name: categoryName));
                  loadCategories();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Категория "$categoryName" добавлена')),
                  );
        }
      },
    );
  }
}