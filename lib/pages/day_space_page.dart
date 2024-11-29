import 'package:archify/components/my_input_alert_box.dart';
import 'package:archify/models/day.dart';
import 'package:archify/models/moment.dart';
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
      _hasVotingDeadlineExpired().then((hasExpired) {
        if (hasExpired) _showVotingResults();
      });
      _isParticipant().then((isParticipant) {
        if (!isParticipant) _showNicknameInputDialog();
      });
      _loadDay();
    });
  }

  Future<bool> _hasVotingDeadlineExpired() async {
    return await _dayProvider.hasVotingDeadlineExpired(widget.dayCode);
  }

  Future<bool> _isParticipant() async {
    return await _dayProvider.isParticipant(widget.dayCode);
  }

  void _showImageDialog(Moment moment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(moment.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  void _showVotingResults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('Tapos na. Winner: ${day?.winnerId ?? "Unknown"}'),
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

  Future<void> _likeImage(String momentId) async {
    await _dayProvider.likeImage(widget.dayCode, momentId);
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DayProvider>(context);
    day = listeningProvider.day;
    final moments = listeningProvider.moments;
    final hasUploaded = listeningProvider.hasUploaded;

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

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (moment.nickname.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          ClipOval(
                                            child: Image.network(
                                              moment.imageUrl,
                                              height: 40,
                                              width: 40,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            moment.nickname,
                                            style: TextStyle(
                                                fontFamily: 'Sora',
                                                fontSize: 16),
                                          )
                                        ],
                                      ),
                                    ),
                                  Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () => _showImageDialog(moment),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                          child: Image.network(
                                            moment.imageUrl,
                                            width: double.infinity,
                                            height:
                                                (index % 3 == 0) ? 180 : 230,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                          child: IconButton(
                                        onPressed: () =>
                                            _likeImage(moment.momentId),
                                        icon: Icon(Icons.favorite_rounded),
                                      )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('You haven\'t uploaded a moment yet!'),
                    ElevatedButton(
                      onPressed: _imageUploadClicked,
                      child: Text('Upload a moment'),
                    ),
                  ],
                ),
              ),
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