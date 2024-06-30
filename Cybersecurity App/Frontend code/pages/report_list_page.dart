import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Define a custom gold color
const Color goldColor = Color(0xFFFFD700);

class ReportListPage extends StatefulWidget {
  final String reportType;

  ReportListPage({required this.reportType});

  @override
  _ReportListPageState createState() => _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  List<dynamic> _reports = [];

  Future<void> _fetchReports() async {
    final endpoint = 'https://flask-report.onrender.com/reports/${widget.reportType}';

    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode == 200) {
      setState(() {
        _reports = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch reports'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report List'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background10.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: _buildReportList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportList() {
    return _reports.isEmpty
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        return ListTile(
          title: Text(
            '${report['created_at']}',
            style: TextStyle(color: goldColor), // Use custom gold color
          ),
          subtitle: Text(
            '${report['value']}',
            style: TextStyle(color: goldColor), // Use custom gold color
          ),
        );
      },
    );
  }
}
