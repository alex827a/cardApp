import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../category.dart';
import '../word_card.dart';

class CategoryService {
  final Box<Category> categoryBox;
  final Box<WordCard> wordCardBox;

  CategoryService(this.categoryBox, this.wordCardBox);

  List<Category> getAllCategories() {
    return categoryBox.values.toList();
  }

  Future<void> addCategory(Category category) async {
    categoryBox.add(category);
  }

  void deleteCategory(String categoryName) {
    final categories = getAllCategories();
    final categoryIndex = categories.indexWhere((c) => c.name == categoryName);
    
    if (categoryIndex != -1 && categoryName != 'Все категории') {
      categoryBox.deleteAt(categoryIndex);
      
      // Удаление связанных карточек
      final cardsToDelete = wordCardBox.values.where((card) => card.category == categoryName).toList();
      for (var card in cardsToDelete) {
        final cardIndex = wordCardBox.values.toList().indexOf(card);
        wordCardBox.deleteAt(cardIndex);
      }
    }
  }

  bool categoryExists(String categoryName) {
    return getAllCategories().any((c) => c.name == categoryName);
  }

 
  Future<void> clearAll() async {
    await categoryBox.clear();
  }
}