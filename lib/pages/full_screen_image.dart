import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String caption;

  const FullScreenImage({
    super.key,
    required this.imageUrl,
    required this.caption,
  });

  Future<void> _downloadImage() async {
    final imagePath = '${Directory.systemTemp.path}/image.jpg';
    await Dio().download(imageUrl, imagePath);
    await Gal.putImage(imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DefaultTextStyle(
          style: TextStyle(
            fontFamily: 'Sora',
            color: Color(0xFF333333),
            fontSize: 20,
          ),
          child: Text(caption),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: 370,
                    height: 500,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 35),
              child: IconButton(
                onPressed: _downloadImage,
                icon: Icon(
                  Icons.download_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 50,
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
