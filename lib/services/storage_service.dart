import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const Uuid _uuid = Uuid();

  static Future<String?> uploadImage(File imageFile) async {
    try {
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage.ref().child('images/$fileName');
      
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  static Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    final List<String> urls = [];
    
    for (final file in imageFiles) {
      final url = await uploadImage(file);
      if (url != null) {
        urls.add(url);
      }
    }
    
    return urls;
  }
}
