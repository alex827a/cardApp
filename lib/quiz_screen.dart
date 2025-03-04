import 'package:flutter/material.dart';
import 'dart:math';
import 'word_card.dart';
import 'models/word_statistics.dart';
import 'services/statistics_service.dart';
import 'package:hive/hive.dart';


class QuizScreen extends StatefulWidget {
  final List<WordCard> cards;
  final bool isFlippedGlobally;
  final String currentCategory; // Add this field
  final int wordCount; // Add this field
  final Function(int correct, int total)? onComplete;

  
  QuizScreen({
    required this.cards,
    required this.isFlippedGlobally,
    required this.currentCategory, // Add this parameter
     required this.wordCount,
     this.onComplete, 
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<WordCard> quizCards;
  late WordCard currentCard;
  late List<String> options;
  int currentIndex = 0;
  int correctAnswers = 0;
  bool answered = false;
  String selectedAnswer = '';
  
  // Добавляем поля для статистики
  late StatisticsService statisticsService;
  late Box<WordStatistics> statsBox;
  Map<String, int> mistakeCount = {};
  Map<String, dynamic> currentStats = {};

  @override
  void initState() {
  super.initState();
  statsBox = Hive.box<WordStatistics>('wordStats');
  statisticsService = StatisticsService(statsBox);
  
  // Фильтруем карточки текущей категории
  List<WordCard> categoryCards = widget.cards
      .where((card) => card.category == widget.currentCategory)
      .toList();
  
  if (categoryCards.isEmpty) {
    quizCards = [];
  } else {
    quizCards = statisticsService.prioritizeWords(categoryCards, widget.currentCategory);
    // Используем выбранное пользователем количество слов
    if (quizCards.length > widget.wordCount) {
      quizCards = quizCards.sublist(0, widget.wordCount);
    }
  }
  
  // Инициализируем статистику с пустыми значениями
  currentStats = {
    'totalAttempts': 0,
    'correctAnswers': 0,
    'successRate': 0.0,
  };
  
  // Загружаем статистику, если есть карточки
  if (quizCards.isNotEmpty) {
    currentStats = getOverallStats();
    loadNextQuestion();
  }
}

 // В методе getOverallStats
Map<String, dynamic> getOverallStats() {
  if (quizCards.isEmpty) {
    return {
      'totalAttempts': 0,
      'correctAnswers': 0,
      'successRate': 0.0,
    };
  }
  
  int totalAttempts = 0;
  int totalCorrect = 0;
  
  for (var card in quizCards.where((card) => card.category == widget.currentCategory)) {
    var stats = statisticsService.getWordStatistics(card.id, widget.currentCategory);
    totalAttempts += ((stats['totalAttempts'] ?? 0) as num).toInt();
    totalCorrect += ((stats['correctAnswers'] ?? 0) as num).toInt();
  }
  
  return {
    'totalAttempts': totalAttempts,
    'correctAnswers': totalCorrect,
    'successRate': totalAttempts > 0 ? totalCorrect / totalAttempts : 0,
  };
}

  void loadNextQuestion() {
    if (currentIndex >= quizCards.length) {
      // Квиз закончен
      return;
    }
    
    setState(() {
      answered = false;
      selectedAnswer = '';
      currentCard = quizCards[currentIndex];
      options = generateOptions();
    });
  }
  
List<String> generateOptions() {
  // Отфильтруем только карточки из текущей категории для опций
  List<WordCard> categoryCards = widget.cards
      .where((card) => card.category == widget.currentCategory)
      .toList();
  
  // Если карточек недостаточно, используем все карточки, но не обновляем статистику для них
  List<String> allAnswers = (categoryCards.length >= 4 ? categoryCards : widget.cards)
      .map((card) => widget.isFlippedGlobally ? card.german : card.russian)
      .toList();
  
  String correctAnswer = widget.isFlippedGlobally ? currentCard.german : currentCard.russian;
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
    bool isCorrect = answer.toLowerCase() == correctAnswer.toLowerCase();
    
    // Update statistics only if the card belongs to current category
        setState(() {
      answered = true;
      selectedAnswer = answer;
      
      if (isCorrect) {
        correctAnswers++;
      } else {
        mistakeCount[currentCard.id] = (mistakeCount[currentCard.id] ?? 0) + 1;
      }
    });
    if (currentCard.category == widget.currentCategory) {
      statisticsService.updateWordStatistics(currentCard.id, isCorrect,widget.currentCategory);
      currentStats = getOverallStats();
    }
     // Обновляем общую статистику
    
    

    Future.delayed(Duration(seconds: 1), () {
      currentIndex++;
      if (currentIndex < quizCards.length) {
        loadNextQuestion();
      } else {
        showResults();
      }
    });
  }

  
  
  void showResults() {
    int totalMistakes = mistakeCount.values.fold(0, (sum, count) => sum + count);
    List<MapEntry<String, int>> sortedMistakes = mistakeCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    double sessionAccuracy = correctAnswers / quizCards.length;
    
   showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text('Результаты теста'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Секция результатов текущей сессии
            Text('Текущая сессия', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Правильных ответов:'),
                        Text('$correctAnswers из ${quizCards.length}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: sessionAccuracy,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        sessionAccuracy > 0.7 ? Colors.green : 
                        sessionAccuracy > 0.4 ? Colors.orange : Colors.red
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${(sessionAccuracy * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: sessionAccuracy > 0.7 ? Colors.green : 
                              sessionAccuracy > 0.4 ? Colors.orange : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Секция общей статистики
            Text('Общая статистика', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatRow('Всего попыток:', 
                      currentStats['totalAttempts']?.toString() ?? '0'),
                    _buildStatRow('Правильных ответов:', 
                      currentStats['correctAnswers']?.toString() ?? '0'),
                    _buildStatRow('Общий процент успеха:', 
                      '${((currentStats['successRate'] ?? 0) * 100).toStringAsFixed(1)}%'),
                    if (currentStats['consecutiveCorrectAnswers'] != null)
                      _buildStatRow('Серия правильных ответов:', 
                        currentStats['consecutiveCorrectAnswers'].toString()),
                  ],
                ),
              ),
            ),
            
            // Секция ошибок
            if (totalMistakes > 0) ...[
              SizedBox(height: 16),
              Text('Слова с ошибками', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: sortedMistakes.take(5).map((entry) {
                      WordCard card = quizCards.firstWhere((c) => c.id == entry.key);
                      return Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('${card.german} - ${card.russian}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Категория: ${card.category}'),
                                Text('Ошибок в этой сессии: ${entry.value}'),
                                Text('Общий процент успеха: ${
                                  ((statisticsService.getWordStatistics(card.id)['successRate'] ?? 0) * 100)
                                    .toStringAsFixed(1)}%'
                                ),
                              ],
                            ),
                          ),
                          if (entry != sortedMistakes.last) Divider(),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
        actions: [
          TextButton(
          child: Text('Пройти еще раз'),
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {
            currentIndex = 0;
            correctAnswers = 0;
            mistakeCount.clear();
            quizCards = statisticsService.prioritizeWords(widget.cards, widget.currentCategory);
            if (quizCards.length > widget.wordCount) {
              quizCards = quizCards.sublist(0, widget.wordCount);
            }
            loadNextQuestion();
            });
          },
        ),
        TextButton(
        child: Text('Вернуться'),
        onPressed: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(); // Return to previous screen
        },
        ),
        ],
      ),
    );
  }

  // Добавляем кнопку статистики в AppBar
  @override
  Widget build(BuildContext context) {
    if (quizCards.isEmpty) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Тестирование'),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            tooltip: 'Статистика',
            onPressed: () => _showStatistics(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Нет доступных карточек для теста', 
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Вернуться назад'),
            )
          ],
        ),
      ),
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
        IconButton(
        icon: Icon(Icons.bar_chart),
        tooltip: 'Статистика',
        onPressed: () => _showStatistics(context),
        ),
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
                child: Column(
                  children: [
                    Text(
                      question,
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    if (answered)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
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
            ),
            SizedBox(height: 20),
            Column(
              children: [
                Text('Выберите перевод:', style: TextStyle(fontSize: 18)),
                SizedBox(height: 14),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStatistics(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Статистика изучения'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Текущая сессия:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Правильных ответов: $correctAnswers из $currentIndex'),
              Text('Процент успеха: ${currentIndex > 0 ? (correctAnswers / currentIndex * 100).toStringAsFixed(1) : '0'}%'),
              Divider(),
              Text('Общая статистика:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Всего попыток: ${currentStats['totalAttempts'] ?? 0}'),
              Text('Правильных ответов: ${currentStats['correctAnswers'] ?? 0}'),
              Text('Процент успеха: ${((currentStats['successRate'] ?? 0) * 100).toStringAsFixed(1)}%'),
              SizedBox(height: 16),
              buildProgressIndicator(),
            ],
          ),
        ),
        
         actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              // Вызываем callback перед закрытием
              widget.onComplete?.call(correctAnswers, quizCards.length);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
          // ...остальные кнопки...
      ],
      ),
    );
  }

    Widget buildProgressIndicator() {
    if (currentStats.isEmpty) return SizedBox.shrink();
    
    double progress = currentStats['successRate'] ?? 0;
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress > 0.7 ? Colors.green : 
            progress > 0.4 ? Colors.orange : Colors.red
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Прогресс изучения: ${(progress * 100).toStringAsFixed(1)}%',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
   Widget _buildStatRow(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
}