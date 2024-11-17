import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final FocusNode focusNode;
  final ValueChanged<String>? onSubmitted;
  final Color? fillColor;
  final Color? focusColor;
  final ValueChanged<String>? onChanged;
  final TextInputType? inputType;

  const MyTextField({
    this.onChanged,
    this.fillColor,
    this.focusColor,
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.focusNode,
    this.onSubmitted,
    this.inputType,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  final ValueNotifier<bool> focusNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    widget.focusNode.dispose();
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
        widget.fillColor ?? Theme.of(context).colorScheme.tertiary;
    //ano magandang color pag typings??
    final focusColor =
        widget.focusColor ?? Theme.of(context).colorScheme.secondaryFixedDim;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Theme.of(context).colorScheme.tertiary,
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: focusNotifier,
          builder: (context, hasFocus, child) {
            return TextField(
              keyboardType: widget.inputType != null
                  ? widget.inputType!
                  : TextInputType.text,
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
                  borderRadius: BorderRadius.circular(25.0),
                ),
                fillColor: hasFocus ? focusColor : fillColor,
                filled: true,
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'Sora',
                  fontSize: 18,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
