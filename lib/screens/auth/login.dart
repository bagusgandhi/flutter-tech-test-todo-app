import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/screens/todos/list.dart';

import 'package:todo_app/widgets/notif.dart';
import 'package:todo_app/config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 200.0),
                child: Center(
                  child: Container(
                      width: 200,
                      height: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0)),
                      child: Image.asset('lib/assets/logo-nadi.png')),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                      hintText: 'Enter your email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }

                    // Additional custom validation, checking if it's a valid email
                    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                        .hasMatch(value)) {
                      return 'Enter a valid email address';
                    }

                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Enter secure password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }

                    return null;
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                  height: 50,
                  width: 250,
                  child: ElevatedButton(
                    onPressed: submitLogin,
                    child: const Text('Login'),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submitLogin() async {
    if (_formKey.currentState!.validate()) {
      final String email = _usernameController.text;
      final String password = _passwordController.text;
      final String combinedHash = _combineHash(email, password);

      final endpoint = Uri.parse('${AppConfig.apiUrl}/auth?hash=$combinedHash');

      final response = await http
          .get(endpoint, headers: {'Content-Type': 'application/json'});

      // admin@nadi.co.id
      // password
      // e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855

      if (response.statusCode == 200) {
        NotifWidget.show(context, 'Login Successfully', false);

        final route = MaterialPageRoute(
          builder: (context) => const ListPage(),
        );
        // ignore: use_build_context_synchronously
        await Navigator.push(context, route);
        // ignore: use_build_context_synchronously
      } else {
        // ignore: use_build_context_synchronously
        NotifWidget.show(context, 'Login Failed', true);
      }
    }
  }

  String _combineHash(String email, String password) {
    final String combinedString = '$email$password';
    final String combinedHash =
        sha256.convert(utf8.encode(combinedString)).toString();
    return combinedHash;
  }
}
