import 'dart:io';

import 'package:archify/services/database/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyProfilePicture extends StatefulWidget {
  final void Function()? onProfileTapped;
  final double height;
  final double width;

  const MyProfilePicture({
    super.key,
    required this.height,
    required this.width,
    required this.onProfileTapped,
  });

  @override
  State<MyProfilePicture> createState() => _MyProfilePictureState();
}

class _MyProfilePictureState extends State<MyProfilePicture> {
  @override
  Widget build(BuildContext context) {
    late final listeningProvider = Provider.of<UserProvider>(context);

    return GestureDetector(
      onTap: widget.onProfileTapped,
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
          image: listeningProvider.picturePath != ''
              ? DecorationImage(
                  image: listeningProvider.picturePath.startsWith('https')
                      ? Image.network(listeningProvider.picturePath).image
                      : Image.file(File(listeningProvider.picturePath)).image,
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: const Center(
          child: Icon(
            Icons.person_rounded,
            color: Colors.black38,
            size: 35,
          ),
        ),
      ),
    );
  }
}
