import 'package:archify/helpers/avatar_mapper.dart';
import 'package:archify/models/moment.dart';
import 'package:archify/services/database/day/day_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyMomentTile extends StatefulWidget {
  final Moment moment;
  final int index;
  final void Function(Moment moment, int index)? onTap;
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
  //late String _avatarPath;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //_avatarPath = avatarMap[widget.moment.avatarId]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DayProvider>(context);
    final votedMomentIds = listeningProvider.votedMomentIds;

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
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'lib/assets/avatars/male_avatar_1.png',
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      widget.moment.nickname,
                      style: TextStyle(fontFamily: 'Sora', fontSize: 16),
                    )
                  ],
                ),
              ),
            Stack(
              children: [
                GestureDetector(
                  onTap: widget.onTap == null
                      ? () {}
                      : () => widget.onTap!(widget.moment, widget.index),
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
          ],
        ),
      ),
    );
  }
}
