import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../category.dart';
import '../word_card.dart';
import 'package:file_picker/file_picker.dart';

class BackupService {
  Future<void> exportData(List<Category> categories, List<WordCard> cards) async {
    try {
      // Convert data to JSON
      final Map<String, dynamic> exportData = {
        'categories': categories.map((c) => c.toJson()).toList(),
        'cards': cards.map((c) => c.toJson()).toList(),
      };

      // Convert to JSON string
      final String jsonData = jsonEncode(exportData);
      
      // Convert string to bytes
      final List<int> bytes = utf8.encode(jsonData);

      // Get app directory
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'cardapp_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      
      // Write data to file
      await file.writeAsBytes(bytes);

      // Share the file
      await Share.shareFiles(
        [file.path],
        text: 'CardApp Backup Data',
      );
    } catch (e) {
      print('Error exporting data: $e');
      rethrow;
    }
  }

   Future<Map<String, List>?> importData() async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return null;

      // Read file content
      File file = File(result.files.single.path!);
      String jsonString = await file.readAsString();
      Map<String, dynamic> jsonData = jsonDecode(jsonString);

      // Convert JSON to objects
      List<Category> categories = (jsonData['categories'] as List)
          .map((categoryJson) => Category(
                name: categoryJson['name'],
              ))
          .toList();

      List<WordCard> cards = (jsonData['cards'] as List)
          .map((cardJson) => WordCard(
                german: cardJson['german'],
                russian: cardJson['russian'],
                category: cardJson['category'],
                isFavorite: cardJson['isFavorite'] ?? false,
                isFlipped: cardJson['isFlipped'] ?? false,
              ))
          .toList();

      return {
        'categories': categories,
        'cards': cards,
      };
    } catch (e) {
      print('Error importing data: $e');
      return null;
    }
  }
}