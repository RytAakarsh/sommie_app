// lib/data/services/wine_service.dart
// Mark as deprecated - use WineUploadService instead

import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import 'wine_upload_service.dart';

class WineService {
  final WineUploadService _uploadService = WineUploadService();
  
  /// Upload wine label and get analysis
  Future<Map<String, dynamic>> uploadWineLabel({
    required String userId,
    required String fileName,
    required Uint8List fileBytes,
    required String contentType,
  }) async {
    return await _uploadService.uploadAndAnalyzeWine(
      userId: userId,
      filename: fileName,
      fileBytes: fileBytes,
      contentType: contentType,
    );
  }
  
  // Keep old method for compatibility but mark as deprecated
  @Deprecated('Use uploadWineLabel with Uint8List instead')
  Future<Map<String, dynamic>> uploadWineLabelBase64({
    required String userId,
    required String fileName,
    required String fileBase64,
  }) async {
    // Convert base64 to bytes
    final bytes = base64Decode(fileBase64.split(',').last);
    return await uploadWineLabel(
      userId: userId,
      fileName: fileName,
      fileBytes: bytes,
      contentType: 'image/jpeg',
    );
  }
}