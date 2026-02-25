import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';

class ChatService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    headers: {'Content-Type': 'application/json'},
  ));

  Future<String> sendMessage({
    required String text,
    required String userId,
    required String sessionId,
    required String token,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.chat,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: jsonEncode({
          'text': text,
          'userId': userId,
          'sessionId': sessionId,
        }),
      );

      if (response.statusCode == 200) {
        return response.data['reply'] ?? 'No response from AI';
      } else {
        throw Exception('Chat failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized');
      }
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
