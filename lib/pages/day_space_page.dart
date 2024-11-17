import 'package:archify/components/my_input_alert_box.dart';
import 'package:archify/services/database/day/day_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DaySpacePage extends StatefulWidget {
  final String dayId;

  const DaySpacePage({super.key, required this.dayId});

  @override
  State<DaySpacePage> createState() => _DaySpacePageState();
}

class _DaySpacePageState extends State<DaySpacePage> {
  late final TextEditingController _nicknameController;
  late final FocusNode _nicknameFocusNode;
  late final DayProvider _dayProvider;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _nicknameFocusNode = FocusNode();
    _dayProvider = Provider.of<DayProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showNicknameInputDialog();
    });
  }

  void _showNicknameInputDialog() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
        textController: _nicknameController,
        hintText: 'Enter Nickname',
        confirmButtonText: 'Enter Day',
        onConfirmPressed: startDay,
        focusNode: _nicknameFocusNode,
      ),
    );
  }

  Future<void> startDay() async {
    await _dayProvider.startDay(widget.dayId, _nicknameController.text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(body: Center(child: Text('Day Space'))));
  }
}
