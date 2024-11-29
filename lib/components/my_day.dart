import 'package:archify/models/moment.dart';
import 'package:flutter/material.dart';

class MyDay extends StatefulWidget {
  final Moment moment;
  final bool isMainPhoto;
  const MyDay({super.key, required this.moment, required this.isMainPhoto});

  @override
  State<MyDay> createState() => _MyDayState();
}

class _MyDayState extends State<MyDay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Container Image
        Container(
          width: MediaQuery.of(context).size.height * 0.4,
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            image: DecorationImage(
              image: Image.network(widget.moment.imageUrl).image,
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.5), // Gradient para sa text
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
              ),
            ),
          ),
        ),

        // Text and date
        if (widget.isMainPhoto)
          Positioned(
            bottom: 30,
            left: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                widget.moment.dayName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),
            ),
          ),

        //date
        if (widget.isMainPhoto)
          Positioned(
            bottom: 5,
            left: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                widget.moment.uploadedAt.add(Duration(hours: 8)).toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  fontSize: 12,
                ),
              ),
            ),
          ),

        //heart and save button
        if (widget.isMainPhoto)
          Positioned(
            bottom: 0,
            right: 10,
            child: Row(
              mainAxisSize:
                  MainAxisSize.min, // To make buttons not take up full space
              mainAxisAlignment: MainAxisAlignment
                  .start, // Al // To make buttons not take up full space
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.favorite_border,
                      color: Theme.of(context).colorScheme.tertiaryContainer),
                  onPressed: () {
                    // Handle the heart button press
                  },
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.bookmark_border,
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                  ),
                  onPressed: () {
                    // Handle the save button press
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}
