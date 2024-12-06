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
import 'package:archify/components/my_nickname_and_avatar_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

  //New dialog
  void _showNicknameAndAvatarDialog(BuildContext context) {
    showDialog(
        context: context,
        // barrierDismissible: false, para di skippable
        builder: (context) => AlertDialog(
              title: Text('Be the best you~'),
              content: Container(
                width: double.infinity,
                child: MyNicknameAndAvatarDialog(),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'))
              ],
            ));
  }

  // OLD Dialog for testing only
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

    if (isHost && mounted) {
      goEditSettings(context, day!);
    } else {
      _showParticipantSettings();
    }
  }

  void _showDayCode(String code) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("QR Code", style: TextStyle(fontFamily: 'Sora',color: Theme.of(context).colorScheme.inversePrimary,),),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  QrImageView(
                    data: code,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  SizedBox(height: 10),
                  Text(code, style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700, color:Theme.of(context).colorScheme.secondary ),),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Close",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontFamily: 'Sora',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  //Font responsiveness
  double _getClampedFontSize(BuildContext context, double scale) {
    double calculatedFontSize = MediaQuery.of(context).size.width * scale;
    return calculatedFontSize.clamp(12.0, 24.0); // Set min and max font size
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DayProvider>(context);
    day = listeningProvider.day;
    final moments = listeningProvider.moments;
    final hasUploaded = listeningProvider.hasUploaded;
    listeningProvider.listenToMoments(widget.dayCode);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          titleSpacing: 0,
          leadingWidth: 600,
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 10.0, 24.0, 8.0),
            child: Stack(
              children: [
                Text(
                  'Let’s keep the moment,',
                  style: TextStyle(
                    fontSize: _getClampedFontSize(context, 0.03),
                    fontFamily: 'Sora',
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                Positioned(
                  bottom: -5,
                  left: 0,
                  child: Text(
                    'Pick the best shot!',
                    style: TextStyle(
                      fontSize: _getClampedFontSize(context, 0.05),
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ),

                //Test icons
                Row(
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


              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(
              height: 2,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      ),


      //TEST APP BAR
      // AppBar(
      //   title: Text(day == null ? 'Loading' : day!.name),
      //   bottom: PreferredSize(
      //     preferredSize: Size.zero,
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //       children: [
      //         Text(
      //             'Deadline: ${day == null ? 'Loading' : day!.votingDeadline.toString()}'),
      //         IconButton(
      //           onPressed: _cameraUploadClicked,
      //           icon: Icon(Icons.camera_alt_rounded),
      //         ),
      //         IconButton(
      //           onPressed: _imageUploadClicked,
      //           icon: Icon(Icons.photo),
      //         ),
      //         IconButton(
      //           onPressed: _showSettings,
      //           icon: Icon(Icons.settings_rounded),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      body: hasUploaded
          ? SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Center(
                  child: Column(
                    children: [
                    //DAY CODE: COntainer
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, top: 20, bottom: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              child: GestureDetector(
                                onTap: () => _showDayCode(day?.code ?? ''),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'DAY CODE: ${day?.code == null ? '' : day!.code}',
                                    style: TextStyle(
                                      fontSize: _getClampedFontSize(context, 0.03),
                                      fontFamily: 'Sora',
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),

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
                ),
            ),
          )
          : NoMomentUploadedPage(imageUploadClicked: _imageUploadClicked),
    );
  }
}
