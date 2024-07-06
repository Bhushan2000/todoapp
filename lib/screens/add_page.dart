import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;

  const AddTodoPage({super.key, this.todo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final title = todo["title"];
      final description = todo["description"];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Todo" : "Add Todo"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Title',
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: 'Description',
            ),
            minLines: 5,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: isEdit ? updateData : submitData,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(isEdit ? "Update" : "Submit"),
            ),
          )
        ],
      ),
    );
  }

  Future<void> updateData() async {
    // form handling
    // get data from form
    final todo = widget.todo;
    if (todo == null) {
      print("You can not call updateData without todo data");
    }
    final id = todo!["_id"];
    //final isCompleted = todo["is_completed"];
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    // update the data to server
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final respose = await http.put(uri,
        body: jsonEncode(body), headers: {"Content-Type": "application/json"});
    // show success or fail message according to the response
    if (respose.statusCode == 200) {
      showSuccessMessage("Todo updated successfully");
    } else {
      showFailureMessage("Failed to update todo");
    }
  }

  Future<void> submitData() async {
    // form handling
    // get data from form
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": true,
    };
    // submit the data to server
    final url = "https://api.nstack.in/v1/todos";
    final uri = Uri.parse(url);
    final respose = await http.post(uri,
        body: jsonEncode(body), headers: {"Content-Type": "application/json"});
    // show success or fail message according to the response
    if (respose.statusCode == 201) {
      titleController.text = '';
      descriptionController.text = '';
      showSuccessMessage("Todo added successfully");
    } else {
      showFailureMessage("Failed to add todo");
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showFailureMessage(String message) {
    final snackBar = SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
