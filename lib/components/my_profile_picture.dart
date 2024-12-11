import 'dart:io';

import 'package:archify/services/database/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyProfilePicture extends StatefulWidget {
  final void Function()? onProfileTapped;
  final double height;
  final double width;
  final bool hasBorder;

  const MyProfilePicture({
    super.key,
    required this.height,
    required this.width,
    required this.onProfileTapped,
    this.hasBorder = false,
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
        padding: const EdgeInsets.all(2),
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          gradient: widget.hasBorder
              ? LinearGradient(
                  colors: [
                    Color(0xFFF5DEB3),
                    Color(0xFFD2691E),
                    Color(0xFFFF6F61),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : null,
          shape: BoxShape.circle,
        ),
        child: listeningProvider.picturePath == ''
            ? const Center(
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.black38,
                  size: 35,
                ),
              )
            : Container(
                height: widget.height,
                width: widget.width,
                decoration: BoxDecoration(
                  border: widget.hasBorder
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 5,
                        )
                      : null,
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: listeningProvider.picturePath.startsWith('https')
                        ? Image.network(listeningProvider.picturePath).image
                        : Image.file(File(listeningProvider.picturePath)).image,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
      ),
    );
  }
}
