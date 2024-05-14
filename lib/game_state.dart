import 'package:flutter/material.dart';
import 'word_card.dart';

class GameState extends ChangeNotifier {
  int score = 0;
  List<WordCard> _cards = [
    WordCard(german: 'Hallo', russian: 'Привет', category: 'Basic'),
    WordCard(german: 'Tschüss', russian: 'Пока', category: 'Basic'),
    // Добавьте больше карточек
  ];

  List<WordCard> getCards() {
    return _cards;
  }

  void increaseScore() {
    score++;
    notifyListeners();
  }

  void decreaseScore() {
    score--;
    notifyListeners();
  }
}
