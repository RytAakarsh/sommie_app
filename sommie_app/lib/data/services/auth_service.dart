import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/auth_response.dart';
import '../../core/constants/api_endpoints.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    headers: {'Content-Type': 'application/json'},
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  ));

  Future<AuthResponse> login(String email, String password) async {
    try {
      print('🔄 Login attempt to: ${ApiEndpoints.login}');
      
      final response = await _dio.post(
        ApiEndpoints.login,
        data: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('✅ Login response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      print('❌ Login error: ${e.message}');
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'O servidor não está respondendo. Por favor, tente novamente em alguns instantes.\n\n'
          'The server is not responding. Please try again in a few moments.'
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Erro de conexão. Verifique sua internet.\n\n'
          'Connection error. Please check your internet.'
        );
      } else {
        throw Exception(_handleDioError(e));
      }
    }
  }

  Future<AuthResponse> signup({
    required String name,
    required String email,
    required String password,
    required int age,
    required String country,
    required String gender,
  }) async {
    try {
      print('🔄 Signup attempt to: ${ApiEndpoints.signup}');
      
      final body = {
        'name': name,
        'email': email,
        'password': password,
        'age': age,
        'country': country,
        'gender': gender,
      };
      
      print('📝 Signup body: $body');

      final response = await _dio.post(
        ApiEndpoints.signup,
        data: jsonEncode(body),
      );

      print('✅ Signup response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Signup failed');
      }
    } on DioException catch (e) {
      print('❌ Signup error: ${e.message}');
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
          'O servidor não está respondendo. Por favor, tente novamente em alguns instantes.\n\n'
          'The server is not responding. Please try again in a few moments.'
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Erro de conexão. Verifique sua internet.\n\n'
          'Connection error. Please check your internet.'
        );
      } else {
        throw Exception(_handleDioError(e));
      }
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'].toString();
      } else if (data is Map && data.containsKey('error')) {
        return data['error'].toString();
      }
      return 'Server error: ${e.response?.statusCode}';
    } else {
      return 'Network error: ${e.message}';
    }
  }
}
