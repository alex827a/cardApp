import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flip_card/flip_card.dart';
import 'word_card.dart';
import 'flip_card_widget.dart';

class CardSwiper extends StatelessWidget {
  final List<WordCard> cards;
  final Function(int, WordCard) onEditCard;
  final Function(int) onDeleteCard;

  CardSwiper({
    required this.cards,
    required this.onEditCard,
    required this.onDeleteCard,
  });

  @override
  Widget build(BuildContext context) {
    return Swiper(
      itemBuilder: (BuildContext context, int index) {
        return Card(
          elevation: 4,
          margin: EdgeInsets.all(8),
          child: Stack(
            children: [
              FlipCardWidget(card: cards[index]),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => onEditCard(index, cards[index]),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => onDeleteCard(index),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      itemCount: cards.length,
      viewportFraction: 0.8,
      scale: 0.9,
      loop: false,
      control: SwiperControl(),
    );
  }
}
