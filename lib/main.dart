// lib/main.dart
import 'package:flutter/material.dart';
import 'number_to_english.dart';
import 'number_to_gujarati.dart';

void main() {
  runApp(NumberToWordsApp());
}

class NumberToWordsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number to Words Converter',
      home: NumberToWordsScreen(),
    );
  }
}

class NumberToWordsScreen extends StatefulWidget {
  @override
  _NumberToWordsScreenState createState() => _NumberToWordsScreenState();
}

class _NumberToWordsScreenState extends State<NumberToWordsScreen> {
  final TextEditingController _controller = TextEditingController();
  String _output = '';
  String _selectedLanguage = 'English';

  void _convertToWords() {
    setState(() {
      int? number = int.tryParse(_controller.text);
      if (number != null) {
        if (_selectedLanguage == 'English') {
          _output = numberToEnglishWords(number);
        } else if (_selectedLanguage == 'Gujarati') {
          _output = numberToGujaratiWords(number);
        }
      } else {
        _output = 'Please enter a valid number';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number to Words Converter'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter a number'),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedLanguage,
              items: <String>['English', 'Gujarati'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convertToWords,
              child: Text('Convert'),
            ),
            SizedBox(height: 20),
            Text(
              _output,
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
