// lib/data/services/wine_upload_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/api_endpoints.dart';

class WineUploadService {
  final Dio _dio = Dio(BaseOptions(
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': ApiEndpoints.chatApiKey,
    },
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
  ));

  /// Step 1: Get presigned URL for upload
  Future<PresignedUploadResponse> getPresignedUrl({
    required String userId,
    required String filename,
    required String contentType,
  }) async {
    try {
      print('📤 Getting presigned URL for wine upload...');
      
      final response = await _dio.post(
        ApiEndpoints.presignUpload,
        data: jsonEncode({
          'upload_type': 'cellar',
          'user_id': userId,
          'session_id': 'wine_${DateTime.now().millisecondsSinceEpoch}',
          'filename': filename,
          'content_type': contentType,
        }),
      );

      print('📥 Presign response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final uploadUrl = data['data']?['upload_url'] ?? data['upload_url'];
        final fileKey = data['data']?['file_key'] ?? data['file_key'];
        
        return PresignedUploadResponse(
          uploadUrl: uploadUrl,
          fileKey: fileKey,
        );
      } else {
        throw Exception('Failed to get presigned URL: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Presign error: ${e.message}');
      throw Exception(_handleDioError(e));
    }
  }

  /// Step 2: Upload file directly to S3 using presigned URL
  Future<void> uploadToS3(String uploadUrl, Uint8List fileBytes, String contentType) async {
    try {
      print('📤 Uploading to S3...');
      
      final response = await Dio().put(
        uploadUrl,
        data: Stream.fromIterable(fileBytes.map((e) => [e])),
        options: Options(
          headers: {
            'Content-Type': contentType,
          },
          contentType: contentType,
        ),
      );

      print('📥 S3 upload status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
        throw Exception('Failed to upload to S3: ${response.statusCode}');
      }
      
      print('✅ File uploaded to S3 successfully');
    } catch (e) {
      print('❌ S3 upload error: $e');
      throw Exception('Failed to upload image to storage');
    }
  }

  /// Step 3: Send file_key to chat endpoint for analysis
  Future<Map<String, dynamic>> analyzeWine({
    required String userId,
    required String fileKey,
    required String message,
  }) async {
    try {
      print('📤 Analyzing wine with file_key: $fileKey');
      
      final response = await _dio.post(
        ApiEndpoints.chat,
        data: jsonEncode({
          'mode': 'cellar',
          'user_id': userId,
          'session_id': 'cellar_${DateTime.now().millisecondsSinceEpoch}',
          'message': message,
          'file_key': fileKey,
        }),
      );

      print('📥 Analysis response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseChatResponse(response.data);
      } else {
        throw Exception('Analysis failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Analysis error: ${e.message}');
      throw Exception(_handleDioError(e));
    }
  }

  /// Complete flow: Get presign -> Upload to S3 -> Analyze
  Future<Map<String, dynamic>> uploadAndAnalyzeWine({
    required String userId,
    required String filename,
    required Uint8List fileBytes,
    required String contentType,
  }) async {
    // Step 1: Get presigned URL
    final presignResponse = await getPresignedUrl(
      userId: userId,
      filename: filename,
      contentType: contentType,
    );
    
    // Step 2: Upload to S3
    await uploadToS3(presignResponse.uploadUrl, fileBytes, contentType);
    
    // Step 3: Analyze the wine
    final analysisResult = await analyzeWine(
      userId: userId,
      fileKey: presignResponse.fileKey,
      message: 'Quero cadastrar esse vinho.',
    );
    
    return analysisResult;
  }

  Map<String, dynamic> _parseChatResponse(dynamic data) {
    final Map<String, dynamic> result = {};
    
    try {
      if (data is Map) {
        // Check for pending wine in state_summary
        if (data.containsKey('state_summary')) {
          final stateSummary = data['state_summary'] as Map;
          if (stateSummary.containsKey('pending_wine')) {
            final pendingWine = stateSummary['pending_wine'] as Map;
            if (pendingWine.containsKey('current_fields')) {
              final fields = pendingWine['current_fields'] as Map;
              result['wine'] = _extractWineData(fields);
            }
          }
        }
        
        // Check for response message
        if (data.containsKey('response')) {
          result['message'] = data['response'].toString();
        } else if (data.containsKey('message')) {
          result['message'] = data['message'].toString();
        }
        
        // Check for wine_id in register_result
        if (data.containsKey('register_result')) {
          final registerResult = data['register_result'] as Map;
          if (registerResult.containsKey('wine_id')) {
            result['wine_id'] = registerResult['wine_id'].toString();
          }
        }
      }
    } catch (e) {
      print('❌ Error parsing chat response: $e');
    }
    
    return result;
  }

  Map<String, dynamic> _extractWineData(Map data) {
    return {
      'wine_name': data['wine_name']?.toString() ?? '',
      'grape': data['grape']?.toString() ?? '',
      'year': data['year']?.toString() ?? data['vintage_year']?.toString() ?? '',
      'country': data['country']?.toString() ?? '',
      'region': data['region']?.toString() ?? '',
      'wine_type': data['wine_type']?.toString() ?? '',
      'alcohol_percent': data['alcohol_percent']?.toString(),
      'volume_ml': data['volume_ml']?.toString(),
    };
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      if (e.response?.statusCode == 403) {
        final data = e.response?.data;
        if (data is Map && data['error'] == 'FORBIDDEN') {
          return 'PLAN_LIMIT_EXCEEDED';
        }
      }
      return 'Server error: ${e.response?.statusCode}';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection';
    } else {
      return 'Network error: ${e.message}';
    }
  }
}

class PresignedUploadResponse {
  final String uploadUrl;
  final String fileKey;
  
  PresignedUploadResponse({
    required this.uploadUrl,
    required this.fileKey,
  });
}