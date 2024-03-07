import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:todo_app/models/todo.dart';

import 'package:todo_app/widgets/notif.dart';
import 'package:todo_app/config.dart';

class AddPage extends StatefulWidget {
  final Map? todo;

  const AddPage({super.key, this.todo});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;

    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Todo' : 'Add New Todo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Title',
                  hintText: 'Insert Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Title must be filled!';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Description',
                  hintText: 'Insert Description'),
              keyboardType: TextInputType.multiline,
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: isEdit ? editTodo : submitTodo,
                child: Text(isEdit ? 'Update' : 'Submit'))
          ],
        ),
      ),
    );
  }

  Future<void> editTodo() async {
    if (_formKey.currentState!.validate()) {
      final todo = widget.todo;
      if (todo != null) {
        final id = todo['id'];
        final title = titleController.text;
        final description = descriptionController.text;

        final updatedTodo =
            Todo(title: title, description: description, completed: false);

        final endpoint = Uri.parse('${AppConfig.apiUrl}/todo/$id');

        final response = await http.put(endpoint,
            body: jsonEncode(updatedTodo),
            headers: {'Content-Type': 'application/json'});

        if (response.statusCode == 200) {
          // ignore: use_build_context_synchronously
          NotifWidget.show(context, 'Todo Has been updated!', false);
        } else {
          // ignore: use_build_context_synchronously
          NotifWidget.show(context, 'Something went wrong', true);
        }
      }
    }
  }

  Future<void> submitTodo() async {
    if (_formKey.currentState!.validate()) {
      final title = titleController.text;
      final description = descriptionController.text;

      final todo =
          Todo(title: title, description: description, completed: false);

      final endpoint = Uri.parse('${AppConfig.apiUrl}/todo');

      final response = await http.post(endpoint,
          body: jsonEncode(todo),
          headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 201) {
        // ignore: use_build_context_synchronously
        NotifWidget.show(context, 'Todo Has been created!', false);

        titleController.clear();
        descriptionController.clear();
      } else {
        // ignore: use_build_context_synchronously
        NotifWidget.show(context, 'Something went wrong', true);
      }
    }
  }
}
