import 'package:flutter/material.dart';
import 'dart:math';
import 'word_card.dart';
import 'services/statistics_service.dart';
import 'models/word_statistics.dart';
import 'package:hive/hive.dart';

class WriteAnswerQuizScreen extends StatefulWidget {
  final List<WordCard> cards;
  final bool isFlippedGlobally;
  final String currentCategory;
   final int wordCount; 
  
  WriteAnswerQuizScreen({
    required this.cards,
    required this.isFlippedGlobally,
    required this.currentCategory,
    required this.wordCount, // Добавьте этот параметр
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
  
  // Добавляем новые поля
  late StatisticsService statisticsService;
  late Box<WordStatistics> statsBox;
  Map<String, int> mistakeCount = {};
  Map<String, dynamic> currentStats = {};
  
@override
void initState() {

      super.initState();
      statsBox = Hive.box<WordStatistics>('wordStats');
      statisticsService = StatisticsService(statsBox);
      quizCards = statisticsService.prioritizeWords(widget.cards, widget.currentCategory);
      // Используем выбранное пользователем количество слов
      if (quizCards.length > widget.wordCount) {
        quizCards = quizCards.sublist(0, widget.wordCount);
      }
      currentStats = getOverallStats();
      loadNextQuestion();

  }
  // Добавьте этот метод в класс _WriteAnswerQuizScreenState
Map<String, dynamic> getOverallStats() {
  int totalAttempts = 0;
  int totalCorrect = 0;
  
  // Фильтруем по текущей категории
  for (var card in quizCards.where((card) => card.category == widget.currentCategory)) {
    var stats = statisticsService.getWordStatistics(card.id);
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
      userAnswer = '';
      answerController.clear();
      currentCard = quizCards[currentIndex];
    });
  }
  
  void checkAnswer() {
  if (answered) return;
  
  String answer = answerController.text.trim().toLowerCase();
  String correctAnswer = widget.isFlippedGlobally ? 
    currentCard.german.toLowerCase() : 
    currentCard.russian.toLowerCase();
  
  bool isCorrect = answer == correctAnswer;
     
  setState(() {
    answered = true;
    userAnswer = answer;
    
    if (isCorrect) {
      correctAnswers++;
    } else {
      // Отслеживаем ошибки
      mistakeCount[currentCard.id] = (mistakeCount[currentCard.id] ?? 0) + 1;
    }
  });

  // Обновляем статистику ТОЛЬКО для карточек текущей категории
  if (currentCard.category == widget.currentCategory) {
    statisticsService.updateWordStatistics(currentCard.id, isCorrect, widget.currentCategory);
  }
  
  // Обновляем общую статистику
  currentStats = getOverallStats();
  
  Future.delayed(Duration(seconds: 2), () {
    currentIndex++;
    if (currentIndex < quizCards.length) {
      loadNextQuestion();
    } else {
      showResults();
    }
  });
}
  
 void showResults() {
  // Вычисляем общую статистику
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
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
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
      ],
    ),
  );
}



  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
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

  // Добавляем виджет для отображения прогресса
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
        // Добавляем кнопку статистики
        IconButton(
          icon: Icon(Icons.bar_chart),
          tooltip: 'Статистика',
          onPressed: () => _showStatistics(context),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('${currentIndex + 1}/${quizCards.length}', 
              style: TextStyle(fontSize: 18)
            ),
          ),
        ),
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
            buildProgressIndicator(), // Добавляем индикатор прогресса
            Spacer(),
          ],
        ),
      ),
    );
  }

  // Добавляем новый метод для отображения статистики
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
          child: Text('Закрыть'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
}