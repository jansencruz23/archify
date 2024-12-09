import 'package:archify/helpers/font_helper.dart';
import 'package:flutter/material.dart';

showErrorDialog(BuildContext context, String title) {
  // Change alert dialog to a custom one
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Sora',
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 3.0,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
