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
        title: Text(caption),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.network(imageUrl),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                    onPressed: _downloadImage,
                    icon: Icon(
                      Icons.download_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 50,
                    ))),
          ],
        ),
      ),
    );
  }
}
