import 'dart:io';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetupProfilePicPage extends StatefulWidget {
  final void Function()? onTap;

  const SetupProfilePicPage({super.key, required this.onTap});

  @override
  State<SetupProfilePicPage> createState() => _SetupProfilePicPageState();
}

// For Responsiveness
double _getClampedFontSize(BuildContext context, double scale) {
  double calculatedFontSize = MediaQuery.of(context).size.width * scale;
  return calculatedFontSize.clamp(12.0, 24.0); // The min and max font size
}

class _SetupProfilePicPageState extends State<SetupProfilePicPage> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(50, 40, 50, 30),
          child: Text(
            'Choose your profile photo',
            style: TextStyle(
              fontFamily: 'Sora',
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: _getClampedFontSize(context, 0.05),
            ),
            maxLines: 2,
          ),
        ),
        Center(
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF5DEB3),
                    Color(0xFFD2691E),
                    Color(0xFFFF6F61),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                shape: BoxShape.circle,
              ),
              child: userProvider.picturePath == ''
                  ? const Center(
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 200,
                ),
              )
                  : Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 5,
                  ),
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: userProvider.picturePath.startsWith('https')
                        ? Image.network(userProvider.picturePath).image
                        : Image.file(File(userProvider.picturePath)).image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
