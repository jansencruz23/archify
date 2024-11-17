import 'package:archify/components/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DaySettingsPage extends StatefulWidget {
  const DaySettingsPage({super.key});

  @override
  State<DaySettingsPage> createState() => _DaySettingsPageState();
}

class _DaySettingsPageState extends State<DaySettingsPage> {
  late final TextEditingController _dayNameController;
  late final TextEditingController _dayDescriptionController;
  late final TextEditingController _maxParticipantsController;
  late TimeOfDay _timeOfDay;
  late final FocusNode _dayNameFocusNode;
  late final FocusNode _dayDescriptionFocusNode;
  late final FocusNode _maxParticipantsFocusNode;

  @override
  initState() {
    super.initState();
    _dayNameController = TextEditingController();
    _dayDescriptionController = TextEditingController();
    _maxParticipantsController = TextEditingController();
    _dayNameFocusNode = FocusNode();
    _dayDescriptionFocusNode = FocusNode();
    _maxParticipantsFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyTextField(
              controller: _dayNameController,
              hintText: 'Day',
              obscureText: false,
              focusNode: _dayNameFocusNode,
            ),
            MyTextField(
              controller: _dayDescriptionController,
              hintText: 'Day Description',
              obscureText: false,
              focusNode: _dayDescriptionFocusNode,
            ),
            MyTextField(
              controller: _maxParticipantsController,
              hintText: 'Max Participants',
              obscureText: false,
              focusNode: _maxParticipantsFocusNode,
              inputType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}
