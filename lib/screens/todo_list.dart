import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:todoapp/screens/add_page.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List items = [];
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List"),
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchData,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(child: Text("No items",style: Theme.of(context).textTheme.titleLarge,),
            ),
            child: ListView.builder(
              itemCount: items.length,
              padding: EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item["_id"] as String;
                return Card(
                  
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text("${index + 1}"),
                    ),
                    title: Text(item["title"]),
                    subtitle: Text(item["description"]),
                    trailing: PopupMenuButton(
                      onSelected: (value) {
                        if (value == "edit") {
                          // open edit page
                          navigateToEditPage(item);
                        } else if (value == "delete") {
                          // delete & refresh the list
                          deleteById(id);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text("Edit"),
                          value: 'edit',
                          onTap: () {},
                        ),
                        PopupMenuItem(
                          child: Text("Delete"),
                          value: 'delete',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: Text("Add note"),
      ),
    );
  }

  Future<void> deleteById(id) async {
    final url = "https://api.nstack.in/v1/todos/$id";
    final uri = Uri.parse(url);
    final respose = await http.delete(uri);
    if (respose.statusCode == 200) {
      // remove the item from the list
      final filtered = items.where((element) => element["_id"] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      showFailureMessage("Failed to delete todo");
    }
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

  Future<void> navigateToAddPage() async{
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(),
    );
   await Navigator.push(context, route);
   setState(() {
     isLoading = true;
   });
   fetchData();
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchData();  }

  Future<void> fetchData() async {
    final url = "https://api.nstack.in/v1/todos?page=1&limit=10";
    final uri = Uri.parse(url);
    final respose =
        await http.get(uri, headers: {"Content-Type": "application/json"});
    if (respose.statusCode == 200) {
      final json = jsonDecode(respose.body) as Map;
      final result = json["items"] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }
}
