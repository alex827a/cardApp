import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as flutter;
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:my_web_app/genetated/app_localizations.dart';

// Models
import 'word_card.dart';
import 'category.dart';

// Widgets
import 'card_swiper.dart';

// Providers
import 'locale_provider.dart';

// Screens
import 'quiz_screen.dart';
import 'write_answer_quiz_screen.dart';

// Services
import 'services/card_service.dart';
import 'services/category_service.dart';
import 'services/import_service.dart';

// Dialogs
import 'widgets/dialogs/add_word_dialog.dart';
import 'widgets/dialogs/add_word_list_dialog.dart';
import 'widgets/dialogs/edit_card_dialog.dart';
import 'widgets/dialogs/category_dialog.dart';
import 'widgets/dialogs/test_dialog.dart';
import 'widgets/home_screen_widgets.dart';

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
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.title),
        actions: [
          widgets.buildLanguageMenu(),
          widgets.buildUploadButton(),
          widgets.buildTestButton(),
          widgets.buildFlipButton(),
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
}