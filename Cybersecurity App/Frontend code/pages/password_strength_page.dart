import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'password_strength_history_page.dart';

class PasswordStrengthPage extends StatefulWidget {
  @override
  _PasswordStrengthPageState createState() => _PasswordStrengthPageState();
}

class _PasswordStrengthPageState extends State<PasswordStrengthPage> {
  TextEditingController _passwordController = TextEditingController();
  String _prediction = '';

  Future<void> _predictStrength(String password) async {
    final response = await http.post(
      Uri.parse('https://flask-password.onrender.com/predict'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'password': password}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _prediction = jsonDecode(response.body)['strength'];
      });
    } else {
      throw Exception('Failed to load prediction');
    }
  }

  Color _getStrengthColor(String strength) {
    switch (strength) {
      case 'Weak':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Strong':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Strength Checker'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PasswordStrengthHistoryPage()),
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
                image: AssetImage('assets/background1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Enter Password',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      _predictStrength(_passwordController.text);
                    },
                    child: Text('Check Strength'),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    _prediction.isNotEmpty
                        ? 'Strength: $_prediction'
                        : 'Enter a password to check its strength',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: _getStrengthColor(_prediction),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}