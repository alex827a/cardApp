import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'word_card.dart';
import 'category.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flip_card/flip_card.dart';
import 'package:provider/provider.dart';
import 'locale_provider.dart';
import 'dart:convert'; // Для работы с JSON
import 'package:flutter/services.dart' show rootBundle; // Для загрузки JSON
import 'package:my_web_app/genetated/app_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(WordCardAdapter());
  Hive.registerAdapter(CategoryAdapter());
  await Hive.openBox<WordCard>('wordCards');
  await Hive.openBox<Category>('categories');

  // Загрузка данных из JSON файла
  final categoriesBox = Hive.box<Category>('categories');
  final wordCardsBox = Hive.box<WordCard>('wordCards');

  if (categoriesBox.isEmpty) {
    final initialData = await rootBundle.loadString('assets/initial_data.json');
    final Map<String, dynamic> jsonData = json.decode(initialData);

    // Добавление категорий
    for (var category in jsonData['categories']) {
      categoriesBox.add(Category(name: category['name']));
    }

    // Добавление слов
    for (var word in jsonData['words']) {
      wordCardsBox.add(WordCard(
        german: word['german'],
        russian: word['russian'],
        category: word['category'],
      ));
    }
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocaleProvider>(
      create: (_) => LocaleProvider(),
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            locale: localeProvider.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomeScreen(),
          );
        },
      ),
    );
  }
}
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

  void _showAddCardDialog(BuildContext context) {
    TextEditingController germanController = TextEditingController();
    TextEditingController russianController = TextEditingController();
    String selectedCategory = currentCategory == 'Все категории' && categories.isNotEmpty
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
              if (currentCategory == 'Все категории')
                DropdownButton<String>(
                  value: selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue!;
                    });
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

  void _showAddCategoryDialog(BuildContext context) {
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

  void _showDeleteCategoryDialog(BuildContext context, String categoryName) {
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

  void _showEditCardDialog(BuildContext context, int index, WordCard card) {
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
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _changeLanguage(Locale locale) {
    Provider.of<LocaleProvider>(context, listen: false).setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).title),
        actions: [
          PopupMenuButton<Locale>(
            onSelected: _changeLanguage,
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
                          _showDeleteCategoryDialog(context, category.name);
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
                _showAddCategoryDialog(context);
              },
            ),
          ],
        ),
      ),
      body: displayedCards.isEmpty
          ? Center(child: Text(AppLocalizations.of(context).no_cards))
          : CardSwiper(
              cards: displayedCards,
              onEditCard: (index, card) => _showEditCardDialog(context, index, card),
              onDeleteCard: (index) => deleteWordCard(index),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCardDialog(context),
        tooltip: AppLocalizations.of(context).add_card,
        child: Icon(Icons.add),
      ),
    );
  }
}

class CardSwiper extends StatelessWidget {
  final List<WordCard> cards;
  final Function(int, WordCard) onEditCard;
  final Function(int) onDeleteCard;

  CardSwiper({
    required this.cards,
    required this.onEditCard,
    required this.onDeleteCard,
  });

  @override
  Widget build(BuildContext context) {
    return Swiper(
      itemBuilder: (BuildContext context, int index) {
        return Card(
          elevation: 4,
          margin: EdgeInsets.all(8),
          child: Stack(
            children: [
              FlipCardWidget(card: cards[index]),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => onEditCard(index, cards[index]),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => onDeleteCard(index),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      itemCount: cards.length,
      viewportFraction: 0.8,
      scale: 0.9,
      loop: false,
      control: SwiperControl(),
    );
  }
}

class FlipCardWidget extends StatelessWidget {
  final WordCard card;

  FlipCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      front: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(card.german, style: TextStyle(fontSize: 20, color: Colors.white)),
      ),
      back: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(card.russian, style: TextStyle(fontSize: 20, color: Colors.white)),
      ),
    );
  }
}