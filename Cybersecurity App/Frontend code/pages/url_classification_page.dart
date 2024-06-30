import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UrlClassificationPage extends StatefulWidget {
  @override
  _UrlClassificationPageState createState() => _UrlClassificationPageState();
}

class _UrlClassificationPageState extends State<UrlClassificationPage> {
  final _formKey = GlobalKey<FormState>();
  String _urlInput = '';
  String _predictionResult = '';
  String _selectedClassification = 'malicious';

  Future<void> _predictUrl(String url, String classification) async {
    String apiUrl;
    if (classification == 'malicious') {
      apiUrl = 'https://flask-mal-url.onrender.com/malicious/predict_url';
    } else if (classification == 'phishing') {
      apiUrl = 'https://flask-phi-url.onrender.com/phishing/predict_url';
    } else {
      apiUrl = 'https://flask-illicit-url.onrender.com/illicit_video/predict_url';
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {'url': url},
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
                title: Text('Malicious URL History'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/url_history', arguments: 'malicious');
                },
              ),
              ListTile(
                title: Text('Phishing URL History'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/url_history', arguments: 'phishing');
                },
              ),
              ListTile(
                title: Text('Illicit Video URL History'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/url_history', arguments: 'illicit_video');
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
        title: Text('URL Classification'),
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
                image: AssetImage('assets/background4.jpg'),
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
                        value: 'malicious',
                        child: Text('Malicious URL'),
                      ),
                      DropdownMenuItem(
                        value: 'phishing',
                        child: Text('Phishing URL'),
                      ),
                      DropdownMenuItem(
                        value: 'illicit_video',
                        child: Text('Illicit Video URL'),
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
                      labelText: 'Enter URL',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a URL';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _urlInput = value!;
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _predictUrl(_urlInput, _selectedClassification);
                    }
                  },
                  child: Text('Check URL'),
                ),
                SizedBox(height: 16.0),
                Text(
                  _predictionResult,
                  style: TextStyle(fontSize: 18.0,color:Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
