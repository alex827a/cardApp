/* import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateCardScreen extends StatefulWidget {
  @override
  _CreateCardScreenState createState() => _CreateCardScreenState();
}


class _CreateCardScreenState extends State<CreateCardScreen> {
  final _formKey = GlobalKey<FormState>();
  String _germanWord = '';
  String _russianWord = '';

  void _saveCard() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
    final prefs = await SharedPreferences.getInstance();
    final cards = prefs.getStringList('cards') ?? [];
    cards.add('$_germanWord:$_russianWord');
    await prefs.setStringList('cards', cards);
    Navigator.pop(context);  // Возвращаемся назад после сохранения
  }
}

void _loadCards() async {
  final prefs = await SharedPreferences.getInstance();
  final cards = prefs.getStringList('cards') ?? [];
  // Преобразуйте строку обратно в объекты WordCard, если нужно
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Создать новую карточку'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Немецкое слово'),
              onSaved: (value) => _germanWord = value!,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите немецкое слово';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Перевод на русский'),
              onSaved: (value) => _russianWord = value!,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Пожалуйста, введите перевод';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: _saveCard,
              child: Text('Сохранить карточку'),
            ),
          ],
        ),
      ),
    );
  }
}

 */