import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final FocusNode focusNode;
  final ValueChanged<String>? onSubmitted;
  final Color? fillColor;
  final Color? focusColor;
  final ValueChanged<String>? onChanged;
  final TextInputType? inputType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final InputDecoration? decoration;

  const MyTextFormField({
    this.onChanged,
    this.fillColor,
    this.focusColor,
    this.validator,
    this.decoration,
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.focusNode,
    this.onSubmitted,
    this.inputType,
    this.inputFormatters,
  });

  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
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
    final fillColor =
        widget.fillColor ?? Theme.of(context).colorScheme.tertiary;
    final focusColor =
        widget.focusColor ?? Theme.of(context).colorScheme.secondaryFixedDim;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: focusNotifier,
        builder: (context, hasFocus, child) {
          final defaultDecoration = InputDecoration(
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
              //fontSize: 18,
            ),
            contentPadding: const EdgeInsets.only(left: 30),
          );

          return TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            focusNode: widget.focusNode,
            keyboardType: widget.inputType ?? TextInputType.text,
            onFieldSubmitted: widget.onSubmitted,
            onChanged: widget.onChanged,
            validator: widget.validator,
            inputFormatters: widget.inputFormatters,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontFamily: 'Sora',
              //fontSize: 18,
            ),
            decoration: widget.decoration?.copyWith(
                  fillColor: hasFocus
                      ? widget.decoration?.fillColor ?? focusColor
                      : widget.decoration?.fillColor ?? fillColor,
                ) ??
                defaultDecoration,
          );
        },
      ),
    );
  }
}
