import 'package:archify/components/my_input_alert_box.dart';
import 'package:archify/components/my_moment_tile.dart';
import 'package:archify/helpers/navigate_pages.dart';
import 'package:archify/models/day.dart';
import 'package:archify/models/moment.dart';
import 'package:archify/pages/no_moment_uploaded_page.dart';
import 'package:archify/services/database/day/day_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:ui' as ui;

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
  late Day? day;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _nicknameFocusNode = FocusNode();
    _dayProvider = Provider.of<DayProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isParticipant().then((isParticipant) {
        if (!isParticipant) _showNicknameInputDialog();
      });
      _loadDay();
    });
  }

  Future<bool> _isParticipant() async {
    return await _dayProvider.isParticipant(widget.dayCode);
  }

  void _showImageDialog(Moment moment, int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: IntrinsicHeight(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: InteractiveViewer(
                  child: MyMomentTile(
                    moment: moment,
                    index: index,
                    toggleVote: _toggleVote,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    await _dayProvider.loadHasUploaded(widget.dayCode);
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

  Future<void> _showSettings() async {
    if (day == null) return;

    final isHost = await _dayProvider.isHost(day!.id);

    if (isHost) {
      //goEditDaySettings(context, day!.id);
    } else {
      _showParticipantSettings();
    }
  }

  void _showParticipantSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave the Day?'),
        content: Text('Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              goRootPage(context);
              await _leaveDay();
            },
            child: Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _leaveDay() async {
    await _dayProvider.leaveDay(day!.id);
  }

  Future<void> _toggleVote(String momentId) async {
    await _dayProvider.toggleVote(widget.dayCode, momentId);
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DayProvider>(context);
    day = listeningProvider.day;
    final moments = listeningProvider.moments;
    final hasUploaded = listeningProvider.hasUploaded;
    listeningProvider.listenToMoments(widget.dayCode);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(day == null ? 'Loading' : day!.name),
          bottom: PreferredSize(
            preferredSize: Size.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                    'Deadline: ${day == null ? 'Loading' : day!.votingDeadline.toString()}'),
                IconButton(
                  onPressed: _cameraUploadClicked,
                  icon: Icon(Icons.camera_alt_rounded),
                ),
                IconButton(
                  onPressed: _imageUploadClicked,
                  icon: Icon(Icons.photo),
                ),
                IconButton(
                  onPressed: _showSettings,
                  icon: Icon(Icons.settings_rounded),
                ),
              ],
            ),
          ),
        ),
        body: hasUploaded
            ? Center(
                child: Column(
                  children: [
                    Expanded(
                      child: MasonryGridView.builder(
                        gridDelegate:
                            SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2),
                        shrinkWrap: true,
                        itemCount: moments?.length ?? 0,
                        itemBuilder: (context, index) {
                          final moment = moments![index];

                          return MyMomentTile(
                            moment: moment,
                            onTap: _showImageDialog,
                            index: index,
                            toggleVote: _toggleVote,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            : NoMomentUploadedPage(imageUploadClicked: _imageUploadClicked),
      ),
    );
  }
}
//eto sen
// class ImageDialog extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Container(
//         width: 200,
//         height: 200,
//         decoration: BoxDecoration(
//             image: DecorationImage(
//                 image: ExactAssetImage('lib/assets/images/sample_Image2.jpg'),
//                 fit: BoxFit.cover
//             )
//         ),
//       ),
//     );
//   }
// }