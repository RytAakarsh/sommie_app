// import 'dart:convert';
// import 'package:dio/dio.dart';
// import '../../core/constants/api_endpoints.dart';

// class ChatService {
//   final Dio _dio = Dio(BaseOptions(
//     connectTimeout: const Duration(seconds: 60),
//     receiveTimeout: const Duration(seconds: 60),
//   ));

//   /// Send a chat message to the API
//   /// Returns the AI response as a String
//   Future<String> sendMessage({
//     required String text,
//     required String userId,
//     required String sessionId,
//     required String token,
//     String mode = "general",
//   }) async {
//     try {
//       print('📤 Chat request - User: $userId, Session: $sessionId');
//       print('📝 Message: ${text.length > 100 ? text.substring(0, 100) + '...' : text}');
      
//       // ✅ Build request body according to API docs
//       final requestBody = {
//         "mode": mode,
//         "user_id": userId,
//         "session_id": sessionId,
//         "message": text,
//       };

//       print('📦 Request body: ${jsonEncode(requestBody)}');

//       final response = await _dio.post(
//         ApiEndpoints.chat,  // ✅ NO query parameters
//         options: Options(
//           headers: {
//             "Authorization": "Bearer ${ApiEndpoints.chatApiKey}",
//             "x-api-key": ApiEndpoints.chatApiKey,
//             "Content-Type": "application/json",
//             "Accept": "application/json",
//           },
//         ),
//         data: requestBody,
//       );

//       print('📥 Chat response status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = response.data;
        
//         // ✅ Parse response - API returns answer field
//         String answer = '';
        
//         if (data is Map<String, dynamic>) {
//           answer = data['answer'] ?? data['response'] ?? data['message'] ?? '';
          
//           // If answer is empty, try to get from data.data
//           if (answer.isEmpty && data['data'] != null) {
//             final innerData = data['data'] as Map<String, dynamic>;
//             answer = innerData['answer'] ?? innerData['response'] ?? '';
//           }
//         }
        
//         if (answer.isEmpty) {
//           print('⚠️ Empty response from API');
//           return "I'm not sure how to respond to that. Could you rephrase?";
//         }
        
//         print('✅ Chat response received: ${answer.length} chars');
//         return answer;
//       } else {
//         final errorData = response.data;
//         final errorMsg = errorData is Map 
//             ? errorData['message'] ?? errorData['error'] ?? 'Unknown error'
//             : 'Status ${response.statusCode}';
//         throw Exception('Chat failed: $errorMsg');
//       }
//     } on DioException catch (e) {
//       print('❌ Chat error: ${e.message}');
      
//       if (e.response != null) {
//         print('❌ Response data: ${e.response?.data}');
//         print('❌ Response status: ${e.response?.statusCode}');
        
//         // Try to extract error message
//         if (e.response?.data is Map) {
//           final errorMsg = e.response?.data['message'] ?? 
//                           e.response?.data['error'] ?? 
//                           'Server error';
//           throw Exception(errorMsg);
//         }
//       }
      
//       if (e.type == DioExceptionType.connectionTimeout ||
//           e.type == DioExceptionType.receiveTimeout) {
//         throw Exception('Connection timeout. Please check your internet.');
//       } else if (e.type == DioExceptionType.connectionError) {
//         throw Exception('Network error. Please check your connection.');
//       } else if (e.response?.statusCode == 401) {
//         throw Exception('Authentication failed. Please login again.');
//       }
      
//       throw Exception('Chat service error: ${e.message}');
//     } catch (e) {
//       print('❌ Unexpected chat error: $e');
//       throw Exception('Failed to send message: $e');
//     }
//   }
// }


import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';

class ChatService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
  ));

  /// Send a chat message to the API
  Future<String> sendMessage({
    required String text,
    required String userId,
    required String sessionId,
    required String token,
    String mode = "general",
  }) async {
    try {
      print('📤 Chat request - User: $userId, Session: $sessionId');
      
      final requestBody = {
        "mode": mode,
        "user_id": userId,
        "session_id": sessionId,
        "message": text,
      };

      final response = await _dio.post(
        ApiEndpoints.chat,
        options: Options(
          headers: {
            "Authorization": "Bearer ${ApiEndpoints.chatApiKey}",
            "x-api-key": ApiEndpoints.chatApiKey,
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        ),
        data: requestBody,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        String answer = '';
        
        if (data is Map<String, dynamic>) {
          answer = data['answer'] ?? data['response'] ?? data['message'] ?? '';
          
          if (answer.isEmpty && data['data'] != null) {
            final innerData = data['data'] as Map<String, dynamic>;
            answer = innerData['answer'] ?? innerData['response'] ?? '';
          }
        }
        
        if (answer.isEmpty) {
          return "I'm not sure how to respond to that. Could you rephrase?";
        }
        
        return answer;
      } else {
        throw Exception('Chat failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Chat error: ${e.message}');
      throw Exception('Failed to send message');
    }
  }

  /// Save chat to backend
  Future<void> saveChat({
    required String token,
    required String chatId,
    required String title,
    required List<Map<String, dynamic>> messages,
  }) async {
    try {
      print('📤 Saving chat to backend: $chatId');
      
      final response = await _dio.post(
        ApiEndpoints.saveChat,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
        data: {
          "chatId": chatId,
          "title": title,
          "messages": messages,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Chat saved to backend: $chatId');
      } else {
        print('❌ Failed to save chat: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Save chat error: $e');
    }
  }

  /// Get all chats from backend
  Future<List<Map<String, dynamic>>> getChats({
    required String token,
  }) async {
    try {
      print('📤 Fetching chats from backend...');
      
      final response = await _dio.get(
        ApiEndpoints.getChats,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final chats = data['chats'] as List? ?? [];
        print('✅ Fetched ${chats.length} chats from backend');
        
        // ✅ Debug: Print first chat's updatedAt to verify format
        if (chats.isNotEmpty) {
          print('📦 Sample chat updatedAt: ${chats.first['updatedAt']}');
        }
        
        return chats.cast<Map<String, dynamic>>();
      } else {
        print('❌ Failed to fetch chats: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Get chats error: $e');
      return [];
    }
  }

  /// Delete chat from backend
  Future<void> deleteChat({
    required String token,
    required String chatId,
  }) async {
    try {
      print('📤 Deleting chat from backend: $chatId');
      
      final response = await _dio.delete(
        '${ApiEndpoints.deleteChat}/$chatId',
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        print('✅ Chat deleted from backend: $chatId');
      } else {
        print('❌ Failed to delete chat: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Delete chat error: $e');
    }
  }
}