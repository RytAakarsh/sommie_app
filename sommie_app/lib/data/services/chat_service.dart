import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';

class ChatService {
  final Dio _dio = Dio(BaseOptions(
    headers: {'Content-Type': 'application/json'},
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
  ));

  Future<String> sendMessage({
    required String text,
    required String userId,
    required String sessionId,
    required String token,
  }) async {
    try {
      print('📤 Chat attempt to: ${ApiEndpoints.chat}');
      
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

      print('📥 Chat response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final reply = response.data['reply'] ?? 'No response from AI';
        return reply;
      } else {
        throw Exception('Chat failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Chat error: ${e.message}');
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return '⚠️ O serviço de chat está demorando para responder. Tente novamente.\n\n⚠️ Chat service is taking too long to respond. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        return '⚠️ Erro de conexão. Verifique sua internet.\n\n⚠️ Connection error. Please check your internet.';
      } else if (e.response?.statusCode == 401) {
        return '⚠️ Sessão expirada. Faça login novamente.\n\n⚠️ Session expired. Please login again.';
      } else {
        return '⚠️ Serviço temporariamente indisponível. Tente novamente mais tarde.\n\n⚠️ Service temporarily unavailable. Please try again later.';
      }
    }
  }
}
