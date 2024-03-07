import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/screens/todos/add.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/widgets/notif.dart';
import 'package:todo_app/config.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  bool isLoading = true;
  List items = <Todo>[];

  @override
  void initState() {
    super.initState();
    fetchTodoData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchTodoData,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(item['title']),
                  subtitle: Text(item['description']),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        navigateToEditPage(item);
                      } else if (value == 'delete') {
                        deleteTodoId(item['id']);
                      }
                    },
                    itemBuilder: (context) {
                      return [
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
              }),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: const Text('Add Todo Data'),
      ),
    );
  }

  Future<void> navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodoData();
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => const AddPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodoData();
  }

  Future<void> deleteTodoId(String id) async {
    final endpoint = Uri.parse('${AppConfig.apiUrl}/todo/$id');

    final response = await http.delete(endpoint);

    if (response.statusCode == 200) {
      final filtered = items.where((element) => element['id'] != id).toList();
      setState(() {
        items = filtered;
      });

      // ignore: use_build_context_synchronously
      NotifWidget.show(context, 'Todo succesfull deleted!', false);
    } else {
      // ignore: use_build_context_synchronously
      NotifWidget.show(context, 'Failed Delete Todo', true);
    }
  }

  Future<void> fetchTodoData() async {
    final endpoint = Uri.parse('${AppConfig.apiUrl}/todo');

    final response = await http.get(endpoint);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List;
      setState(() {
        items = json;
      });
    }

    setState(() {
      isLoading = false;
    });
  }
}
