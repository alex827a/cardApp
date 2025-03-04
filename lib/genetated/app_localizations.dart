import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> _supportedLocales = [
    Locale('en', ''),
    Locale('ru', ''),
  ];

  static List<Locale> get supportedLocales => _supportedLocales;

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'My Vocab',
      'categories': 'Categories',
      'add_card': 'Add Card',
      'add_category': 'Add Category',
      'no_cards': 'No cards',
      'delete_category': 'Delete Category',
      'delete_category_confirm': "Are you sure you want to delete the category '{category}' and all its words?",
      'edit_card': 'Edit Card',
      'german_word': 'German Word',
      'russian_word': 'Russian Word',
      'category': 'Category',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'all_categories': 'All Categories',
      'favorites': 'Favorites',
      'add_single_word': 'Add Single Word', // Новая строка
      'add_word_list': 'Add Word List',     // Новая строка
      'enter_category': 'Enter Category',  // Новая строка
      'word_list_placeholder': 'Example: Hallo:Hello;Danke:Thanks;', // Новая строка
      'swap_order': 'Swap Word Order',     // Новая строка
      'upload_words': 'Upload Words',      // Новая строка
      'category_not_selected': 'Category not selected', // Новая строка
      'incorrect_format': 'Incorrect format: "{line}"', // Новая строка
       'please_fill_all_fields': 'Please fill in all fields',
  'word_added_successfully': 'Word added successfully!',
  'word_list_added_successfully': 'Word list added successfully!',
    },
    'ru': {
      'title': 'Немецкий язык',
      'categories': 'Категории',
      'add_card': 'Добавить карточку',
      'add_category': 'Добавить категорию',
      'no_cards': 'Нет карточек',
      'delete_category': 'Удалить категорию',
      'delete_category_confirm': "Вы уверены, что хотите удалить категорию '{category}' и все её слова?",
      'edit_card': 'Редактировать карточку',
      'german_word': 'Немецкое слово',
      'russian_word': 'Русское слово',
      'category': 'Категория',
      'cancel': 'Отмена',
      'save': 'Сохранить',
      'delete': 'Удалить',
      'all_categories': 'Все категории',
      'favorites': 'Избранные',
      'add_single_word': 'Добавить одно слово', // Новая строка
      'add_word_list': 'Добавить список слов',  // Новая строка
      'enter_category': 'Введите категорию',   // Новая строка
      'word_list_placeholder': 'Например: Hallo:Привет;Danke:Спасибо;', // Новая строка
      'swap_order': 'Сменить порядок слов',    // Новая строка
      'upload_words': 'Загрузить слова',       // Новая строка
      'category_not_selected': 'Категория не выбрана', // Новая строка
      'incorrect_format': 'Некорректный формат: "{line}"', // Новая строка
      'please_fill_all_fields': 'Пожалуйста, заполните все поля',
      'word_added_successfully': 'Слово успешно добавлено!',
      'word_list_added_successfully': 'Список слов успешно добавлен!',
    },
  };

  String get title => _localizedValues[locale.languageCode]!['title']!;
  String get categories => _localizedValues[locale.languageCode]!['categories']!;
  String get add_card => _localizedValues[locale.languageCode]!['add_card']!;
  String get add_category => _localizedValues[locale.languageCode]!['add_category']!;
  String get no_cards => _localizedValues[locale.languageCode]!['no_cards']!;
  String get delete_category => _localizedValues[locale.languageCode]!['delete_category']!;
  String get delete_category_confirm => _localizedValues[locale.languageCode]!['delete_category_confirm']!;
  String get edit_card => _localizedValues[locale.languageCode]!['edit_card']!;
  String get german_word => _localizedValues[locale.languageCode]!['german_word']!;
  String get russian_word => _localizedValues[locale.languageCode]!['russian_word']!;
  String get category => _localizedValues[locale.languageCode]!['category']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get all_categories => _localizedValues[locale.languageCode]!['all_categories']!;
  String get favorites => _localizedValues[locale.languageCode]!['favorites']!;
  String get add_single_word => _localizedValues[locale.languageCode]!['add_single_word']!; // Новый метод
  String get add_word_list => _localizedValues[locale.languageCode]!['add_word_list']!;     // Новый метод
  String get enter_category => _localizedValues[locale.languageCode]!['enter_category']!;  // Новый метод
  String get word_list_placeholder => _localizedValues[locale.languageCode]!['word_list_placeholder']!; // Новый метод
  String get swap_order => _localizedValues[locale.languageCode]!['swap_order']!;          // Новый метод
  String get upload_words => _localizedValues[locale.languageCode]!['upload_words']!;      // Новый метод
  String get category_not_selected => _localizedValues[locale.languageCode]!['category_not_selected']!; // Новый метод
  String get incorrect_format => _localizedValues[locale.languageCode]!['incorrect_format']!; // Новый метод
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
