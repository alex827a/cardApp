import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';
import 'game_card_widget.dart';
import 'word_card.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<WordCard> cards;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameState = Provider.of<GameState>(context, listen: false);
      cards = gameState.getCards();
      setState(() {});
    });
  }

  void onSwipeLeft() {
    Provider.of<GameState>(context, listen: false).decreaseScore();
    setState(() {
      currentIndex = (currentIndex + 1) % cards.length;
    });
  }

  void onSwipeRight() {
    Provider.of<GameState>(context, listen: false).increaseScore();
    setState(() {
      currentIndex = (currentIndex + 1) % cards.length;
    });
  }

  void resetGame() {
    setState(() {
      currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Language Learning Game'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Score: ${Provider.of<GameState>(context).score}',
              style: TextStyle(fontSize: 24),
            ),
          ),
          Expanded(
            child: Center(
              child: cards.isEmpty
                  ? CircularProgressIndicator() // Показать индикатор загрузки, если карточки еще не загружены
                  : currentIndex < cards.length
                      ? GameCardWidget(
                          card: cards[currentIndex],
                          onSwipeLeft: onSwipeLeft,
                          onSwipeRight: onSwipeRight,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Вы просмотрели все карточки!'),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: resetGame,
                              child: Text('Начать сначала'),
                            ),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
