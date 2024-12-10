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

        //  colors: [
        //                     Color(0xFFF5DEB3),
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
                  ?  Center(
                      child: Icon(
                        Icons.account_circle,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 300,
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
                              : Image.file(File(userProvider.picturePath))
                                  .image,
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
