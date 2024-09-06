// lib/main.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'number_to_english.dart';
import 'number_to_gujarati.dart';
import 'number_to_hindi.dart'; // Import the Hindi conversion logic

void main() {
  runApp(NumberToWordsApp());
}

class NumberToWordsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Numbers to Words Converter',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.purple,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => NumberToWordsScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png', // Replace with your logo path
              width:
                  MediaQuery.of(context).size.width * 0.5, // Adjust logo size
              height:
                  MediaQuery.of(context).size.height * 0.3, // Adjust logo size
            ),
            SizedBox(height: 20),
            Text(
              'Numbers to Words Converter',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width *
                    0.06, // Adjust text size
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            _selectedLanguage == 'English'
                ? 'Error'
                : _selectedLanguage == 'Gujarati'
                    ? 'ભૂલ'
                    : 'त्रुटि',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                _selectedLanguage == 'English'
                    ? 'OK'
                    : _selectedLanguage == 'Gujarati'
                        ? 'ઠીક છે'
                        : 'ठीक है',
              ),
            ),
          ],
        );
      },
    );
  }

  void _convertToWords() {
    setState(() {
      int? number = int.tryParse(_controller.text);
      if (number != null) {
        if (_selectedLanguage == 'English') {
          _output = numberToEnglishWords(number);
        } else if (_selectedLanguage == 'Gujarati') {
          _output = numberToGujaratiWords(number);
        } else if (_selectedLanguage == 'Hindi') {
          _output = numberToHindiWords(number);
        }
      } else {
        String errorMessage = _selectedLanguage == 'English'
            ? 'Please enter a valid number'
            : _selectedLanguage == 'Gujarati'
                ? 'કૃપા કરીને યોગ્ય નંબર દાખલ કરો'
                : 'कृपया एक मान्य संख्या दर्ज करें';
        _showErrorDialog(errorMessage);
        _output = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedLanguage == 'English'
              ? 'Number to Words Converter'
              : _selectedLanguage == 'Gujarati'
                  ? 'નંબર થી શબ્દ માં રૂપાંતરક'
                  : 'संख्या से शब्द कन्वर्टर',
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedLanguage = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return ['English', 'Gujarati', 'Hindi'].map((String language) {
                return PopupMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  Icon(Icons.language),
                  SizedBox(width: 6),
                  Text(_selectedLanguage),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              style: TextStyle(
                fontSize: 20,
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _selectedLanguage == 'English'
                    ? 'Enter a number'
                    : _selectedLanguage == 'Gujarati'
                        ? 'નંબર દાખલ કરો'
                        : 'संख्या दर्ज करें',
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _convertToWords,
              child: Text(
                _selectedLanguage == 'English'
                    ? 'Convert'
                    : _selectedLanguage == 'Gujarati'
                        ? 'રૂપાંતરિત કરો'
                        : 'कन्वर्ट करें',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _output,
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
