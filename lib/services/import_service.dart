import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../word_card.dart';

class ImportService {
  // Конструктор без параметров
  ImportService();

  Future<String?> pickAndReadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'csv'],
      );

      if (result != null) {
        if (kIsWeb) {
          // Web platform
          final bytes = result.files.first.bytes;
          if (bytes == null) return null;
          return String.fromCharCodes(bytes);
        } else {
          // Mobile/Desktop
          final path = result.files.first.path;
          if (path == null) return null;
          File file = File(path);
          return await file.readAsString();
        }
      }
      return null;
    } catch (e) {
      print('Error picking file: $e');
      return null;
    }
  }

  Future<List<WordCard>> parseWordsFromText(
      String text, String categoryName, bool isFlipped) {
    List<WordCard> newCards = [];
    
    List<String> lines = text.split(';');
    for (String line in lines) {
      if (line.trim().isEmpty) continue;
      
      List<String> parts = line.split(':');
      if (parts.length != 2) {
        continue;
      }

      String foreignWord = parts[0].trim();
      String nativeWord = parts[1].trim();

      newCards.add(WordCard(
        german: foreignWord,
        russian: nativeWord,
        category: categoryName,
        isFavorite: false,
        isFlipped: isFlipped,
      ));
    }
    
    return Future.value(newCards);
  }
}