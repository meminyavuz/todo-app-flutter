import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CompletedTasksPage extends StatefulWidget {
  @override
  _CompletedTasksPageState createState() => _CompletedTasksPageState();
}

class _CompletedTasksPageState extends State<CompletedTasksPage> {
  List<dynamic> completedTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCompletedTasks();
  }

  Future<void> fetchCompletedTasks() async {
    const url = 'http://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final List<dynamic> result = json["items"] as List;

      setState(() {
        completedTasks = result.where((task) => task["is_completed"]).toList();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Tasks'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: completedTasks.length,
        itemBuilder: (BuildContext context, int index) {
          final task = completedTasks[index];
          return ListTile(
            title: Text(task['title']),
            subtitle: Text(task['description']),
            // Diğer görev bilgilerini buraya ekleyebilirsiniz
          );
        },
      ),
    );
  }
}

