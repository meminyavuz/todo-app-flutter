import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todoapp_flutter/Pages/AddTaskPage.dart';

class Home extends StatefulWidget {
  const Home({Key? key,}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = true;
  List items = [];
  int pendingTasks = 0;
  int totalTasks = 0;
  int completedTasks = 0;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTasks();
    fetchNotCompletedTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Tasks: $totalTasks',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Pending Tasks: $pendingTasks',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                    'Completed Tasks: $completedTasks',
                     style: TextStyle(fontSize: 16),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Pending Tasks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
          ),
          Expanded(
            child: Visibility(
              visible: isLoading,
              replacement: RefreshIndicator(
                onRefresh: fetchNotCompletedTasks,
                child: ListView.builder(
                  itemCount: items.length > 3 ? 3 : items.length,
                  itemBuilder: (context, index) {
                    final item = items[items.length - 1 - index] as Map;
                    String id = item['_id'];
                    return ListTile(
                      title: Text(item['title']),
                      subtitle: Text(item['description']),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if(value == 'done'){
                            updateIsCompleted(id, item['title'], item['description']);
                          }
                          else if (value == 'edit') {
                            navigateToEditPage(item);
                          } else if (value == 'delete') {
                            deleteById(id);
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                              value: 'done',
                              child: Text('Task Done'),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ];
                        },
                      ),
                    );
                  },
                ),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchTasks() async{
    const url = 'http://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if(response.statusCode == 200){
      final json = jsonDecode(response.body) as Map;
      final result = json["items"] as List;

      totalTasks = result.length;
    }
  }

  Future<void> fetchNotCompletedTasks() async {
    const url = 'http://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final List<dynamic> result = json["items"] as List;

      List<dynamic> incompleteTasks = result.where((task) => task["is_completed"] == false).toList();

      setState(() {
        items = incompleteTasks;
        pendingTasks = items.length;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateIsCompleted(String id, String title, String description) async {
    final url = 'http://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);

    final body = {
      "title": title,
      "description": description,
      "is_completed": true,
    };

    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      showSuccessMessage('task updated successfully');
    } else {
     showErrorMessage('task not updated!');
    }
  }

  void deleteById(String id) async {
    final url = 'http://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      final filtered = items = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      showErrorMessage('Deletion Failed!');
    }
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTask(task: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchNotCompletedTasks();
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
