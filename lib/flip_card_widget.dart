import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'word_card.dart';

class FlipCardWidget extends StatelessWidget {
  final WordCard card;
  final Function(WordCard) toggleFavorite;

  FlipCardWidget({required this.card, required this.toggleFavorite});

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      front: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade100, // Мягкий синий цвет
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Stack(
          children: [
            Center(
              child: Text(
                card.german,
                style: TextStyle(fontSize: 20, color: Colors.black), // Черный цвет текста
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: Icon(
                  card.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: card.isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () => toggleFavorite(card),
              ),
            ),
          ],
        ),
      ),
      back: Container(
        decoration: BoxDecoration(
          color: Colors.pink.shade100, // Мягкий розовый цвет
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Stack(
          children: [
            Center(
              child: Text(
                card.russian,
                style: TextStyle(fontSize: 20, color: Colors.black), // Черный цвет текста
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: Icon(
                  card.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: card.isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () => toggleFavorite(card),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
