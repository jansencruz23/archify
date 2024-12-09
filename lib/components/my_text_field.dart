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
  final bool showToggleIcon;

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
    this.showToggleIcon = false,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  final ValueNotifier<bool> focusNotifier = ValueNotifier<bool>(false);
  bool isObscured = true;

  @override
  void initState() {
    super.initState();
    isObscured = widget.obscureText;
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

  void _toggleObscureText() {
    setState(() {
      isObscured = !isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fillColor =
        widget.fillColor ?? Theme.of(context).colorScheme.tertiary;
    final focusColor =
        widget.focusColor ?? Theme.of(context).colorScheme.secondaryFixedDim;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Theme.of(context).colorScheme.tertiary,
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: focusNotifier,
        builder: (context, hasFocus, child) {
          return TextField(
            keyboardType: widget.inputType ?? TextInputType.text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontFamily: 'Sora',
              fontSize: 18,
            ),
            controller: widget.controller,
            obscureText: isObscured,
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
              contentPadding: const EdgeInsets.only(left: 30),
              suffixIcon: widget.showToggleIcon
                  ? IconButton(
                      icon: Icon(
                        isObscured ? Icons.visibility_off : Icons.visibility,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: _toggleObscureText,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
