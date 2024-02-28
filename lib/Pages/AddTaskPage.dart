import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTask extends StatefulWidget {
  final Map? task;
  const AddTask({super.key, this.task});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState(){
    super.initState();
    final task = widget.task;
    if(task != null){
      isEdit = true;
      final title = task['title'];
      final description = task['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
           TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: 'Title'),
          ),
           TextField(
             controller: descriptionController,
             decoration: InputDecoration(hintText: 'Description'),
             keyboardType: TextInputType.multiline,
             maxLength: 100,
             minLines: 3,
             maxLines: 3,
          ),
          ElevatedButton(
              onPressed:isEdit ? updateData : submitData,
              child: Text(isEdit ? 'Update' : 'Submit'),
          )
        ],
      ),
    );
  }


  Future<void> updateData() async {
    final task = widget.task;

    if(task == null){
      print("You can not call updated without task data");
      return;
    }

    final id = task['_id'];
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    final url = 'http://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(
      uri,body: jsonEncode(body),
      headers: {'Content-Type' : 'application/json'},
    );
    if(response.statusCode == 200){
      showSuccsessMessage('Task Successfully Updated');
    }
    else{
      showErrorMessage('Updation Failed');
    }
  }

  Future<void> submitData() async {

    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    const url = 'http://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,body: jsonEncode(body),
      headers: {'Content-Type' : 'application/json'},
    );

    if(response.statusCode == 201){
      titleController.clear();
      descriptionController.clear();
      showSuccsessMessage(isEdit ? 'Task Successfully Updated':'Task Successfully Added!');
    }
    else{
      showErrorMessage('Creation Failed');
    }
  }

  void showSuccsessMessage(String message){
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message){
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
