import 'package:archify/components/my_button.dart';
import 'package:archify/components/my_text_field.dart';
import 'package:archify/services/database/day/day_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DaySettingsPage extends StatefulWidget {
  const DaySettingsPage({super.key});

  @override
  State<DaySettingsPage> createState() => _DaySettingsPageState();
}

class _DaySettingsPageState extends State<DaySettingsPage> {
  late final DayProvider _dayProvider;

  late final TextEditingController _dayNameController;
  late final TextEditingController _dayDescriptionController;
  late final TextEditingController _maxParticipantsController;
  late TimeOfDay _votingDeadline;
  late final FocusNode _dayNameFocusNode;
  late final FocusNode _dayDescriptionFocusNode;
  late final FocusNode _maxParticipantsFocusNode;

  @override
  initState() {
    super.initState();
    _dayProvider = Provider.of<DayProvider>(context, listen: false);
    _dayNameController = TextEditingController();
    _dayDescriptionController = TextEditingController();
    _maxParticipantsController = TextEditingController();
    _dayNameFocusNode = FocusNode();
    _dayDescriptionFocusNode = FocusNode();
    _maxParticipantsFocusNode = FocusNode();
    _votingDeadline = TimeOfDay.now();
  }

  Future<void> pickTime() async {
    final now = TimeOfDay.fromDateTime(DateTime.now().add(Duration(hours: 8)));
    print(now);
    final endOfDay = const TimeOfDay(hour: 23, minute: 59);

    final pickedTime = await showTimePicker(
      confirmText: 'Select',
      context: context,
      initialTime: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            dialogBackgroundColor: Colors.white, // background color
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      if (pickedTime.hour < now.hour ||
          (pickedTime.hour == now.hour && pickedTime.minute < now.minute)) {
        _showInvalidTimeError();
        return;
      }

      setState(() {
        _votingDeadline = pickedTime;
      });
    }
  }

  void _showInvalidTimeError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please pick a time from now until 11:59 PM.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> createDay() async {
    final dayName = _dayNameController.text;
    final dayDescription = _dayDescriptionController.text;
    final maxParticipants = int.tryParse(_maxParticipantsController.text);

    if (dayName.isEmpty || dayDescription.isEmpty || maxParticipants == null) {
      //_showInvalidInputError();
      return;
    }

    await _dayProvider.createDay(
      name: dayName,
      description: dayDescription,
      maxParticipants: maxParticipants,
      votingDeadline: _votingDeadline,
    );
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
            ElevatedButton(
              onPressed: pickTime,
              child: const Text('Pick Voting Deadline'),
            ),
            MyButton(
              onTap: createDay,
              text: 'Create Day',
            ),
          ],
        ),
      ),
    );
  }
}
