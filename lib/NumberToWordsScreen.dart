import 'package:flutter/material.dart';
import 'package:num_to_words_converter/number_to_english.dart';
import 'package:num_to_words_converter/number_to_gujarati.dart';
import 'package:num_to_words_converter/number_to_hindi.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class NumberToWordsScreen extends StatefulWidget {
  @override
  _NumberToWordsScreenState createState() => _NumberToWordsScreenState();
}

class _NumberToWordsScreenState extends State<NumberToWordsScreen> {
  final TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _output = '';
  String _spokenText = '';
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

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

  Future<void> _startListening() async {
    if (!_isListening && await _speech.initialize()) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _spokenText = result.recognizedWords;
          _controller.text = _spokenText;
          _convertToWords();
        });
      });
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: Scaffold(
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
        body: SingleChildScrollView(
          child: Padding(
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
                  onChanged: (value) {
                    _convertToWords();
                  },
                ),
                SizedBox(height: 30),
                // ElevatedButton(
                //   onPressed: _convertToWords,
                //   child: Text(
                //     _selectedLanguage == 'English'
                //         ? 'Convert'
                //         : _selectedLanguage == 'Gujarati'
                //             ? 'રૂપાંતરિત કરો'
                //             : 'कन्वर्ट करें',
                //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                //   ),
                // ),
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
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _startListening,
          child: Icon(_isListening ? Icons.mic_off : Icons.mic),
        ),
      ),
    );
  }
}
