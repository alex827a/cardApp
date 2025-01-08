// lib/home_screen.dart

import 'package:provider/provider.dart';
import 'word_card.dart';
import 'category.dart';
import 'card_swiper.dart';
import 'dialogs.dart';
import 'locale_provider.dart';
import 'package:my_web_app/genetated/app_localizations.dart';

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

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
  TextEditingController searchController = TextEditingController();
  bool isFlippedGlobally = false; // Переменная для глобального переворота

  @override
  void initState() {
    super.initState();
    loadCards();
    loadCategories();
    searchController.addListener(_filterCardsBySearch);
  }

  // Загрузка карточек из Hive
  void loadCards() async {
    wordCardBox = Hive.box<WordCard>('wordCards');
    allCards = wordCardBox.values.toList();
    setState(() {
      _filterCardsBySearch();
    });
    print("Загружено карточек: ${allCards.length}");
  }

  // Загрузка категорий из Hive
  void loadCategories() async {
    categoryBox = Hive.box<Category>('categories');
    setState(() {
      categories = categoryBox.values.toList();
    });
    print("Загружено категорий: ${categories.length}");
  }

  // Фильтрация карточек по категории и поиску
  void filterCards(String category) {
    setState(() {
      currentCategory = category;
      _filterCardsBySearch();
    });
  }

  // Фильтрация карточек по поисковому запросу
  void _filterCardsBySearch() {
    final query = searchController.text.toLowerCase();
    setState(() {
      displayedCards = allCards.where((card) {
        final matchCategory = currentCategory == 'Все категории' ||
            (currentCategory == 'Избранные' && card.isFavorite) ||
            card.category == currentCategory;
        final matchSearch = card.german.toLowerCase().contains(query) ||
            card.russian.toLowerCase().contains(query);
        return matchCategory && matchSearch;
      }).toList();
    });
  }

  // Переключение статуса избранного
  void toggleFavorite(WordCard card) {
    card.isFavorite = !card.isFavorite;
    card.save();
    setState(() {
      if (currentCategory == 'Избранные' && !card.isFavorite) {
        displayedCards.remove(card);
      } else {
        _filterCardsBySearch();
      }
    });
  }

  // Добавление новой карточки
  void addWordCard(WordCard card) {
    wordCardBox.add(card);
    loadCards();
  }

  // Добавление новой категории
  void addCategory(Category category) {
    categoryBox.add(category);
    loadCategories();
  }

  // Обновление существующей карточки
  void updateWordCard(int index, WordCard newCard) {
    wordCardBox.putAt(index, newCard);
    loadCards();
  }

  // Удаление карточки
  void deleteWordCard(int index) {
    wordCardBox.deleteAt(index);
    loadCards();
  }

  // Удаление категории и связанных карточек
  void deleteCategory(String categoryName) {
    final categoryIndex = categories.indexWhere((c) => c.name == categoryName);
    if (categoryIndex != -1 && categoryName != 'Все категории') {
      categoryBox.deleteAt(categoryIndex);
      final cardsToDelete =
          wordCardBox.values.where((card) => card.category == categoryName).toList();
      for (var card in cardsToDelete) {
        final cardIndex = wordCardBox.values.toList().indexOf(card);
        wordCardBox.deleteAt(cardIndex);
      }
      loadCategories();
      loadCards();
    }
  }

  // Загрузка слов из файла
  Future<void> loadWordsFromFile(String categoryName) async {
    try {
      // Выбор файла
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'csv'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();

        // Парсинг содержимого
        List<String> lines = content.split(';');
        List<WordCard> newCards = [];

        for (String line in lines) {
          if (line.trim().isEmpty) continue;
          List<String> parts = line.split(':');
          if (parts.length != 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Некорректный формат строки: "$line"')),
            );
            continue;
          }

          String foreignWord = parts[0].trim();
          String nativeWord = parts[1].trim();

          newCards.add(WordCard(
            german: foreignWord,
            russian: nativeWord,
            category: categoryName,
            isFavorite: false,
            isFlipped: isFlippedGlobally, // Устанавливаем состояние переворота
          ));
        }

        // Добавление слов в базу данных
        for (var card in newCards) {
          await wordCardBox.add(card);
        }

        loadCards(); // Перезагружаем карточки

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Слова успешно загружены!')),
        );
      }
    } catch (e) {
      print("Ошибка при загрузке слов: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке слов')),
      );
    }
  }

  // Переключение порядка отображения слов на всех карточках
  Future<void> flipAllCards() async {
    setState(() {
      isFlippedGlobally = !isFlippedGlobally;
      for (var card in allCards) {
        if (currentCategory == 'Все категории' ||
            (currentCategory == 'Избранные' && card.isFavorite) ||
            card.category == currentCategory) {
          card.isFlipped = isFlippedGlobally;
          card.save();
        }
      }
      _filterCardsBySearch();
    });
  }

  // Новая функция для загрузки слов из текста
  Future<void> loadWordsFromText(String categoryName, String text) async {
    try {
      // Парсинг содержимого
      List<String> lines = text.split(';');
      List<WordCard> newCards = [];

      for (String line in lines) {
        if (line.trim().isEmpty) continue;
        List<String> parts = line.split(':');
        if (parts.length != 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Некорректный формат строки: "$line"')),
          );
          continue;
        }

        String foreignWord = parts[0].trim();
        String nativeWord = parts[1].trim();

        newCards.add(WordCard(
          german: foreignWord,
          russian: nativeWord,
          category: categoryName,
          isFavorite: false,
          isFlipped: isFlippedGlobally, // Устанавливаем состояние переворота
        ));
      }

      // Добавление слов в базу данных
      for (var card in newCards) {
        await wordCardBox.add(card);
      }

      loadCards(); // Перезагружаем карточки

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Слова успешно добавлены!')),
      );
    } catch (e) {
      print("Ошибка при добавлении слов: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при добавлении слов')),
      );
    }
  }

  @override
  void dispose() async {
    await wordCardBox.close();
    await categoryBox.close();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
  title: Text(AppLocalizations.of(context).title),
  actions: [
    // Меню для смены языка
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
    // Кнопка загрузки списка слов из файла
    IconButton(
      icon: Icon(Icons.upload_file),
      tooltip: AppLocalizations.of(context).upload_words,
      onPressed: () async {
        // Запросить у пользователя название категории
        String? categoryName = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            TextEditingController _controller = TextEditingController();
            return AlertDialog(
              title: Text(AppLocalizations.of(context).enter_category),
              content: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: AppLocalizations.of(context).category),
              ),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context).cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(AppLocalizations.of(context).save),
                  onPressed: () {
                    Navigator.of(context).pop(_controller.text);
                  },
                ),
              ],
            );
          },
        );

        if (categoryName != null && categoryName.trim().isNotEmpty) {
          categoryName = categoryName.trim();
          // Проверка, существует ли категория
          bool categoryExists = categories.any((c) => c.name == categoryName);
          if (!categoryExists) {
            // Добавление новой категории
            addCategory(Category(name: categoryName));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Категория "$categoryName" добавлена')),
            );
          }

          setState(() {
            currentCategory = categoryName!;
            displayedCards = Hive.box<WordCard>('wordCards').values
                .where((card) => card.category == currentCategory)
                .toList();
          });

          // Загрузка слов из файла
          await loadWordsFromFile(categoryName);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).category_not_selected)),
          );
        }
      },
    ),
    // Кнопка переворота порядка слов
    IconButton(
      icon: Icon(Icons.swap_horiz),
      tooltip: AppLocalizations.of(context).swap_order,
      onPressed: () async {
        await flipAllCards();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFlippedGlobally
                ? 'Порядок слов изменен: родное → иностранное'
                : 'Порядок слов изменен: иностранное → родное'),
          ),
        );
      },
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
                localizations.categories,
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
                          showDeleteCategoryDialog(
                              context, category.name, deleteCategory);
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
                setState(() {
                  currentCategory = 'Избранные';
                  displayedCards =
                      allCards.where((card) => card.isFavorite).toList();
                });
              },
            ),
            ListTile(
              title: Text(localizations.add_category),
              onTap: () {
                Navigator.pop(context);
                showAddCategoryDialog(context, addCategory);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Поле поиска
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Поиск',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Список карточек
          Expanded(
            child: displayedCards.isEmpty
                ? Center(child: Text(localizations.no_cards))
                : CardSwiperWidget(
                    cards: displayedCards,
                    onEditCard: (index, card) => showEditCardDialog(
                        context, index, card, updateWordCard),
                    onDeleteCard: (index) => deleteWordCard(index),
                    toggleFavorite: toggleFavorite,
                    isFlippedGlobally: isFlippedGlobally,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Показываем выбор между добавлением одного слова или списка слов
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return SafeArea(
                child: Wrap(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.add),
                      title: Text('Добавить одно слово'),
                      onTap: () {
                        Navigator.of(context).pop();
                        showAddSingleWordDialog();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.list),
                      title: Text('Добавить список слов'),
                      onTap: () {
                        Navigator.of(context).pop();
                        showAddWordListDialog();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        tooltip: AppLocalizations.of(context).add_card,
        child: Icon(Icons.add),
      ),
    );
  }

  // Диалог для редактирования карточки
  void showEditCardDialog(BuildContext context, int index, WordCard card, Function(int, WordCard) updateWordCard) {
    TextEditingController germanController = TextEditingController(text: card.german);
    TextEditingController russianController = TextEditingController(text: card.russian);

    showDialog(
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

                // Обновляем карточку
                updateWordCard(index, WordCard(
                  german: germanWord,
                  russian: russianWord,
                  category: card.category,
                  isFavorite: card.isFavorite,
                  isFlipped: card.isFlipped,
                ));

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Диалог для добавления одного слова

  // Обновлённый диалог для добавления одного слова с контроллерами
  void showAddSingleWordDialog() async {
    String? selectedCategory = currentCategory;

    // Если текущая категория - "Все категории" или "Избранные", попросим выбрать категорию
    if (currentCategory == 'Все категории' || currentCategory == 'Избранные') {
      selectedCategory = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Выберите категорию'),
            content: Container(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: categories.map((category) {
                  return ListTile(
                    title: Text(category.name),
                    onTap: () {
                      Navigator.of(context).pop(category.name);
                    },
                  );
                }).toList(),
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
          );
        },
      );
    }

    if (selectedCategory == null || selectedCategory.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Категория не выбрана')),
      );
      return;
    }

    // Контроллеры для ввода слов
    TextEditingController germanController = TextEditingController();
    TextEditingController russianController = TextEditingController();

    // Показываем диалог для ввода одного слова
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Добавить слово'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: germanController,
                decoration: InputDecoration(labelText: 'Иностранное слово'),
                autofocus: true,
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
              child: Text('Добавить'),
              onPressed: () {
                String germanWord = germanController.text.trim();
                String russianWord = russianController.text.trim();

                if (germanWord.isEmpty || russianWord.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Пожалуйста, заполните все поля')),
                  );
                  return;
                }

                // Добавляем новое слово
                addWordCard(WordCard(
                  german: germanWord,
                  russian: russianWord,
                  category: selectedCategory!,
                  isFavorite: false,
                  isFlipped: isFlippedGlobally,
                ));

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Диалог для добавления списка слов
  void showAddWordListDialog() async {
    String? selectedCategory = currentCategory;

    // Если текущая категория - "Все категории" или "Избранные", попросим выбрать категорию
    if (currentCategory == 'Все категории' || currentCategory == 'Избранные') {
      selectedCategory = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Выберите категорию'),
            content: Container(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: categories.map((category) {
                  return ListTile(
                    title: Text(category.name),
                    onTap: () {
                      Navigator.of(context).pop(category.name);
                    },
                  );
                }).toList(),
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
          );
        },
      );
    }

    if (selectedCategory == null || selectedCategory.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Категория не выбрана')),
      );
      return;
    }

    // Контроллер для ввода списка слов
    TextEditingController listController = TextEditingController();

    // Показываем диалог для ввода списка слов
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Добавить список слов'),
          content: SingleChildScrollView(
            child: TextField(
              controller: listController,
              decoration: InputDecoration(
                hintText: 'Например: Hallo:Привет;Danke:Спасибо;',
              ),
              maxLines: 10,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Добавить'),
              onPressed: () {
                String inputText = listController.text.trim();
                if (inputText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Список слов не может быть пустым')),
                  );
                  return;
                }

                // Парсинг и добавление слов
                loadWordsFromText(selectedCategory!, inputText);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
