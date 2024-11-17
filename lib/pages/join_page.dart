import 'package:archify/components/my_button.dart';
import 'package:archify/components/my_text_field.dart';
import 'package:flutter/material.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  late final TextEditingController _codeController;
  late final FocusNode _codeFocusNode;

  @override
  void initState() {
    super.initState();

    _codeController = TextEditingController();
    _codeFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              MyButton(
                onTap: () {},
                text: 'Kunware magandang button',
              ),
              MyTextField(
                controller: _codeController,
                hintText: 'Enter Code',
                obscureText: false,
                focusNode: _codeFocusNode,
              ),
              MyButton(text: 'Join Day', onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
