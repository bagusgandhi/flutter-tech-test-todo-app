import 'package:flutter/material.dart';

class NotifWidget {
  static void show(BuildContext context, String message, bool error) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: error ? Colors.red : Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}