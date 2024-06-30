import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const Color goldColor = Color(0xFFFFD700);

class SpamHistoryPage extends StatefulWidget {
  final String type;

  SpamHistoryPage({required this.type});

  @override
  _SpamHistoryPageState createState() => _SpamHistoryPageState();
}

class _SpamHistoryPageState extends State<SpamHistoryPage> {
  List<dynamic> _predictionHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchPredictionHistory();
  }

  Future<void> _fetchPredictionHistory() async {
    String url;
    if (widget.type == 'email') {
      url = 'https://flask-spam-email.onrender.com/email/history';
    } else {
      url = 'https://flask-spam-sms.onrender.com/sms/history';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        _predictionHistory = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch prediction history'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.type.toUpperCase()} Spam History'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background3.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: _predictionHistory.isEmpty
            ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(goldColor)))
            : ListView.builder(
          itemCount: _predictionHistory.length,
          itemBuilder: (context, index) {
            final prediction = _predictionHistory[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.black.withOpacity(0.7),
              child: ListTile(
                title: Text(
                  prediction['text'],
                  style: TextStyle(color: goldColor, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${prediction['result']} - ${prediction['created_at']}',
                  style: TextStyle(color: Colors.white70),
                ),
                contentPadding: EdgeInsets.all(16),
              ),
            );
          },
        ),
      ),
    );
  }
}