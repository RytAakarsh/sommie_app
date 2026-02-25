import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';

class WineService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    headers: {'Content-Type': 'application/json'},
  ));

  Future<Map<String, dynamic>> uploadWineLabel({
    required String userId,
    required String planType,
    required String fileName,
    required String fileBase64,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.uploadWine,
        data: jsonEncode({
          'userId': userId,
          'planType': planType,
          'fileName': fileName,
          'fileBase64': fileBase64,
        }),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Upload failed');
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? 'Server error';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout';
    } else {
      return 'Network error';
    }
  }
}
