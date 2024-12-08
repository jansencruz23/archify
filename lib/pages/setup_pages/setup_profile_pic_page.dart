import 'package:archify/components/my_profile_picture.dart';
import 'package:flutter/material.dart';

class SetupProfilePicPage extends StatefulWidget {
  final void Function()? onTap;

  const SetupProfilePicPage({super.key, required this.onTap});

  @override
  State<SetupProfilePicPage> createState() => _SetupProfilePicPageState();
}
//For Responsiveness
double _getClampedFontSize(BuildContext context, double scale) {
  double calculatedFontSize = MediaQuery.of(context).size.width * scale;
  return calculatedFontSize.clamp(12.0, 24.0); // Ang min and max nyaa
}
class _SetupProfilePicPageState extends State<SetupProfilePicPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(50, 40, 50, 30),
          child: Text('Choose your profile photo', style: TextStyle(
            fontFamily: 'Sora',
            color: Theme.of(context).colorScheme.inversePrimary,
            fontSize: _getClampedFontSize(context, 0.05),
          ), maxLines: 2,),
        ),
        Center(
          child: MyProfilePicture(
            height: 100,
            width: 100,
            onProfileTapped: widget.onTap,
          ),
        ),
      ],
    );
  }
}
