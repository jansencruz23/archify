import 'package:flutter/material.dart';

showErrorDialog(BuildContext context, String title) {
  // Change alert dialog to a custom one
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
    ),
  );
}
