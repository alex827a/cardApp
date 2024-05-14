import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'word_card.dart';

class GameCardWidget extends StatelessWidget {
  final WordCard card;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  GameCardWidget({
    required this.card,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx < 0) {
          onSwipeLeft();
        } else if (details.velocity.pixelsPerSecond.dx > 0) {
          onSwipeRight();
        }
      },
      child: FlipCard(
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
      ),
    );
  }
}
