import 'package:hive/hive.dart';
import '../models/word_statistics.dart';
import '../word_card.dart';  
import 'dart:math';

class StatisticsService {
  final Box<WordStatistics> _box;

  StatisticsService(this._box);

 // В классе StatisticsService
  Future<void> updateWordStatistics(String wordId, bool isCorrect, String category) async {
    String statsKey = '${wordId}_${category}'; // Используем комбинацию ID и категории как ключ
    
    var stats = _box.get(statsKey) ?? WordStatistics(
      wordId: wordId,
      lastAttempt: DateTime.now(),
      category: category,
    );
    
    // Обновляем статистику
    stats.totalAttempts++;
    if (isCorrect) {
      stats.correctAnswers++;
      stats.consecutiveCorrectAnswers++;
    } else {
      stats.consecutiveCorrectAnswers = 0;
    }
    stats.lastAttempt = DateTime.now();
    
    await _box.put(statsKey, stats);
  }
  

// В StatisticsService.dart
List<WordCard> prioritizeWords(List<WordCard> cards, String category) {
  // Создаем карты для хранения статистики
  Map<String, double> priorities = {};
  
  for (var card in cards) {
    // Получаем статистику для карточки
    var stats = getWordStatistics(card.id, category);
    int attempts = ((stats['totalAttempts'] ?? 0) as num).toInt();
    int correct = ((stats['correctAnswers'] ?? 0) as num).toInt();
    DateTime? lastAttempt = stats['lastAttempt'] as DateTime?;
    
    // Рассчитываем приоритет (чем выше, тем важнее изучать)
    double priority = 0;
    
    if (attempts == 0) {
      // Новое слово - средний приоритет
      priority = 50;
    } else {
      // Рассчитываем коэффициент успешности
      double successRate = correct / attempts;
      
      // Больше ошибок - выше приоритет (обратная величина успешности)
      priority = 100 * (1 - successRate);
      
      // Учитываем время с последней попытки - чем дольше не повторяли, тем выше приоритет
      if (lastAttempt != null) {
        int daysSinceLastAttempt = DateTime.now().difference(lastAttempt).inDays;
        
        // Формула забывания на основе кривой Эббингауза
        // Для хорошо изученных слов (>70%) интервал повторения дольше
        int optimalInterval = successRate > 0.7 ? 7 : (successRate > 0.4 ? 3 : 1);
        
        // Если прошло больше времени, чем оптимальный интервал - увеличиваем приоритет
        if (daysSinceLastAttempt > optimalInterval) {
          priority += 20 * (daysSinceLastAttempt / optimalInterval);
        }
      }
    }
    
    // Максимум 100
    priority = min(100, priority);
    priorities[card.id] = priority;
  }
  
  // Сортируем карточки по приоритету (высокий приоритет сначала)
  cards.sort((a, b) => priorities[b.id]!.compareTo(priorities[a.id]!));
  
  // Балансировка выборки:
  if (cards.length > 10) {
    // Берем карточки по категориям сложности
    List<WordCard> hardCards = []; // Сложные (высокий приоритет)
    List<WordCard> mediumCards = []; // Средние
    List<WordCard> easyCards = []; // Легкие (низкий приоритет)
    
    for (int i = 0; i < cards.length; i++) {
      double priority = priorities[cards[i].id]!;
      if (priority > 70) {
        hardCards.add(cards[i]);
      } else if (priority > 30) {
        mediumCards.add(cards[i]);
      } else {
        easyCards.add(cards[i]);
      }
    }
    
    // Перемешиваем каждую группу
    hardCards.shuffle();
    mediumCards.shuffle();
    easyCards.shuffle();
    
    // Формируем сбалансированный список: ~60% сложных, 30% средних, 10% легких
    List<WordCard> balancedCards = [];
    
    // Не более 60% сложных карточек
    int hardCount = min((cards.length * 0.6).round(), hardCards.length);
    balancedCards.addAll(hardCards.take(hardCount));
    
    // Не более 30% средних карточек
    int mediumCount = min((cards.length * 0.3).round(), mediumCards.length);
    balancedCards.addAll(mediumCards.take(mediumCount));
    
    // Оставшееся заполняем легкими
    int easyCount = cards.length - balancedCards.length;
    if (easyCount > 0 && easyCards.isNotEmpty) {
      balancedCards.addAll(easyCards.take(easyCount));
    }
    
    // Если не хватило легких, добавляем из средних или сложных
    if (balancedCards.length < cards.length) {
      if (mediumCards.length > mediumCount) {
        balancedCards.addAll(mediumCards.skip(mediumCount)
            .take(cards.length - balancedCards.length));
      }
      if (balancedCards.length < cards.length && hardCards.length > hardCount) {
        balancedCards.addAll(hardCards.skip(hardCount)
            .take(cards.length - balancedCards.length));
      }
    }
    
    // Перемешиваем финальный список для разнообразия
    balancedCards.shuffle();
    return balancedCards;
  }
  
  // Для маленьких наборов просто перемешиваем
  cards.shuffle();
  return cards;
}
 // Обновляем метод получения статистики для учета категории
  Map<String, dynamic> getWordStatistics(String wordId, [String? category]) {
    if (category != null) {
      String statsKey = '${wordId}_${category}';
      var stats = _box.get(statsKey);
      if (stats == null) return {};
      
      return {
        'totalAttempts': stats.totalAttempts,
        'correctAnswers': stats.correctAnswers,
        'successRate': stats.successRate,
        'lastAttempt': stats.lastAttempt,
        'consecutiveCorrectAnswers': stats.consecutiveCorrectAnswers,
        'category': stats.category,
      };
    } else {
      // Если категория не указана, возвращаем статистику из любой категории
      // (это нужно заменить на более осмысленное поведение)
      var keyPrefix = '${wordId}_';
      var allStats = _box.values.where((stats) => stats.wordId == wordId);
      if (allStats.isEmpty) return {};
      
      var stats = allStats.first;
      return {
        'totalAttempts': stats.totalAttempts,
        'correctAnswers': stats.correctAnswers,
        'successRate': stats.successRate,
        'lastAttempt': stats.lastAttempt,
        'consecutiveCorrectAnswers': stats.consecutiveCorrectAnswers,
        'category': stats.category,
      };
    }
  }
}