import 'package:flutter/material.dart';



class MyCommentTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final FocusNode focusNode;
  final ValueChanged<String>? onSubmitted;
  final Color? fillColor;
  final Color? focusColor;
  final ValueChanged<String>? onChanged;

  const MyCommentTextField({
    this.onChanged,
    this.fillColor,
    this.focusColor,
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.focusNode,
    this.onSubmitted,
  });

  @override
  State<MyCommentTextField> createState() => _MyCommentTextFieldState();
}

class _MyCommentTextFieldState extends State<MyCommentTextField> {
  final ValueNotifier<bool> focusNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    focusNotifier.dispose();

    super.dispose();
  }

  void _onFocusChange() {
    focusNotifier.value = widget.focusNode.hasFocus;
  }

  @override
  Widget build(BuildContext context) {
    //Focus color ng textfield pag typing
    final fillColor =
        widget.fillColor ?? Theme.of(context).colorScheme.surface;
    //ano magandang color pag typings??
    final focusColor =
        widget.focusColor ?? Theme.of(context).colorScheme.tertiaryContainer;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30), // This controls the corner roundness
// The fill color inside the box
        border: Border.all(
          color: Theme.of(context).colorScheme.inversePrimary,  // Set the border color
          width: 1, // Increase this value to make the border thicker
        ),
      ),

      child: ValueListenableBuilder<bool>(
        valueListenable: focusNotifier,
        builder: (context, hasFocus, child) {
          return TextField(
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontFamily: 'Sora',
              fontSize: 18,
            ),
            controller: widget.controller,
            obscureText: widget.obscureText,
            focusNode: widget.focusNode,
            onSubmitted: widget.onSubmitted,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: const BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
                borderRadius: BorderRadius.circular(30.0),
              ),
              fillColor: hasFocus ? focusColor : fillColor,
              filled: true,
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontFamily: 'Sora',
                fontSize: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}
