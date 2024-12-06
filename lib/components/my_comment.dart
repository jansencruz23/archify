import 'package:flutter/material.dart';

class MyComment extends StatelessWidget {
  final String text;
  final String user;
  final String time;
  const MyComment(
      {super.key, required this.text, required this.user, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            children: [Text(user), Text(text)],
          )
        ],
      ),
    );
  }
}
