import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'word_card.dart';

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
