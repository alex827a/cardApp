import 'package:flutter/material.dart';
import 'dart:math';
import 'word_card.dart';

class WriteAnswerQuizScreen extends StatefulWidget {
  final List<WordCard> cards;
  final bool isFlippedGlobally;
  
  WriteAnswerQuizScreen({
    required this.cards,
    required this.isFlippedGlobally,
  });

  @override
  _WriteAnswerQuizScreenState createState() => _WriteAnswerQuizScreenState();
}

class _WriteAnswerQuizScreenState extends State<WriteAnswerQuizScreen> {
  late List<WordCard> quizCards;
  late WordCard currentCard;
  int currentIndex = 0;
  int correctAnswers = 0;
  bool answered = false;
  String userAnswer = '';
  TextEditingController answerController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Перемешиваем карточки для квиза
    quizCards = List.from(widget.cards)..shuffle();
    if (quizCards.length > 10) {
      quizCards = quizCards.sublist(0, 10); // Ограничим до 10 слов
    }
    loadNextQuestion();
  }
  
  void loadNextQuestion() {
    if (currentIndex >= quizCards.length) {
      // Квиз закончен
      return;
    }
    
    setState(() {
      answered = false;
      userAnswer = '';
      answerController.clear();
      currentCard = quizCards[currentIndex];
    });
  }
  
  void checkAnswer() {
    if (answered) return;
    
    String answer = answerController.text.trim();
    String correctAnswer = widget.isFlippedGlobally ? currentCard.german : currentCard.russian;
    
    setState(() {
      answered = true;
      userAnswer = answer;
      
      // Простая проверка соответствия
      if (answer.toLowerCase() == correctAnswer.toLowerCase()) {
        correctAnswers++;
      }
    });
    
    Future.delayed(Duration(seconds: 2), () {
      currentIndex++;
      if (currentIndex < quizCards.length) {
        loadNextQuestion();
      } else {
        // Показать результаты
        showResults();
      }
    });
  }
  
  void showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Результаты теста'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Правильных ответов: $correctAnswers из ${quizCards.length}'),
            Text('Процент успеха: ${(correctAnswers / quizCards.length * 100).toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Вернуться на предыдущий экран
            },
          ),
          TextButton(
            child: Text('Пройти еще раз'),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                currentIndex = 0;
                correctAnswers = 0;
                quizCards.shuffle();
                loadNextQuestion();
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (quizCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Угадай слово')),
        body: Center(child: Text('Нет доступных карточек для теста')),
      );
    }
    
    if (currentIndex >= quizCards.length) {
      return Scaffold(
        appBar: AppBar(title: Text('Угадай слово')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    String question = widget.isFlippedGlobally ? currentCard.russian : currentCard.german;
    String correctAnswer = widget.isFlippedGlobally ? currentCard.german : currentCard.russian;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Угадай слово'),
        actions: [
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('${currentIndex + 1}/${quizCards.length}', 
              style: TextStyle(fontSize: 18)
            ),
          )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  question,
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: answerController,
              decoration: InputDecoration(
                labelText: 'Введите перевод',
                border: OutlineInputBorder(),
              ),
              enabled: !answered,
              autofocus: true,
              onSubmitted: (_) => checkAnswer(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Проверить', style: TextStyle(fontSize: 16)),
              onPressed: answered ? null : checkAnswer,
            ),
            SizedBox(height: 16),
            if (answered)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: userAnswer.toLowerCase() == correctAnswer.toLowerCase()
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      userAnswer.toLowerCase() == correctAnswer.toLowerCase()
                          ? 'Правильно!'
                          : 'Неправильно!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: userAnswer.toLowerCase() == correctAnswer.toLowerCase()
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Правильный ответ: $correctAnswer',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}