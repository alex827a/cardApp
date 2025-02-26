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

class HomeScreenWidgets {
  final BuildContext context;
  final List<Category> categories;
  final List<WordCard> displayedCards;
  final List<WordCard> allCards;
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
  });

  Widget buildLanguageMenu() {
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
      );
    },
  );
}
 Widget buildUploadButton() {
    return IconButton(
      icon: Icon(Icons.upload_file),
      tooltip: 'Загрузить слова',
      onPressed: () async {
        String? categoryName = await showCategorySelectDialog(
          context: context,
          categories: categories,
          title: 'Выберите категорию',
        );

        if (categoryName != null && categoryName.trim().isNotEmpty) {
          if (!categoryService.categoryExists(categoryName)) {
            await categoryService.addCategory(Category(name: categoryName)); // Добавлен await
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
    );
  }

Widget buildFlipButton() {
  return IconButton(
    icon: Icon(Icons.swap_horiz),
    tooltip: 'Изменить порядок слов',
    onPressed: () async {
      setState(() {
        isFlippedGlobally = !isFlippedGlobally;
        for (var card in cardService.getCardsByCategory(currentCategory)) {
          card.isFlipped = isFlippedGlobally;
          card.save();
        }
      });
      loadCards();
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