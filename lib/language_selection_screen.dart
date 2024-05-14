import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';
import 'home_screen.dart';
import 'word_card.dart';
import 'category.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class LanguageSelectionScreen extends StatelessWidget {
  Future<void> _loadInitialData(BuildContext context, String languageCode) async {
    try {
      String data = await rootBundle.loadString('assets/${languageCode}_initial_data.json');
      Map<String, dynamic> jsonResult = json.decode(data);

      List<dynamic> categoriesJson = jsonResult['categories'];
      List<dynamic> wordsJson = jsonResult['words'];

      Box<WordCard> wordCardBox = Hive.box<WordCard>('wordCards');
      Box<Category> categoryBox = Hive.box<Category>('categories');

      // Clear existing data
      await wordCardBox.clear();
      await categoryBox.clear();

      // Load categories
      for (var categoryJson in categoriesJson) {
        categoryBox.add(Category(name: categoryJson['name']));
      }

      // Load words
      for (var wordJson in wordsJson) {
        wordCardBox.add(WordCard(
          german: wordJson['german'],
          russian: wordJson['russian'],
          category: wordJson['category'],
          isFavorite: false,
        ));
      }

      // Mark the initial run as completed
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('isFirstRun', false);

      // Navigate to HomeScreen
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      print("Error loading initial data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _loadInitialData(context, 'en_german'),
              child: Text('English/German'),
            ),
            ElevatedButton(
              onPressed: () => _loadInitialData(context, 'german_russian'),
              child: Text('Немецкий/Русский'),
            ),
            ElevatedButton(
              onPressed: () => _loadInitialData(context, 'ukrainian_german'),
              child: Text('Украинский/Немецкий'),
            ),
          ],
        ),
      ),
    );
  }
}
