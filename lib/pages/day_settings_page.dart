import 'package:archify/components/my_button.dart';
import 'package:archify/components/my_text_field.dart';
import 'package:archify/components/my_text_field_form.dart';
import 'package:archify/helpers/navigate_pages.dart';
import 'package:archify/services/database/day/day_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DaySettingsPage extends StatefulWidget {
  const DaySettingsPage({super.key});

  @override
  State<DaySettingsPage> createState() => _DaySettingsPageState();
}

class _DaySettingsPageState extends State<DaySettingsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final DayProvider _dayProvider;
  late final TextEditingController _dayNameController;
  late final TextEditingController _dayDescriptionController;
  late final TextEditingController _maxParticipantsController;
  late final TextEditingController _codeController;
  late TimeOfDay _votingDeadline;
  late final FocusNode _dayNameFocusNode;
  late final FocusNode _dayDescriptionFocusNode;
  late final FocusNode _maxParticipantsFocusNode;
  late final FocusNode _pickVotingDeadlineFocusNode;
  late final String _fillUpFormMessage;

  @override
  initState() {
    super.initState();
    _dayProvider = Provider.of<DayProvider>(context, listen: false);
    _dayNameController = TextEditingController();
    _dayDescriptionController = TextEditingController();
    _maxParticipantsController = TextEditingController();
    _codeController = TextEditingController();
    _dayNameFocusNode = FocusNode();
    _dayDescriptionFocusNode = FocusNode();
    _maxParticipantsFocusNode = FocusNode();
    _pickVotingDeadlineFocusNode = FocusNode();
    _votingDeadline = TimeOfDay.now();
    _fillUpFormMessage = 'Please Fill Up The Form';
  }

  Future<void> pickTime() async {
    final now = TimeOfDay.fromDateTime(DateTime.now());
    final endOfDay = const TimeOfDay(hour: 23, minute: 59);

    final pickedTime = await showTimePicker(
      confirmText: 'Select',
      context: context,
      initialTime: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6F61),
              onPrimary: Colors.white,
              onSurface: Color(0xFF333333),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    //submission key
    // void _submitForm() async {
    //   if (!_formKey.currentState!.validate()) return;
    // }

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
      const SnackBar(
        content: Text('Please pick a time from now until 11:59 PM.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> createDay() async {
    if (!_formKey.currentState!.validate()) return;
    final dayName = _dayNameController.text;
    final dayDescription = _dayDescriptionController.text;
    final maxParticipants = int.tryParse(_maxParticipantsController.text);

    if (dayName.isEmpty || dayDescription.isEmpty || maxParticipants == null) {
      return;
    }

    final dayId = await _dayProvider.createDay(
      name: dayName,
      description: dayDescription,
      maxParticipants: maxParticipants,
      votingDeadline: _votingDeadline,
    );

    goDayCode(context, dayId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFD9D9D9), width: 1.0),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.centerLeft,
          child: const SafeArea(
            child: Text(
              "Create a Day",
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFFF6F61),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.sunny,
                      color: Color(0xFFFF6F61),
                      size: 30.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Ready for the Challenge?",
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                      color: Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          MyTextFormField(
                            controller: _dayNameController,
                            hintText: 'Day',
                            obscureText: false,
                            focusNode: _dayNameFocusNode,
                            onSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_dayDescriptionFocusNode);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter a day name";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          MyTextFormField(
                            controller: _dayDescriptionController,
                            hintText: 'Day Description',
                            obscureText: false,
                            focusNode: _dayDescriptionFocusNode,
                            onSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_maxParticipantsFocusNode);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please a day description";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          MyTextFormField(
                            controller: _maxParticipantsController,
                            hintText: 'Max Participants',
                            obscureText: false,
                            focusNode: _maxParticipantsFocusNode,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[0-9]*$'))
                            ],
                            onSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_pickVotingDeadlineFocusNode);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter max number of participants";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            focusNode: _pickVotingDeadlineFocusNode,
                            onPressed: pickTime,
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                  const Color(0xFFFAF1E1)),
                              padding: WidgetStatePropertyAll(
                                const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                              ),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                              ),
                              elevation: WidgetStatePropertyAll(0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Pick Voting Deadline',
                                  style: TextStyle(
                                    color: Color(0xFFC8C1B4),
                                    fontFamily: 'Sora',
                                    fontSize: 18,
                                  ),
                                ),
                                const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFFC8C1B4),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border:
                                Border.all(color: Color(0xFFFF6F61), width: 1),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFFFF6F61),
                            ),
                          ),
                        ),
                      ),

                      // Add spacing between buttons
                      SizedBox(
                        width: 24,
                      ),

                      GestureDetector(
                        onTap: createDay,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (PointerEvent details) =>
                              setState(() => amIHovering = true),
                          onExit: (PointerEvent details) {
                            setState(() {
                              amIHovering = false;

                              exitFrom = details.localPosition;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: amIHovering
                                  ? Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                  : Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: Center(
                              child: Text(
                                'Create Day',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Sora',
                                    fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
