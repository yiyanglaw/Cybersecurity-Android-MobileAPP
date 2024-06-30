

import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/password_strength_page.dart';
import 'pages/spam_classification_page.dart';
import 'pages/url_classification_page.dart';
import 'pages/malware_detection_page.dart';
import 'pages/spam_call_classification_page.dart';
import 'pages/report_page.dart';
import 'pages/report_list_page.dart';
import 'pages/url_history_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cybersecurity App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/password_strength': (context) => PasswordStrengthPage(),
        '/spam_classification': (context) => SpamClassificationPage(),
        '/url_classification': (context) => UrlClassificationPage(),
        '/malware_detection': (context) => MalwareDetectionPage(),
        '/spam_call_classification': (context) => SpamCallClassificationPage(),
        '/report': (context) => ReportPage(),
        '/report_list': (context) => ReportListPage(
          reportType: ModalRoute.of(context)?.settings.arguments as String,
        ),
        '/url_history': (context) => UrlHistoryPage(
          type: ModalRoute.of(context)?.settings.arguments as String,
        ),
      },
    );
  }
}