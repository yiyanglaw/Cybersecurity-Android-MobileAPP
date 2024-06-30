import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordStrengthHistoryPage extends StatefulWidget {
  @override
  _PasswordStrengthHistoryPageState createState() => _PasswordStrengthHistoryPageState();
}

class _PasswordStrengthHistoryPageState extends State<PasswordStrengthHistoryPage> {
  List<dynamic> _predictionHistory = [];

  Future<void> _fetchPredictionHistory() async {
    final endpoint = 'https://flask-password.onrender.com/password_strength/history';

    final response = await http.get(Uri.parse(endpoint));

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
  void initState() {
    super.initState();
    _fetchPredictionHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Strength History'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background11.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          _predictionHistory.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
            itemCount: _predictionHistory.length,
            itemBuilder: (context, index) {
              final prediction = _predictionHistory[index];
              return ListTile(
                title: Text(
                  '${prediction['password']} - ${prediction['strength']}',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${prediction['created_at']}',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}