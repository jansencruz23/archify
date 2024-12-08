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
      appBar:  AppBar(
        title: Text(
          caption,
          style: TextStyle(
            fontFamily: 'Sora',
            color: Color(0xFF333333),
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Padding(
        padding: const EdgeInsets.only(top: 45),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Centers horizontally
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        imageUrl,
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
                        child: Image.asset(
                          'lib/assets/images/download_icon.png',
                          width: 40,
                          height: 40,
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