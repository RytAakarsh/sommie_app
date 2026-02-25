import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/auth_response.dart';
import '../../core/constants/api_endpoints.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    headers: {'Content-Type': 'application/json'},
  ));

  Future<AuthResponse> login(String email, String password) async {
    try {
      print('Login attempt: ${ApiEndpoints.baseUrl}${ApiEndpoints.login}'); // Debug log
      print('Email: $email'); // Debug log
      
      final response = await _dio.post(
        ApiEndpoints.login,
        data: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}'); // Debug log
      print('Login response data: ${response.data}'); // Debug log

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      print('Dio error: ${e.message}'); // Debug log
      print('Response data: ${e.response?.data}'); // Debug log
      print('Response status: ${e.response?.statusCode}'); // Debug log
      throw Exception(_handleDioError(e));
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
      print('Signup attempt: ${ApiEndpoints.baseUrl}${ApiEndpoints.signup}'); // Debug log
      
      final body = {
        'name': name,
        'email': email,
        'password': password,
        'age': age,
        'country': country,
        'gender': gender,
      };
      
      print('Signup body: $body'); // Debug log

      final response = await _dio.post(
        ApiEndpoints.signup,
        data: jsonEncode(body),
      );

      print('Signup response status: ${response.statusCode}'); // Debug log
      print('Signup response data: ${response.data}'); // Debug log

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Signup failed');
      }
    } on DioException catch (e) {
      print('Dio error: ${e.message}'); // Debug log
      print('Response data: ${e.response?.data}'); // Debug log
      print('Response status: ${e.response?.statusCode}'); // Debug log
      throw Exception(_handleDioError(e));
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      // Try to get error message from response
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      } else if (data is Map && data.containsKey('error')) {
        return data['error'];
      } else if (data is String) {
        return data;
      }
      return 'Server error: ${e.response?.statusCode}';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout. Please try again.';
    } else if (e.type == DioExceptionType.cancel) {
      return 'Request cancelled';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Network error. Please check your connection.';
    } else {
      return 'Network error: ${e.message}';
    }
  }
}