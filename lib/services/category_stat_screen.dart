import '../word_card.dart';  
import 'package:flutter/material.dart';
import 'statistics_service.dart';
import '../quiz_screen.dart';

class CategoryStatsScreen extends StatelessWidget {
  final String category;
  final List<WordCard> cards;
  final StatisticsService statisticsService;

  CategoryStatsScreen({
    required this.category,
    required this.cards,
    required this.statisticsService,
  });

  @override
  Widget build(BuildContext context) {
    // Фильтруем только карточки этой категории
    List<WordCard> categoryCards = cards
        .where((card) => card.category == category)
        .toList();

    // Получаем статистику для каждой карточки
    List<Map<String, dynamic>> cardStats = categoryCards.map((card) {
      var stats = statisticsService.getWordStatistics(card.id, category);
      return {
        'card': card,
        'attempts': stats['totalAttempts'] ?? 0,
        'correct': stats['correctAnswers'] ?? 0,
        'rate': stats['successRate'] ?? 0.0,
        'lastAttempt': stats['lastAttempt'],
      };
    }).toList();

    // Сортируем от самых сложных к легким
    cardStats.sort((a, b) => (a['rate'] as double).compareTo(b['rate'] as double));

    return Scaffold(
      appBar: AppBar(
        title: Text('Статистика категории "$category"'),
        actions: [
          IconButton(
            icon: Icon(Icons.quiz),
            tooltip: 'Тест по сложным словам',
            onPressed: () {
              // Берем 10 самых сложных слов
              List<WordCard> hardestCards = cardStats
                  .take(10)
                  .map((stats) => stats['card'] as WordCard)
                  .toList();
                  
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(
                    cards: hardestCards,
                    isFlippedGlobally: false,
                    currentCategory: category,
                    wordCount: hardestCards.length,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: ListView(
        children: [
          _buildCategoryStats(cardStats),
          Divider(),
          ...cardStats.map((stats) => _buildCardStatItem(stats)),
        ],
      ),
    );
  }

  Widget _buildCategoryStats(List<Map<String, dynamic>> cardStats) {
    // Подсчет общей статистики
    int totalWords = cardStats.length;
    int studiedWords = cardStats.where((s) => (s['attempts'] as num) > 0).length;
    double avgSuccess = cardStats.fold(0.0, (sum, s) => sum + (s['rate'] as double)) / 
                      (studiedWords > 0 ? studiedWords : 1);

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Общий прогресс:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: studiedWords / totalWords,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              avgSuccess > 0.7 ? Colors.green : 
              avgSuccess > 0.4 ? Colors.orange : Colors.red
            ),
          ),
          SizedBox(height: 8),
          Text('Изучено ${studiedWords}/${totalWords} слов (${(studiedWords/totalWords*100).toStringAsFixed(1)}%)'),
          Text('Средний процент правильных ответов: ${(avgSuccess*100).toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _buildCardStatItem(Map<String, dynamic> stats) {
    WordCard card = stats['card'] as WordCard;
    int attempts = stats['attempts'] as int;
    int correct = stats['correct'] as int;
    double rate = stats['rate'] as double;
    
    return ListTile(
      title: Text('${card.german} - ${card.russian}'),
      subtitle: attempts > 0 
        ? Text('Правильно: $correct из $attempts (${(rate*100).toStringAsFixed(1)}%)') 
        : Text('Еще не изучалось'),
      trailing: Icon(
        attempts == 0 ? Icons.new_releases :
        rate > 0.7 ? Icons.check_circle :
        rate > 0.4 ? Icons.warning : 
        Icons.error,
        color: attempts == 0 ? Colors.blue :
               rate > 0.7 ? Colors.green :
               rate > 0.4 ? Colors.orange : 
               Colors.red,
      ),
    );
  }
}