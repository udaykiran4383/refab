import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String?> uploadImage({
    required String path,
    required dynamic file, // File for mobile, Uint8List for web
    String? fileName,
  }) async {
    try {
      fileName ??= DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage.ref().child('$path/$fileName');

      UploadTask uploadTask;
      if (kIsWeb) {
        // Web upload
        uploadTask = ref.putData(file as Uint8List);
      } else {
        // Mobile upload
        uploadTask = ref.putFile(file as File);
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  static Future<List<String>> uploadMultipleImages({
    required String path,
    required List<dynamic> files,
  }) async {
    final List<String> urls = [];
    
    for (int i = 0; i < files.length; i++) {
      final url = await uploadImage(
        path: path,
        file: files[i],
        fileName: '${DateTime.now().millisecondsSinceEpoch}_$i',
      );
      if (url != null) {
        urls.add(url);
      }
    }
    
    return urls;
  }

  static Future<bool> deleteImage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}
