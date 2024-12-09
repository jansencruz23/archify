import 'package:archify/helpers/font_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FullScreenImage extends StatefulWidget {
  final String imageUrl;
  final String caption;

  const FullScreenImage({
    super.key,
    required this.imageUrl,
    required this.caption,
  });

  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  bool _isClicked = false; // Tracks if the button is clicked

  Future<void> _downloadImage() async {
    setState(() {
      _isClicked = true;
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      setState(() {
        _isClicked = false;
      });
    });

    try {
      final imagePath = '${Directory.systemTemp.path}/image.jpg';
      await Dio().download(widget.imageUrl, imagePath);
      await Gal.putImage(imagePath);

      // Show SnackBar message after successful download
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(
              child: Text(
                'Image downloaded.',
                style: TextStyle(fontFamily: 'Sora', color: Color(0xFFFF6F61)),
              ),
            ),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.transparent,
            behavior: SnackBarBehavior.floating,
            elevation: 0,
          ),
        );
      }
    } catch (e) {
      // Handle errors (optional)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to download image. Please try again.',
              style: TextStyle(fontFamily: 'Sora'),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.caption,
          style: TextStyle(
              fontFamily: 'Sora',
              color: Color(0xFF333333),
              fontSize: getClampedFontSize(context, 0.05)),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Padding(
        padding: const EdgeInsets.only(top: 45),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        width: 370,
                        height: 600,
                      ),
                    ),
                    Positioned(
                      bottom: 15,
                      right: 40,
                      child: GestureDetector(
                        onTap: _downloadImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              width: 60, // Shadow size
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: _isClicked
                                    ? [
                                        BoxShadow(
                                          color:
                                              Colors.black12.withOpacity(0.1),
                                          blurRadius: 8,
                                          spreadRadius: 5,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                            Image.asset(
                              'lib/assets/images/download_icon.png',
                              width: 40,
                              height: 40,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
