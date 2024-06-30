import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'spam_history_page.dart';

class SpamClassificationPage extends StatefulWidget {
  @override
  _SpamClassificationPageState createState() => _SpamClassificationPageState();
}

class _SpamClassificationPageState extends State<SpamClassificationPage> {
  final _formKey = GlobalKey<FormState>();
  String _textInput = '';
  String _predictionResult = '';
  String _selectedClassification = 'email';

  Future<void> _predictSpam(String text, String classification) async {
    String url;
    if (classification == 'email') {
      url = 'https://flask-spam-email.onrender.com/email/predict_spam';
    } else {
      url = 'https://flask-spam-sms.onrender.com/sms/predict_spam';
    }

    final response = await http.post(
      Uri.parse(url),
      body: {'text': text},
    );

    if (response.statusCode == 200) {
      setState(() {
        _predictionResult = response.body;
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  void _showHistorySelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select History Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Email Spam History'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpamHistoryPage(type: 'email'),
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('SMS Spam History'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpamHistoryPage(type: 'sms'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spam Classification'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _showHistorySelector,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background2.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedClassification,
                    hint: Text('Select classification type'),
                    items: [
                      DropdownMenuItem(
                        value: 'email',
                        child: Text('Spam Email'),
                      ),
                      DropdownMenuItem(
                        value: 'sms',
                        child: Text('Spam SMS'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedClassification = value!;
                        _predictionResult = '';
                      });
                    },
                    isExpanded: true,
                    underline: SizedBox(),
                  ),
                ),
                SizedBox(height: 16.0),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: _selectedClassification == 'email'
                          ? 'Enter email text'
                          : 'Enter SMS text',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    maxLines: null,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _textInput = value!;
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _predictSpam(_textInput, _selectedClassification);
                    }
                  },
                  child: Text('Check for Spam'),
                ),
                SizedBox(height: 16.0),
                Text(
                  _predictionResult,
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
