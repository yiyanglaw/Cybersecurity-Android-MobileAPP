import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'spam_call_history_page.dart';

// Define a custom gold color
const Color goldColor = Color(0xFFFFD700);

class SpamCallClassificationPage extends StatefulWidget {
  @override
  _SpamCallClassificationPageState createState() =>
      _SpamCallClassificationPageState();
}

class _SpamCallClassificationPageState
    extends State<SpamCallClassificationPage> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = '';
  String _predictionResult = '';

  Future<void> _predictSpamCall(String phoneNumber) async {
    final endpoint =
        'https://flask-spam-call.onrender.com/spam_call/predict';

    final response = await http.post(
      Uri.parse(endpoint),
      body: {'phone_number': phoneNumber},
    );

    if (response.statusCode == 200) {
      setState(() {
        _predictionResult = response.body;
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spam Call Classification'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SpamCallHistoryPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background7.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: TextFormField(
                    style: TextStyle(color: goldColor),
                    decoration: InputDecoration(
                      labelText: 'Enter Phone Number (Space-separated format):',
                      labelStyle: TextStyle(color: goldColor),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: goldColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: goldColor),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _phoneNumber = value!.replaceAll('-', '');
                    },
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _predictSpamCall(_phoneNumber.replaceAll(RegExp(r'\D'), '-'));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: goldColor,
                    foregroundColor: Colors.black,
                  ),
                  child: Text('Check Phone Number'),
                ),
                SizedBox(height: 16.0),
                Text(
                  _predictionResult,
                  style: TextStyle(fontSize: 18.0, color: goldColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}