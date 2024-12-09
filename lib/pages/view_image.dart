import 'package:archify/helpers/avatar_mapper.dart';
import 'package:archify/helpers/font_helper.dart';
import 'package:archify/models/moment.dart';
import 'package:archify/services/database/day/day_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ViewImage extends StatefulWidget {
  final Moment moment;
  final void Function()? toggleVote;
  final void Function()? toggleFavorite;
  final bool isActive;

  const ViewImage({
    super.key,
    required this.moment,
    required this.toggleVote,
    required this.isActive,
    this.toggleFavorite,
  });

  @override
  State<ViewImage> createState() => _PartialScreenImageState();
}

class _PartialScreenImageState extends State<ViewImage> {
  late String _avatarPath;

  @override
  void initState() {
    super.initState();
    try {
      _avatarPath = avatarMap[widget.moment.avatarId]!;
    } catch (e) {
      _avatarPath = avatarMap['avatar_01']!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DayProvider>(context);
    final votedMomentIds = listeningProvider.votedMomentIds;
    try {
      _avatarPath = avatarMap[widget.moment.avatarId]!;
    } catch (e) {
      _avatarPath = avatarMap['avatar_01']!;
    }

    return Scaffold(
      appBar: AppBar(
        title: widget.isActive
            ? const Text('')
            : Text(
                widget.moment.dayName,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: getClampedFontSize(context, 0.04),
                ),
              ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add margin
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    _avatarPath,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.moment.nickname,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: getClampedFontSize(context, 0.04),
                      ),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(widget.moment.uploadedAt),
                      style: TextStyle(
                        fontFamily: 'Sora',
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: getClampedFontSize(context, 0.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              flex: 3, // Image takes 3/4 of the screen
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.moment.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 16), // Spacer between image and heart icon
            Row(
              children: [
                GestureDetector(
                  onTap: widget.toggleVote ?? () {},
                  child: votedMomentIds.contains(widget.moment.momentId)
                      ? Icon(
                          Icons.favorite_rounded,
                          color: Colors.red,
                          size: 40,
                        )
                      : Icon(
                          Icons.favorite_border_rounded,
                          color: Colors.grey[400],
                          size: 40,
                        ),
                ),
                const SizedBox(
                    width: 16), // Spacer between heart icon and share icon
                GestureDetector(
                  onTap: () => Share.share(widget.moment.imageUrl),
                  child: Image.asset(
                    'lib/assets/images/send_outlined.png',
                    height: 40,
                    width: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
