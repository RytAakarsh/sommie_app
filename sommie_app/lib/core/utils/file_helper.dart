import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class FileHelper {
  static Future<Map<String, dynamic>> processImage(XFile image) async {
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    
    return {
      'fileName': image.name,
      'base64': base64Image,
      'preview': 'data:image/jpeg;base64,$base64Image',
      'size': bytes.length / 1024,
    };
  }

  static Uint8List decodeBase64Image(String base64String) {
    if (base64String.startsWith('data:image')) {
      base64String = base64String.split(',').last;
    }
    return base64Decode(base64String);
  }

  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  static bool isValidImage(String fileName) {
    final ext = getFileExtension(fileName);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }
}
