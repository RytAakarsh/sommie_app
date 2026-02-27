import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';
import '../../core/constants/api_endpoints.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    headers: {'Content-Type': 'application/json'},
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
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
      print('🔄 Signup attempt to: ${ApiEndpoints.signup}');
      
      final body = {
        'name': name,
        'email': email,
        'password': password,
        'age': age,
        'country': country,
        'gender': gender,
        // Backend should default to FREE plan
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
      throw Exception(_handleDioError(e));
    }
  }

  // Upgrade user to PRO on backend
  Future<UserModel> upgradeToPro(String userId, String token) async {
    try {
      print('🔄 Upgrading user to PRO on backend: ${ApiEndpoints.upgradePlan}');
      
      final response = await _dio.post(
        ApiEndpoints.upgradePlan,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        data: jsonEncode({
          'userId': userId,
          'plan': 'PRO',
        }),
      );

      print('✅ Upgrade response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Return updated user from response
        if (response.data['user'] != null) {
          return UserModel.fromJson(response.data['user']);
        }
        // If no user returned, create one with PRO plan
        return UserModel(
          userId: userId,
          name: '',
          email: '',
          plan: 'PRO',
          token: token,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Upgrade failed');
      }
    } on DioException catch (e) {
      print('❌ Upgrade error: ${e.message}');
      throw Exception(_handleDioError(e));
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
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout. Please try again.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Network error. Please check your connection.';
    } else {
      return 'Network error: ${e.message}';
    }
  }
}
