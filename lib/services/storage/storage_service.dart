import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logging/logging.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;
  final logger = Logger('StorageService');

  Future<String> uploadImage(String path) async {
    try {
      final uid = _auth.currentUser!.uid;
      final file = File(path);
      final filePath = 'profile_pictures/$uid - ${DateTime.now()}.png';
      final ref = _storage.ref().child(filePath);

      await ref.putFile(file);

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (ex) {
      logger.severe(ex.toString());
      return '';
    }
  }
}
