import 'package:flutter/material.dart';

class NoMomentUploadedPage extends StatefulWidget {
  final void Function() imageUploadClicked;
  const NoMomentUploadedPage({super.key, required this.imageUploadClicked});

  @override
  State<NoMomentUploadedPage> createState() => _NoMomentUploadedPageState();
}

class _NoMomentUploadedPageState extends State<NoMomentUploadedPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('You haven\'t uploaded a moment yet!'),
          ElevatedButton(
            onPressed: widget.imageUploadClicked,
            child: Text('Upload a moment'),
          ),
        ],
      ),
    );
  }
}
