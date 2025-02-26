import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../word_card.dart';

class CardService {
  final Box<WordCard> wordCardBox;

  CardService(this.wordCardBox);

  List<WordCard> getAllCards() {
    return wordCardBox.values.toList();
  }

  Future<void> addCard(WordCard card) async{
    wordCardBox.add(card);
  }

  void updateCard(int index, WordCard card) {
    wordCardBox.putAt(index, card);
  }

 Future<void> deleteCard(WordCard card) async {
  final allCards = getAllCards();
  int actualIndex = allCards.indexOf(card);
  if (actualIndex != -1) {
    await wordCardBox.deleteAt(actualIndex);
  }
}

  void toggleFavorite(WordCard card) {
    card.isFavorite = !card.isFavorite;
    card.save();
  }

  List<WordCard> getCardsByCategory(String categoryName) {
    if (categoryName == 'Все категории') {
      return getAllCards();
    } else if (categoryName == 'Избранные') {
      return getAllCards().where((card) => card.isFavorite).toList();
    } else {
      return getAllCards().where((card) => card.category == categoryName).toList();
    }
  }

  List<WordCard> searchCards(String query, String categoryName) {
    final lowercaseQuery = query.toLowerCase();
    return getCardsByCategory(categoryName).where((card) {
      return card.german.toLowerCase().contains(lowercaseQuery) || 
             card.russian.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Удаление карточки по индексу из отфильтрованного списка
  void deleteCardByDisplayedIndex(List<WordCard> displayedCards, int index, List<WordCard> allCards) {
    WordCard cardToDelete = displayedCards[index];
    int actualIndex = allCards.indexOf(cardToDelete);
    if (actualIndex != -1) {
      wordCardBox.deleteAt(actualIndex);
    }
  }
}