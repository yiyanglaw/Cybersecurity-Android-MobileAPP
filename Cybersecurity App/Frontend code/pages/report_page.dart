import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();
  String _spamEmails = '';
  String _spamSms = '';
  String _spamCalls = '';
  String _maliciousUrls = '';
  String _phishingUrls = '';
  String _illicitVideoUrls = '';

  Future<void> _submitReport() async {
    final endpoint = 'https://flask-report.onrender.com/report';

    final response = await http.post(
      Uri.parse(endpoint),
      body: {
        'spam_emails': _spamEmails,
        'spam_sms': _spamSms,
        'spam_calls': _spamCalls,
        'malicious_urls': _maliciousUrls,
        'phishing_urls': _phishingUrls,
        'illicit_video_urls': _illicitVideoUrls,
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report submitted successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report'),
        ),
      );
    }
  }

  void _showReportListDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Report Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Spam Emails'),
                onTap: () {
                  Navigator.pushNamed(context, '/report_list', arguments: 'spam_emails');
                },
              ),
              ListTile(
                title: Text('Spam SMS'),
                onTap: () {
                  Navigator.pushNamed(context, '/report_list', arguments: 'spam_sms');
                },
              ),
              ListTile(
                title: Text('Spam Call Numbers'),
                onTap: () {
                  Navigator.pushNamed(context, '/report_list', arguments: 'spam_calls');
                },
              ),
              ListTile(
                title: Text('Malicious URLs'),
                onTap: () {
                  Navigator.pushNamed(context, '/report_list', arguments: 'malicious_urls');
                },
              ),
              ListTile(
                title: Text('Phishing URLs'),
                onTap: () {
                  Navigator.pushNamed(context, '/report_list', arguments: 'phishing_urls');
                },
              ),
              ListTile(
                title: Text('Illicit Video URLs'),
                onTap: () {
                  Navigator.pushNamed(context, '/report_list', arguments: 'illicit_video_urls');
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
        title: Text('Report and Feedback'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: _showReportListDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background9.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Spam Emails', labelStyle: TextStyle(color: Colors.white)),
                      maxLines: null,
                      style: TextStyle(color: Colors.white),
                      onSaved: (value) {
                        _spamEmails = value ?? '';
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Spam SMS', labelStyle: TextStyle(color: Colors.white)),
                      maxLines: null,
                      style: TextStyle(color: Colors.white),
                      onSaved: (value) {
                        _spamSms = value ?? '';
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Spam Call Numbers', labelStyle: TextStyle(color: Colors.white)),
                      maxLines: null,
                      style: TextStyle(color: Colors.white),
                      onSaved: (value) {
                        _spamCalls = value ?? '';
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Malicious URLs', labelStyle: TextStyle(color: Colors.white)),
                      maxLines: null,
                      style: TextStyle(color: Colors.white),
                      onSaved: (value) {
                        _maliciousUrls = value ?? '';
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Phishing URLs', labelStyle: TextStyle(color: Colors.white)),
                      maxLines: null,
                      style: TextStyle(color: Colors.white),
                      onSaved: (value) {
                        _phishingUrls = value ?? '';
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Illicit Video URLs', labelStyle: TextStyle(color: Colors.white)),
                      maxLines: null,
                      style: TextStyle(color: Colors.white),
                      onSaved: (value) {
                        _illicitVideoUrls = value ?? '';
                      },
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _submitReport();
                        }
                      },
                      child: Text('Submit Report'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
