import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/wine_model.dart';
import '../../core/constants/api_endpoints.dart';

class WineService {
  final Dio _dio = Dio(BaseOptions(
    headers: {'Content-Type': 'application/json'},
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Future<Map<String, dynamic>> uploadWineLabel({
    required String userId,
    required String planType,
    required String fileName,
    required String fileBase64,
  }) async {
    try {
      print('📤 Uploading wine to: ${ApiEndpoints.uploadWine}');
      
      final response = await _dio.post(
        ApiEndpoints.uploadWine,
        data: jsonEncode({
          'user_id': userId,
          'plan_type': planType,
          'file_name': fileName,
          'file_base64': fileBase64,
        }),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseWineResponse(response.data);
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Upload error: ${e.message}');
      throw Exception(_handleDioError(e));
    }
  }

  // NEW: Get user's wines from server
  Future<List<WineModel>> getUserWines(String userId) async {
    try {
      // This endpoint doesn't exist yet - you need to create it on your server
      // For now, we'll return empty list
      print('⚠️ Need to implement GET /users/$userId/wines endpoint');
      return [];
    } catch (e) {
      print('❌ Error fetching wines: $e');
      return [];
    }
  }

  Map<String, dynamic> _parseWineResponse(dynamic data) {
    final Map<String, dynamic> safeResponse = {};
    
    try {
      if (data is Map) {
        if (data.containsKey('duplicate') && data['duplicate'] == true) {
          safeResponse['duplicate'] = true;
          safeResponse['wine_id'] = data['wine_id']?.toString();
          return safeResponse;
        }
        
        if (data.containsKey('register_result') && data['register_result'] is Map) {
          final registerResult = data['register_result'] as Map;
          final Map<String, dynamic> safeRegister = {};
          
          if (registerResult.containsKey('wine_id')) {
            safeRegister['wine_id'] = registerResult['wine_id']?.toString();
          }
          
          if (registerResult.containsKey('parsed') && registerResult['parsed'] is Map) {
            final parsed = registerResult['parsed'] as Map;
            final Map<String, dynamic> safeParsed = {};
            
            if (parsed.containsKey('wine_name')) {
              safeParsed['wine_name'] = parsed['wine_name']?.toString();
            }
            if (parsed.containsKey('grape')) {
              safeParsed['grape'] = parsed['grape']?.toString();
            }
            if (parsed.containsKey('year')) {
              safeParsed['year'] = parsed['year']?.toString();
            }
            if (parsed.containsKey('country')) {
              safeParsed['country'] = parsed['country']?.toString();
            }
            if (parsed.containsKey('region')) {
              safeParsed['region'] = parsed['region']?.toString();
            }
            
            safeRegister['parsed'] = safeParsed;
          }
          
          safeResponse['register_result'] = safeRegister;
        }
        
        data.forEach((key, value) {
          if (!safeResponse.containsKey(key)) {
            safeResponse[key] = value;
          }
        });
      }
    } catch (e) {
      print('❌ Error parsing response: $e');
    }
    
    return safeResponse;
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
    } else {
      return 'Network error';
    }
  }
}
