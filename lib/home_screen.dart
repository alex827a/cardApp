import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'word_card.dart';
import 'category.dart';
import 'card_swiper.dart';
import 'dialogs.dart';
import 'locale_provider.dart';
import 'package:my_web_app/genetated/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<WordCard> wordCardBox;
  late Box<Category> categoryBox;
  List<WordCard> allCards = [];
  List<WordCard> displayedCards = [];
  List<Category> categories = [];
  String currentCategory = 'Все категории';

  @override
  void initState() {
    super.initState();
    loadCards();
    loadCategories();
  }

  void loadCards() async {
    wordCardBox = Hive.box<WordCard>('wordCards');
    allCards = wordCardBox.values.toList();
    setState(() {
      displayedCards = allCards;
    });
    print("Загружено карточек: ${allCards.length}");
  }

  void loadCategories() async {
    categoryBox = Hive.box<Category>('categories');
    setState(() {
      categories = categoryBox.values.toList();
    });
    print("Загружено категорий: ${categories.length}");
  }

  void filterCards(String category) {
    setState(() {
      currentCategory = category;
      if (category == 'Все категории') {
        displayedCards = allCards;
      } else {
        displayedCards = allCards.where((card) => card.category == category).toList();
      }
    });
  }

  void addWordCard(WordCard card) {
    wordCardBox.add(card);
    loadCards();
  }

  void addCategory(Category category) {
    categoryBox.add(category);
    loadCategories();
  }

  void updateWordCard(int index, WordCard newCard) {
    wordCardBox.putAt(index, newCard);
    loadCards();
  }

  void deleteWordCard(int index) {
    wordCardBox.deleteAt(index);
    loadCards();
  }

  void deleteCategory(String categoryName) {
    final categoryIndex = categories.indexWhere((c) => c.name == categoryName);
    if (categoryIndex != -1 && categoryName != 'Все категории') {
      categoryBox.deleteAt(categoryIndex);
      final cardsToDelete = wordCardBox.values.where((card) => card.category == categoryName).toList();
      for (var card in cardsToDelete) {
        final cardIndex = wordCardBox.values.toList().indexOf(card);
        wordCardBox.deleteAt(cardIndex);
      }
      loadCategories();
      loadCards();
    }
  }

  @override
  void dispose() async {
    await wordCardBox.close();
    await categoryBox.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).title),
        actions: [
          PopupMenuButton<Locale>(
            onSelected: (locale) {
              Provider.of<LocaleProvider>(context, listen: false).setLocale(locale);
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
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                AppLocalizations.of(context).categories,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ...categories.map((category) {
              return ListTile(
                title: Text(category.name),
                trailing: category.name != 'Все категории'
                    ? IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDeleteCategoryDialog(context, category.name, deleteCategory);
                        },
                      )
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  filterCards(category.name);
                },
              );
            }).toList(),
            ListTile(
              title: Text(AppLocalizations.of(context).all_categories),
              onTap: () {
                Navigator.pop(context);
                filterCards('Все категории');
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).add_category),
              onTap: () {
                Navigator.pop(context);
                showAddCategoryDialog(context, addCategory);
              },
            ),
          ],
        ),
      ),
      body: displayedCards.isEmpty
          ? Center(child: Text(AppLocalizations.of(context).no_cards))
          : CardSwiper(
              cards: displayedCards,
              onEditCard: (index, card) => showEditCardDialog(context, index, card, updateWordCard),
              onDeleteCard: (index) => deleteWordCard(index),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddCardDialog(context, categories, currentCategory, addWordCard),
        tooltip: AppLocalizations.of(context).add_card,
        child: Icon(Icons.add),
      ),
    );
  }
}
