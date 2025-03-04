import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:my_web_app/genetated/app_localizations.dart';

// Models
import 'word_card.dart';
import 'category.dart';

// Widgets


// Screens

// Services
import 'services/card_service.dart';
import 'services/category_service.dart';
import 'services/import_service.dart';

import 'services/backup_service.dart';


import 'widgets/home_screen_widgets.dart';

import 'services/statistics_service.dart';

import 'models/word_statistics.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // MARK: - Properties
  late CardService cardService;
  late CategoryService categoryService;
  late ImportService importService;
  final TextEditingController searchController = TextEditingController();
  
  List<WordCard> allCards = [];
  List<WordCard> displayedCards = [];
  List<Category> categories = [];
  String currentCategory = 'Все категории';
  bool isFlippedGlobally = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeData();
  }

  void _initializeServices() {
    final wordCardBox = Hive.box<WordCard>('wordCards');
    final categoryBox = Hive.box<Category>('categories');
    
    cardService = CardService(wordCardBox);
    categoryService = CategoryService(categoryBox, wordCardBox);
    importService = ImportService();
  }

  void _initializeData() {
    loadCards();
    loadCategories();
    searchController.addListener(_filterCardsBySearch);
  }

  // MARK: - Data Management
  void loadCards() {
    setState(() {
      allCards = cardService.getAllCards();
      _filterCardsBySearch();
    });
  }

  void loadCategories() {
    setState(() {
      categories = categoryService.getAllCategories();
    });
  }

  void filterCards(String category) {
    setState(() {
      currentCategory = category;
      _filterCardsBySearch();
    });
  }

  void _filterCardsBySearch() {
    final query = searchController.text.toLowerCase();
    setState(() {
      displayedCards = cardService.searchCards(query, currentCategory);
    });
  }

  void toggleFavorite(WordCard card) {
    cardService.toggleFavorite(card);
    setState(() {
      if (currentCategory == 'Избранные' && !card.isFavorite) {
        displayedCards.remove(card);
      } else {
        _filterCardsBySearch();
      }
    });
  }

  Future<void> flipAllCards() async {
    setState(() {
      isFlippedGlobally = !isFlippedGlobally;
      for (var card in cardService.getCardsByCategory(currentCategory)) {
        card.isFlipped = isFlippedGlobally;
        card.save();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    final widgets = HomeScreenWidgets(
      context: context,
      categories: categories,
      displayedCards: displayedCards,
      allCards: allCards,
      isFlippedGlobally: isFlippedGlobally,
	    toggleFlip: toggleFlip, 
      searchController: searchController,
      cardService: cardService,
      categoryService: categoryService,
      importService: importService,
      currentCategory: currentCategory,
      filterCards: filterCards,
      loadCards: loadCards,
      loadCategories: loadCategories,
      toggleFavorite: toggleFavorite,
      setState: setState,
      statisticsService: StatisticsService(Hive.box<WordStatistics>('wordStats')),
      backupService: BackupService(),
    );

    return Scaffold(
       appBar: AppBar(
    title: Text(localizations.title),
    actions: [
      // Оставляем только основные кнопки
      widgets.buildFlipButton(),
      widgets.buildTestButton(),
      // Добавляем меню настроек
      PopupMenuButton(
        icon: Icon(Icons.settings),
        tooltip: 'Настройки',
   itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.language),
                  title: Text('Язык'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => widgets.buildLanguageMenu(),
                    );
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.file_upload),
                  title: Text('Управление словами'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Управление словами'),
                        content: widgets.buildUploadButton(),
                      ),
                    );
                  },
                ),
              ),
           PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.analytics),
              title: Text('Статистика'),
              onTap: () {
                Navigator.pop(context);
                widgets.showStatistics(context); // Call the method directly
              },
            ),
          ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.backup),
                  title: Text('Резервное копирование'),
                   onTap: () {
                    Navigator.pop(context);
                    widgets.showBackupOptions(context); // Direct method call instead of building button
                  },
                ),
              ),
        ],
      ),
    ],
  ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            widgets.buildDrawerHeader(localizations),
            ...widgets.buildCategoryItems(),
            ...widgets.buildDefaultDrawerItems(localizations),
          ],
        ),
      ),
      body: Column(
        children: [
          widgets.buildSearchField(),
          widgets.buildCardList(localizations),
        ],
      ),
      floatingActionButton: widgets.buildAddButton(),
    );
  }

  // В классе _HomeScreenState добавим метод:
void toggleFlip() {
  setState(() {
    isFlippedGlobally = !isFlippedGlobally;
    for (var card in cardService.getCardsByCategory(currentCategory)) {
      card.isFlipped = isFlippedGlobally;
      card.save();
    }
    loadCards();
  });
}
}