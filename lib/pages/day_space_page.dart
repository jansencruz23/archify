import 'package:archify/components/my_input_alert_box.dart';
import 'package:archify/services/database/day/day_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DaySpacePage extends StatefulWidget {
  final String dayCode;

  const DaySpacePage({super.key, required this.dayCode});

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
      _loadDay();
    });
  }

  void _showNicknameInputDialog() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
        textController: _nicknameController,
        hintText: 'Enter Nickname',
        confirmButtonText: 'Enter Day',
        onConfirmPressed: _startDay,
        focusNode: _nicknameFocusNode,
      ),
    );
  }

  Future<void> _loadDay() async {
    await _dayProvider.loadDayByCode(widget.dayCode);
    await _dayProvider.loadMoments(widget.dayCode);
  }

  Future<void> _startDay() async {
    await _dayProvider.startDay(widget.dayCode, _nicknameController.text);
  }

  Future<void> _imageUploadClicked() async {
    await _dayProvider.openImagePicker(
      isCameraSource: false,
      dayCode: widget.dayCode,
    );
  }

  Future<void> _cameraUploadClicked() async {
    await _dayProvider.openImagePicker(
      isCameraSource: true,
      dayCode: widget.dayCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DayProvider>(context);
    final day = listeningProvider.day;
    final moments = listeningProvider.moments;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(day == null ? 'Loading' : day.name),
          bottom: PreferredSize(
            preferredSize: Size.zero,
            child: Text(
                'Deadline: ${day == null ? 'Loading' : day.votingDeadline.toString()}'),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              SingleChildScrollView(
                child: Container(
                  // random numbers
                  // maging grid din pala based sa figma pero shshow ko muna
                  height: MediaQuery.sizeOf(context).height - 200,
                  width: MediaQuery.sizeOf(context).width,
                  child: ListView.builder(
                    itemCount: moments == null ? 0 : moments.length,
                    itemBuilder: (context, index) {
                      final moment = moments![index];

                      return ListTile(
                        title: Text(moment.nickname),
                        leading: Image.network(moment.imageUrl),
                      );
                    },
                  ),
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: _cameraUploadClicked,
                    icon: Icon(Icons.camera_alt_rounded),
                  ),
                  IconButton(
                    onPressed: _imageUploadClicked,
                    icon: Icon(Icons.photo),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
