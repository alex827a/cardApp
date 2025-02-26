import 'package:flutter/material.dart';
import 'dart:math';
import 'word_card.dart';

class QuizScreen extends StatefulWidget {
  final List<WordCard> cards;
  final bool isFlippedGlobally;
  
  QuizScreen({
    required this.cards,
    required this.isFlippedGlobally,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<WordCard> quizCards;
  late WordCard currentCard;
  List<String> options = [];
  int currentIndex = 0;
  int correctAnswers = 0;
  bool answered = false;
  String? selectedAnswer;
  
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
      selectedAnswer = null;
      currentCard = quizCards[currentIndex];
      options = generateOptions();
    });
  }
  
  List<String> generateOptions() {
    // Создаем варианты ответов
    List<String> allAnswers = widget.cards
        .map((card) => widget.isFlippedGlobally ? card.german : card.russian)
        .toList();
    
    // Правильный ответ
    String correctAnswer = widget.isFlippedGlobally ? currentCard.german : currentCard.russian;
    
    // Случайные опции
    Set<String> optionsSet = {correctAnswer};
    final random = Random();
    
    while (optionsSet.length < 4 && optionsSet.length < allAnswers.length) {
      String randomOption = allAnswers[random.nextInt(allAnswers.length)];
      optionsSet.add(randomOption);
    }
    
    List<String> optionsList = optionsSet.toList()..shuffle();
    return optionsList;
  }
  
  void checkAnswer(String answer) {
    if (answered) return;
    
    String correctAnswer = widget.isFlippedGlobally ? currentCard.german : currentCard.russian;
    
    setState(() {
      answered = true;
      selectedAnswer = answer;
      
      if (answer == correctAnswer) {
        correctAnswers++;
      }
    });
    
    Future.delayed(Duration(seconds: 1), () {
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
        title: Text('Результаты квиза'),
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
  Widget build(BuildContext context) {
    if (quizCards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Тестирование')),
        body: Center(child: Text('Нет доступных карточек для теста')),
      );
    }
    
    if (currentIndex >= quizCards.length) {
      return Scaffold(
        appBar: AppBar(title: Text('Тестирование')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    String question = widget.isFlippedGlobally ? currentCard.russian : currentCard.german;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Тестирование'),
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
            Text('Выберите перевод:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            ...options.map((option) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: answered
                      ? (option == (widget.isFlippedGlobally ? currentCard.german : currentCard.russian))
                          ? Colors.green
                          : (option == selectedAnswer ? Colors.red : null)
                      : null,
                ),
                onPressed: answered ? null : () => checkAnswer(option),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(option, style: TextStyle(fontSize: 16)),
                ),
              ),
            )).toList(),
            Spacer(),
            if (answered)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  selectedAnswer == (widget.isFlippedGlobally ? currentCard.german : currentCard.russian)
                      ? 'Правильно!'
                      : 'Неправильно. Правильный ответ: ${widget.isFlippedGlobally ? currentCard.german : currentCard.russian}',
                  style: TextStyle(
                    fontSize: 18,
                    color: selectedAnswer == (widget.isFlippedGlobally ? currentCard.german : currentCard.russian)
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}