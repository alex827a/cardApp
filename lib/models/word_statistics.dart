import 'package:hive/hive.dart';

part 'word_statistics.g.dart';


@HiveType(typeId: 2)
class WordStatistics extends HiveObject {
  @HiveField(0)
  final String wordId; // Уникальный идентификатор слова

  @HiveField(1)
  int totalAttempts;

  @HiveField(2)
  int correctAnswers;

  @HiveField(3)
  DateTime lastAttempt;

  @HiveField(4)
  int consecutiveCorrectAnswers;

  @HiveField(5)
  String category;

  WordStatistics({
    required this.wordId,
    this.totalAttempts = 0,
    this.correctAnswers = 0,
    required this.lastAttempt,
    this.consecutiveCorrectAnswers = 0,
    required this.category, // Добавляем категорию
  });

  double get successRate => 
    totalAttempts > 0 ? correctAnswers / totalAttempts : 0;

  Map<String, dynamic> toJson() => {
    'wordId': wordId,
    'totalAttempts': totalAttempts,
    'correctAnswers': correctAnswers,
    'lastAttempt': lastAttempt.toIso8601String(),
    'consecutiveCorrectAnswers': consecutiveCorrectAnswers,
  };

  static WordStatistics fromJson(Map<String, dynamic> json) => WordStatistics(
    wordId: json['wordId'],
    totalAttempts: json['totalAttempts'],
    correctAnswers: json['correctAnswers'],
    lastAttempt: DateTime.parse(json['lastAttempt']),
    consecutiveCorrectAnswers: json['consecutiveCorrectAnswers'],
    category: json['category'],
  );
}