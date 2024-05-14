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
      'title': 'German Language',
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
      'favorites': 'Favorites'  // Добавлено
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
      'favorites': 'Избранные'  // Добавлено
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
  String get favorites => _localizedValues[locale.languageCode]!['favorites']!;  // Добавлено
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
