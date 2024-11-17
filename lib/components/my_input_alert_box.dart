import 'package:archify/components/my_button.dart';
import 'package:archify/components/my_text_field.dart';
import 'package:flutter/material.dart';

class MyInputAlertBox extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController textController;
  final String hintText;
  final void Function()? onConfirmPressed;
  final String confirmButtonText;

  const MyInputAlertBox({
    super.key,
    required this.textController,
    required this.hintText,
    required this.onConfirmPressed,
    required this.confirmButtonText,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      content: MyTextField(
        controller: textController,
        hintText: hintText,
        obscureText: false,
        focusNode: focusNode,
      ),
      actions: [
        MyButton(
          onTap: () {
            textController.clear();
            Navigator.pop(context);
          },
          text: 'cancel(change dis)',
        ),
        MyButton(
          onTap: () {
            onConfirmPressed!();
            Navigator.pop(context);
            textController.clear();
          },
          text: confirmButtonText,
        ),
      ],
    );
  }
}
