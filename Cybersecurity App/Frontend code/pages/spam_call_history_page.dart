import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Define a custom gold color
const Color goldColor = Color(0xFFFFD700);

class SpamCallHistoryPage extends StatefulWidget {
  @override
  _SpamCallHistoryPageState createState() => _SpamCallHistoryPageState();
}

class _SpamCallHistoryPageState extends State<SpamCallHistoryPage> {
  List<dynamic> _predictionHistory = [];

  Future<void> _fetchPredictionHistory() async {
    final endpoint = 'https://flask-spam-call.onrender.com/spam_call/history';

    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode == 200) {
      setState(() {
        _predictionHistory = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch prediction history', style: TextStyle(color: goldColor)),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPredictionHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Spam Call Prediction History', style: TextStyle(color: goldColor)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: goldColor, // Set the color of the arrow to gold
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background8.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          _predictionHistory.isEmpty
              ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(goldColor)))
              : ListView.builder(
            itemCount: _predictionHistory.length,
            itemBuilder: (context, index) {
              final prediction = _predictionHistory[index];
              return ListTile(
                title: Text(
                  '${prediction['phone_number']} - ${prediction['result']}',
                  style: TextStyle(color: goldColor),
                ),
                subtitle: Text(
                  '${prediction['created_at']}',
                  style: TextStyle(color: goldColor.withOpacity(0.7)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
