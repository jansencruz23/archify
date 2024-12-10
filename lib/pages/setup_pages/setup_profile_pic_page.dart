import 'dart:io';
import 'package:archify/services/database/user/user_provider.dart';
import 'package:archify/helpers/font_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetupProfilePicPage extends StatefulWidget {
  final void Function()? onTap;

  const SetupProfilePicPage({super.key, required this.onTap});

  @override
  State<SetupProfilePicPage> createState() => _SetupProfilePicPageState();
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
              fontSize: getClampedFontSize(context, 0.05),
            ),
            maxLines: 2,
          ),
        ),


        Center(
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.all(0),
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: userProvider.picturePath == ''
                  ? Align(
                      alignment: Alignment.center,// Ensures it spans the full width of the parent
                      child: Center(
                        child: Icon(
                          Icons.account_circle,
                          color: Theme.of(context).colorScheme.secondary,
                          size: MediaQuery.of(context).size.height * 0.4,
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(3),
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.height * 0.4,
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
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.height * 0.3,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 8,
                          ),
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: userProvider.picturePath.startsWith('https')
                                ? Image.network(userProvider.picturePath).image
                                : Image.file(File(userProvider.picturePath))
                                    .image,
                            fit: BoxFit.cover,
                          ),
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
