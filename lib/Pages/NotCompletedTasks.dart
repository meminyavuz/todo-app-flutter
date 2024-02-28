import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotCompletedTasksPage extends StatefulWidget {
  @override
  _NotCompletedTasksPageState createState() => _NotCompletedTasksPageState();
}

class _NotCompletedTasksPageState extends State<NotCompletedTasksPage> {
  List<dynamic> notCompletedTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotCompletedTasks();
  }

  Future<void> fetchNotCompletedTasks() async {
    const url = 'http://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final List<dynamic> result = json["items"] as List;

      setState(() {
        notCompletedTasks = result.where((task) => !task["is_completed"]).toList();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Not Completed Tasks'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: notCompletedTasks.length,
        itemBuilder: (BuildContext context, int index) {
          final task = notCompletedTasks[index];
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

