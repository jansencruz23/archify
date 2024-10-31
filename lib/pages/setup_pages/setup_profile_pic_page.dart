import 'package:archify/components/my_profile_picture.dart';
import 'package:flutter/material.dart';

class SetupProfilePicPage extends StatefulWidget {
  final void Function()? onTap;

  const SetupProfilePicPage({super.key, required this.onTap});

  @override
  State<SetupProfilePicPage> createState() => _SetupProfilePicPageState();
}

class _SetupProfilePicPageState extends State<SetupProfilePicPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: MyProfilePicture(
        height: 100,
        width: 100,
        onProfileTapped: widget.onTap,
      ),
    );
  }
}
