import 'package:archify/components/my_button.dart';
import 'package:archify/components/my_text_field.dart';
import 'package:archify/helpers/navigate_pages.dart';
import 'package:archify/services/database/day/day_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  late final DayProvider _dayProvider;
  late final TextEditingController _codeController;
  late final FocusNode _codeFocusNode;

  @override
  void initState() {
    super.initState();

    _dayProvider = Provider.of<DayProvider>(context, listen: false);
    _codeController = TextEditingController();
    _codeFocusNode = FocusNode();
  }

  Future<void> joinDay() async {
    if (_codeController.text.isEmpty) return;
    final dayExists =
        await _dayProvider.isDayExistingAndActive(_codeController.text);

    if (!mounted) return;

    if (!dayExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Day does not exist or already finished')),
      );
      return;
    }

    goDaySpace(context, _codeController.text);
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
              MyButton(text: 'Join Day', onTap: joinDay),
            ],
          ),
        ),
      ),
    );
  }
}
