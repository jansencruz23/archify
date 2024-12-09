import 'package:archify/helpers/avatar_mapper.dart';
import 'package:archify/helpers/font_helper.dart';
import 'package:archify/models/moment.dart';
import 'package:archify/services/database/day/day_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyMomentTile extends StatefulWidget {
  final Moment moment;
  final int index;
  final void Function()? onTap;
  final void Function(String momentId) toggleVote;
  const MyMomentTile({
    super.key,
    required this.moment,
    required this.toggleVote,
    required this.index,
    this.onTap,
  });

  @override
  State<MyMomentTile> createState() => _MyMomentTileState();
}

class _MyMomentTileState extends State<MyMomentTile> {
  late String _avatarPath;

  @override
  void initState() {
    super.initState();
    _avatarPath = avatarMap[widget.moment.avatarId]!;
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DayProvider>(context);
    final votedMomentIds = listeningProvider.votedMomentIds;
    _avatarPath = avatarMap[widget.moment.avatarId]!;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.moment.nickname.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(0),
                child: Row(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        _avatarPath,
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                      widget.moment.nickname,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: getClampedFontSize(context, 0.03),
                      ),
                    )
                  ],
                ),
              ),
            Stack(
              children: [
                GestureDetector(
                  onTap: widget.onTap,
                  onDoubleTap: () => widget.toggleVote(widget.moment.momentId),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.network(
                      widget.moment.imageUrl,
                      width: double.infinity,
                      height: (widget.index % 3 == 0) ? 180 : 230,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                    child: IconButton(
                  onPressed: () => widget.toggleVote(widget.moment.momentId),
                  icon: votedMomentIds.contains(widget.moment.momentId)
                      ? Icon(Icons.favorite_rounded, color: Colors.red)
                      : Icon(Icons.favorite_rounded),
                )),
              ],
            ),
            SizedBox(
              height: (widget.index % 3 == 0) ? 10 : 10,
            )
          ],
        ),
      ),
    );
  }
}
