// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';
// import '../models/wine_model.dart';
// import '../services/cellar_service.dart';
// import '../../core/utils/storage_helper.dart';
// import '../../core/constants/api_endpoints.dart';

// class CellarProvider extends ChangeNotifier {
//   List<WineModel> _wines = [];
//   String? _userId;
//   String? _token;
//   bool _isLoading = false;
//   static const int maxFreeBottles = 6;
//   final CellarService _service = CellarService();
  
//   /// ✅ Create Dio instance with BOTH required headers (matches working website)
//   Dio _createDio() {
//     final headers = {
//       'Content-Type': 'application/json',
//       'x-api-key': ApiEndpoints.chatApiKey,
//       'Authorization': 'Bearer ${ApiEndpoints.chatApiKey}',
//       'Accept': 'application/json',
//     };
    
//     print('🔑 Dio Headers: ${headers.keys}');
    
//     return Dio(BaseOptions(
//       headers: headers,
//       connectTimeout: const Duration(seconds: 60),
//       receiveTimeout: const Duration(seconds: 60),
//     ));
//   }

//   List<WineModel> get wines => _wines;
//   int get wineCount => _wines.length;
//   int get remainingFreeSpots => maxFreeBottles - _wines.length;
//   bool get canAddMore => _wines.length < maxFreeBottles;
//   bool get isLoading => _isLoading;

//   CellarProvider() {
//     _initialize();
//   }

//   Future<void> _initialize() async {
//     final user = await StorageHelper.getUser();
//     if (user != null) {
//       _userId = user.userId;
//       _token = await StorageHelper.getToken();
//       await loadWines();
//     }
//   }

//   Future<void> loadWines() async {
//     if (_userId == null || _token == null) {
//       _wines = [];
//       notifyListeners();
//       return;
//     }

//     _isLoading = true;
//     notifyListeners();

//     try {
//       final wines = await _service.fetchCellar(_userId!, _token!);
//       _wines = wines;
//       await StorageHelper.saveCellarWines(_userId!, _wines);
//     } catch (e) {
//       print('Error fetching from backend, using cache: $e');
//       _wines = await StorageHelper.getCellarWines(_userId!);
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> addWine(WineModel wine) async {
//     if (_userId == null || _token == null) {
//       throw Exception('User not authenticated');
//     }

//     final user = await StorageHelper.getUser();
//     if (user?.plan != 'PRO' && _wines.length >= maxFreeBottles) {
//       throw Exception('PLAN_LIMIT_EXCEEDED');
//     }

//     try {
//       await _service.addWine(wine, _userId!, _token!);
//       await loadWines();
//       return true;
//     } catch (e) {
//       print('Error adding wine: $e');
//       rethrow;
//     }
//   }

//   Future<bool> updateWine(WineModel wine) async {
//     if (_userId == null || _token == null) return false;

//     try {
//       await _service.updateWine(wine, _userId!, _token!);
//       await loadWines();
//       return true;
//     } catch (e) {
//       print('Error updating wine: $e');
//       return false;
//     }
//   }

//   Future<bool> deleteWine(String wineId) async {
//     if (_userId == null || _token == null) return false;

//     try {
//       await _service.deleteWine(wineId, _userId!, _token!);
//       await loadWines();
//       return true;
//     } catch (e) {
//       print('Error deleting wine: $e');
//       return false;
//     }
//   }

//   Future<void> refreshAfterLogin() async {
//     final user = await StorageHelper.getUser();
//     if (user != null) {
//       _userId = user.userId;
//       _token = await StorageHelper.getToken();
//       await loadWines();
//     }
//   }

//   // ==================== WINE UPLOAD METHODS ====================
  
//   /// Step 1: Get presigned URL for upload
//   Future<PresignedUploadResponse> getPresignedUrl({
//     required String filename,
//     required String contentType,
//     required String sessionId,
//   }) async {
//     if (_userId == null) {
//       throw Exception('User not authenticated');
//     }
    
//     final dio = _createDio();
    
//     try {
//       print('📤 Getting presigned URL for wine upload...');
//       print('🔑 Session ID: $sessionId');
      
//       final response = await dio.post(
//         ApiEndpoints.presignUpload,
//         data: jsonEncode({
//           'upload_type': 'cellar',
//           'user_id': _userId,
//           'session_id': sessionId,
//           'filename': filename,
//           'content_type': contentType,
//         }),
//       );

//       print('📥 Presign response status: ${response.statusCode}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = response.data;
//         final uploadUrl = data['data']?['upload_url'] ?? data['upload_url'];
//         final fileKey = data['data']?['file_key'] ?? data['file_key'];
        
//         if (uploadUrl == null || fileKey == null) {
//           throw Exception('Invalid response from server');
//         }
        
//         return PresignedUploadResponse(
//           uploadUrl: uploadUrl,
//           fileKey: fileKey,
//         );
//       } else {
//         throw Exception('Failed to get presigned URL: ${response.statusCode}');
//       }
//     } on DioException catch (e) {
//       print('❌ Presign error: ${e.message}');
//       if (e.response != null) {
//         print('Response data: ${e.response?.data}');
//         print('Response status: ${e.response?.statusCode}');
//       }
//       throw Exception('Server error: ${e.response?.statusCode ?? e.message}');
//     }
//   }

//   /// Step 2: Upload file directly to S3 using presigned URL
//   Future<void> uploadToS3(String uploadUrl, Uint8List fileBytes, String contentType) async {
//     try {
//       print('📤 Uploading to S3...');
      
//       final response = await Dio().put(
//         uploadUrl,
//         data: Stream.fromIterable(fileBytes.map((e) => [e])),
//         options: Options(
//           headers: {
//             'Content-Type': contentType,
//           },
//           contentType: contentType,
//         ),
//       );

//       print('📥 S3 upload status: ${response.statusCode}');

//       if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
//         throw Exception('Failed to upload to S3: ${response.statusCode}');
//       }
      
//       print('✅ File uploaded to S3 successfully');
//     } catch (e) {
//       print('❌ S3 upload error: $e');
//       throw Exception('Failed to upload image to storage');
//     }
//   }

//   /// Step 3: Send file_key to chat endpoint for analysis
//   Future<Map<String, dynamic>> analyzeWine({
//     required String fileKey,
//     required String message,
//     required String sessionId,
//   }) async {
//     if (_userId == null) {
//       throw Exception('User not authenticated');
//     }
    
//     final dio = _createDio();
    
//     try {
//       print('📤 Analyzing wine with file_key: $fileKey');
//       print('🔑 Session ID: $sessionId');
      
//       final response = await dio.post(
//         ApiEndpoints.chat,
//         data: jsonEncode({
//           'mode': 'cellar',
//           'user_id': _userId,
//           'session_id': sessionId,
//           'message': message,
//           'file_key': fileKey,
//         }),
//       );

//       print('📥 Analysis response status: ${response.statusCode}');
//       print('📥 Response data: ${response.data}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final parsed = _parseChatResponse(response.data);
//         print('📊 Parsed result: $parsed');
//         return parsed;
//       } else {
//         throw Exception('Analysis failed: ${response.statusCode}');
//       }
//     } on DioException catch (e) {
//       print('❌ Analysis error: ${e.message}');
//       if (e.response != null) {
//         print('Response data: ${e.response?.data}');
//       }
//       throw Exception('Server error: ${e.response?.statusCode ?? e.message}');
//     }
//   }

//   /// ✅ CORRECTED: Parse chat response according to actual API structure
//   Map<String, dynamic> _parseChatResponse(dynamic data) {
//     final Map<String, dynamic> result = {};

//     try {
//       if (data is Map) {
//         print('🔍 Parsing response structure: ${data.keys}');
        
//         // ✅ CORRECT PATH: data -> data -> state_summary -> pending_wine -> current_fields
//         final responseData = data['data'];
//         if (responseData != null && responseData is Map) {
//           final stateSummary = responseData['state_summary'];
//           if (stateSummary != null && stateSummary is Map) {
//             final pendingWine = stateSummary['pending_wine'];
//             if (pendingWine != null && pendingWine is Map) {
//               final fields = pendingWine['current_fields'];
//               if (fields != null && fields is Map) {
//                 result['wine'] = _extractWineData(fields);
//                 print('✅ Extracted wine data from pending_wine');
//               }
              
//               // Get wine_id
//               if (pendingWine.containsKey('wine_id')) {
//                 result['wine_id'] = pendingWine['wine_id'].toString();
//               }
//             }
//           }
          
//           // Get status
//           final metadata = responseData['metadata'];
//           if (metadata != null && metadata is Map) {
//             final status = metadata['status'];
//             result['status'] = status;
//             print('📊 Status: $status');
            
//             if (status == 'awaiting_confirmation') {
//               result['awaiting_confirmation'] = true;
//             }
//           }
//         }
        
//         // Get message from various possible locations
//         result['message'] = data['answer'] ?? 
//             data['message'] ?? 
//             data['data']?['metadata']?['status'] ??
//             'Processing complete';
        
//         result['success'] = true;
//       }
//     } catch (e) {
//       print('❌ Error parsing chat response: $e');
//       result['success'] = false;
//       result['error'] = e.toString();
//     }
    
//     return result;
//   }

//   Map<String, dynamic> _extractWineData(Map data) {
//     print('📦 Extracting wine data from fields: ${data.keys}');
    
//     return {
//       'wine_name': data['wine_name']?.toString() ?? '',
//       'grape': data['grape']?.toString() ?? '',
//       'year': data['year']?.toString() ?? data['vintage_year']?.toString() ?? '',
//       'country': data['country']?.toString() ?? '',
//       'region': data['region']?.toString() ?? '',
//       'wine_type': data['wine_type']?.toString() ?? '',
//       'alcohol_percent': data['alcohol_percent']?.toString(),
//       'volume_ml': data['volume_ml']?.toString(),
//     };
//   }

//   /// Complete flow: Get presign -> Upload to S3 -> Analyze
//   Future<WineAnalysisResult> uploadAndAnalyzeWine({
//     required String filename,
//     required Uint8List fileBytes,
//     required String contentType,
//   }) async {
//     if (_userId == null) {
//       throw Exception('User not authenticated');
//     }
    
//     _isLoading = true;
//     notifyListeners();
    
//     try {
//       // Create ONE sessionId for the entire flow
//       final sessionId = 'cellar_${DateTime.now().millisecondsSinceEpoch}';
//       print('🚀 Starting complete wine upload flow with sessionId: $sessionId');
      
//       // Step 1: Get presigned URL
//       final presignResponse = await getPresignedUrl(
//         filename: filename,
//         contentType: contentType,
//         sessionId: sessionId,
//       );
      
//       // Step 2: Upload to S3
//       await uploadToS3(presignResponse.uploadUrl, fileBytes, contentType);
      
//       // Step 3: Analyze the wine
//       final analysisResult = await analyzeWine(
//         fileKey: presignResponse.fileKey,
//         message: 'Quero cadastrar esse vinho.',
//         sessionId: sessionId,
//       );
      
//       print('✅ Wine analysis completed successfully');
//       print('📊 Analysis result to save: $analysisResult');
      
//       // ✅ IMPORTANT: Save the parsed result to storage
//       await StorageHelper.saveWineResult(analysisResult);
      
//       return WineAnalysisResult(
//         success: true,
//         wineData: analysisResult['wine'],
//         message: analysisResult['message'],
//         wineId: analysisResult['wine_id'],
//         fileKey: presignResponse.fileKey,
//       );
//     } catch (e) {
//       print('❌ Upload and analyze error: $e');
//       return WineAnalysisResult(
//         success: false,
//         error: e.toString(),
//       );
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   /// Confirm pending wine (after user reviews/edits)
//   Future<Map<String, dynamic>> confirmPendingWine({
//     required String message,
//   }) async {
//     if (_userId == null) {
//       throw Exception('User not authenticated');
//     }
    
//     final dio = _createDio();
//     final sessionId = 'cellar_${DateTime.now().millisecondsSinceEpoch}';
    
//     _isLoading = true;
//     notifyListeners();
    
//     try {
//       print('📤 Confirming pending wine with sessionId: $sessionId');
//       print('📤 Message: $message');
      
//       final response = await dio.post(
//         ApiEndpoints.chat,
//         data: jsonEncode({
//           'mode': 'cellar',
//           'user_id': _userId,
//           'session_id': sessionId,
//           'message': message,
//         }),
//       );
      
//       print('📥 Confirm response status: ${response.statusCode}');
//       print('📥 Confirm response data: ${response.data}');
      
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final result = _parseChatResponse(response.data);
//         print('📊 Parsed confirm result: $result');
        
//         if (result['success'] != false) {
//           await loadWines();
//         }
//         return result;
//       }
//       return {};
//     } catch (e) {
//       print('Error confirming wine: $e');
//       rethrow;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   /// Cancel pending wine upload
//   Future<Map<String, dynamic>> cancelPendingWine() async {
//     if (_userId == null) {
//       throw Exception('User not authenticated');
//     }
    
//     final dio = _createDio();
//     final sessionId = 'cellar_${DateTime.now().millisecondsSinceEpoch}';
    
//     _isLoading = true;
//     notifyListeners();
    
//     try {
//       print('📤 Canceling pending wine upload with sessionId: $sessionId');
      
//       final response = await dio.post(
//         ApiEndpoints.chat,
//         data: jsonEncode({
//           'mode': 'cellar',
//           'user_id': _userId,
//           'session_id': sessionId,
//           'message': 'Cancelar cadastro.',
//         }),
//       );
      
//       print('📥 Cancel response status: ${response.statusCode}');
      
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final result = _parseChatResponse(response.data);
//         print('✅ Wine upload canceled');
//         return result;
//       }
//       return {};
//     } catch (e) {
//       print('Error canceling wine: $e');
//       rethrow;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // ==================== FILTER METHODS ====================
  
//   List<String> getUniqueCountries() {
//     return _wines
//         .map((w) => w.country)
//         .where((c) => c.isNotEmpty)
//         .toSet()
//         .toList()
//       ..sort();
//   }

//   List<String> getUniqueWineTypes() {
//     final types = _wines
//         .map((w) => w.wineType)
//         .where((t) => t.isNotEmpty)
//         .toSet()
//         .toList();
    
//     const order = ['red', 'white', 'rose', 'sparkling'];
//     types.sort((a, b) {
//       final indexA = order.indexOf(a);
//       final indexB = order.indexOf(b);
//       if (indexA == -1 && indexB == -1) return a.compareTo(b);
//       if (indexA == -1) return 1;
//       if (indexB == -1) return -1;
//       return indexA.compareTo(indexB);
//     });
//     return types;
//   }

//   List<WineModel> filterWines({
//     String? country,
//     String? wineType,
//     String? searchQuery,
//     String? sortBy,
//   }) {
//     var filtered = List<WineModel>.from(_wines);

//     if (country != null && country.isNotEmpty && country != 'all') {
//       filtered = filtered.where((w) => w.country == country).toList();
//     }

//     if (wineType != null && wineType.isNotEmpty && wineType != 'all') {
//       filtered = filtered.where((w) => w.wineType == wineType).toList();
//     }

//     if (searchQuery != null && searchQuery.isNotEmpty) {
//       final query = searchQuery.toLowerCase();
//       filtered = filtered.where((w) =>
//         w.name.toLowerCase().contains(query) ||
//         w.grape.toLowerCase().contains(query) ||
//         w.region.toLowerCase().contains(query)
//       ).toList();
//     }

//     if (sortBy == 'name-az') {
//       filtered.sort((a, b) => a.name.compareTo(b.name));
//     } else if (sortBy == 'year-desc') {
//       filtered.sort((a, b) => b.year.compareTo(a.year));
//     }

//     return filtered;
//   }
// }

// // ==================== HELPER CLASSES ====================

// class PresignedUploadResponse {
//   final String uploadUrl;
//   final String fileKey;
  
//   PresignedUploadResponse({
//     required this.uploadUrl,
//     required this.fileKey,
//   });
// }

// class WineAnalysisResult {
//   final bool success;
//   final Map<String, dynamic>? wineData;
//   final String? message;
//   final String? wineId;
//   final String? fileKey;
//   final String? error;
  
//   WineAnalysisResult({
//     required this.success,
//     this.wineData,
//     this.message,
//     this.wineId,
//     this.fileKey,
//     this.error,
//   });
// } 



import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/wine_model.dart';
import '../services/cellar_service.dart';
import '../../core/utils/storage_helper.dart';
import '../../core/constants/api_endpoints.dart';

class CellarProvider extends ChangeNotifier {
  List<WineModel> _wines = [];
  String? _userId;
  String? _token;
  bool _isLoading = false;
  static const int maxFreeBottles = 6;
  final CellarService _service = CellarService();
  
  /// ✅ Create Dio instance with headers for your backend
  Dio _createBackendDio() {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
    
    return Dio(BaseOptions(
      headers: headers,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }
  
  /// ✅ Create Dio instance for API Gateway (Chat API)
  Dio _createApiGatewayDio() {
    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': ApiEndpoints.chatApiKey,
      'Authorization': 'Bearer ${ApiEndpoints.chatApiKey}',
      'Accept': 'application/json',
    };
    
    return Dio(BaseOptions(
      headers: headers,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  List<WineModel> get wines => _wines;
  int get wineCount => _wines.length;
  int get remainingFreeSpots => maxFreeBottles - _wines.length;
  bool get canAddMore => _wines.length < maxFreeBottles;
  bool get isLoading => _isLoading;

  CellarProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final user = await StorageHelper.getUser();
    if (user != null) {
      _userId = user.userId;
      _token = await StorageHelper.getToken();
      await loadWines();
    }
  }

  Future<void> loadWines() async {
    if (_userId == null || _token == null) {
      _wines = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final wines = await _service.fetchCellar(_userId!, _token!);
      _wines = wines;
      await StorageHelper.saveCellarWines(_userId!, _wines);
    } catch (e) {
      print('Error fetching from backend, using cache: $e');
      _wines = await StorageHelper.getCellarWines(_userId!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Save the entire cellar to backend using POST (no PUT)
  Future<bool> _saveCellarToBackend(List<WineModel> bottles) async {
    try {
      final dio = _createBackendDio();
      final response = await dio.post(
        ApiEndpoints.addWine, // POST /cellar
        data: {
          "bottles": bottles.map((w) => w.toJson()).toList(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Cellar saved to backend successfully');
        return true;
      }
      print('❌ Failed to save cellar: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Error saving cellar to backend: $e');
      return false;
    }
  }

  /// ✅ FIXED: Add wine - send full list with new wine
  Future<bool> addWine(WineModel wine) async {
    if (_userId == null || _token == null) {
      throw Exception('User not authenticated');
    }

    final user = await StorageHelper.getUser();
    if (user?.plan != 'PRO' && _wines.length >= maxFreeBottles) {
      throw Exception('PLAN_LIMIT_EXCEEDED');
    }

    try {
      // Create new list with added wine
      final updatedBottles = [..._wines, wine];
      
      // Send full list to backend using POST
      final success = await _saveCellarToBackend(updatedBottles);
      
      if (success) {
        _wines = updatedBottles;
        await StorageHelper.saveCellarWines(_userId!, _wines);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding wine: $e');
      rethrow;
    }
  }

  /// ✅ FIXED: Update wine - send full list with updated wine (no PUT)
  Future<bool> updateWine(WineModel updatedWine) async {
    if (_userId == null || _token == null) return false;

    try {
      // Find and replace the updated wine in the list
      final updatedBottles = _wines.map((wine) {
        if (wine.id == updatedWine.id) {
          return updatedWine;
        }
        return wine;
      }).toList();

      // Send full list to backend using POST
      final success = await _saveCellarToBackend(updatedBottles);
      
      if (success) {
        _wines = updatedBottles;
        await StorageHelper.saveCellarWines(_userId!, _wines);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating wine: $e');
      return false;
    }
  }

  /// ✅ FIXED: Delete wine - send full list without the deleted wine
  Future<bool> deleteWine(String wineId) async {
    if (_userId == null || _token == null) return false;

    try {
      // Remove the wine from the list
      final updatedBottles = _wines.where((w) => w.id != wineId).toList();

      // Send full list to backend using POST
      final success = await _saveCellarToBackend(updatedBottles);
      
      if (success) {
        _wines = updatedBottles;
        await StorageHelper.saveCellarWines(_userId!, _wines);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting wine: $e');
      return false;
    }
  }

  Future<void> refreshAfterLogin() async {
    final user = await StorageHelper.getUser();
    if (user != null) {
      _userId = user.userId;
      _token = await StorageHelper.getToken();
      await loadWines();
    }
  }

  // ==================== WINE UPLOAD METHODS (API Gateway) ====================
  
  /// Step 1: Get presigned URL for upload
  Future<PresignedUploadResponse> getPresignedUrl({
    required String filename,
    required String contentType,
    required String sessionId,
  }) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
    
    final dio = _createApiGatewayDio();
    
    try {
      print('📤 Getting presigned URL for wine upload...');
      print('🔑 Session ID: $sessionId');
      
      final response = await dio.post(
        ApiEndpoints.presignUpload,
        data: jsonEncode({
          'upload_type': 'cellar',
          'user_id': _userId,
          'session_id': sessionId,
          'filename': filename,
          'content_type': contentType,
        }),
      );

      print('📥 Presign response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final uploadUrl = data['data']?['upload_url'] ?? data['upload_url'];
        final fileKey = data['data']?['file_key'] ?? data['file_key'];
        
        if (uploadUrl == null || fileKey == null) {
          throw Exception('Invalid response from server');
        }
        
        return PresignedUploadResponse(
          uploadUrl: uploadUrl,
          fileKey: fileKey,
        );
      } else {
        throw Exception('Failed to get presigned URL: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Presign error: ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
        print('Response status: ${e.response?.statusCode}');
      }
      throw Exception('Server error: ${e.response?.statusCode ?? e.message}');
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
    required String fileKey,
    required String message,
    required String sessionId,
  }) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
    
    final dio = _createApiGatewayDio();
    
    try {
      print('📤 Analyzing wine with file_key: $fileKey');
      print('🔑 Session ID: $sessionId');
      
      final response = await dio.post(
        ApiEndpoints.chat,
        data: jsonEncode({
          'mode': 'cellar',
          'user_id': _userId,
          'session_id': sessionId,
          'message': message,
          'file_key': fileKey,
        }),
      );

      print('📥 Analysis response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsed = _parseChatResponse(response.data);
        print('📊 Parsed result: $parsed');
        return parsed;
      } else {
        throw Exception('Analysis failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Analysis error: ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response?.data}');
      }
      throw Exception('Server error: ${e.response?.statusCode ?? e.message}');
    }
  }

  /// Parse chat response according to actual API structure
  Map<String, dynamic> _parseChatResponse(dynamic data) {
    final Map<String, dynamic> result = {};

    try {
      if (data is Map) {
        print('🔍 Parsing response structure: ${data.keys}');
        
        final responseData = data['data'];
        if (responseData != null && responseData is Map) {
          final stateSummary = responseData['state_summary'];
          if (stateSummary != null && stateSummary is Map) {
            final pendingWine = stateSummary['pending_wine'];
            if (pendingWine != null && pendingWine is Map) {
              final fields = pendingWine['current_fields'];
              if (fields != null && fields is Map) {
                result['wine'] = _extractWineData(fields);
                print('✅ Extracted wine data from pending_wine');
              }
              
              if (pendingWine.containsKey('wine_id')) {
                result['wine_id'] = pendingWine['wine_id'].toString();
              }
            }
          }
          
          final metadata = responseData['metadata'];
          if (metadata != null && metadata is Map) {
            final status = metadata['status'];
            result['status'] = status;
            print('📊 Status: $status');
            
            if (status == 'awaiting_confirmation') {
              result['awaiting_confirmation'] = true;
            }
          }
        }
        
        result['message'] = data['answer'] ?? 
            data['message'] ?? 
            data['data']?['metadata']?['status'] ??
            'Processing complete';
        
        result['success'] = true;
      }
    } catch (e) {
      print('❌ Error parsing chat response: $e');
      result['success'] = false;
      result['error'] = e.toString();
    }
    
    return result;
  }

  Map<String, dynamic> _extractWineData(Map data) {
    print('📦 Extracting wine data from fields: ${data.keys}');
    
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

  /// Complete flow: Get presign -> Upload to S3 -> Analyze
  Future<WineAnalysisResult> uploadAndAnalyzeWine({
    required String filename,
    required Uint8List fileBytes,
    required String contentType,
  }) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final sessionId = 'cellar_${DateTime.now().millisecondsSinceEpoch}';
      print('🚀 Starting complete wine upload flow with sessionId: $sessionId');
      
      final presignResponse = await getPresignedUrl(
        filename: filename,
        contentType: contentType,
        sessionId: sessionId,
      );
      
      await uploadToS3(presignResponse.uploadUrl, fileBytes, contentType);
      
      final analysisResult = await analyzeWine(
        fileKey: presignResponse.fileKey,
        message: 'Quero cadastrar esse vinho.',
        sessionId: sessionId,
      );
      
      print('✅ Wine analysis completed successfully');
      
      await StorageHelper.saveWineResult(analysisResult);
      
      return WineAnalysisResult(
        success: true,
        wineData: analysisResult['wine'],
        message: analysisResult['message'],
        wineId: analysisResult['wine_id'],
        fileKey: presignResponse.fileKey,
      );
    } catch (e) {
      print('❌ Upload and analyze error: $e');
      return WineAnalysisResult(
        success: false,
        error: e.toString(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Confirm pending wine (after user reviews/edits)
  Future<Map<String, dynamic>> confirmPendingWine({
    required String message,
  }) async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
    
    final dio = _createApiGatewayDio();
    final sessionId = 'cellar_${DateTime.now().millisecondsSinceEpoch}';
    
    _isLoading = true;
    notifyListeners();
    
    try {
      print('📤 Confirming pending wine with sessionId: $sessionId');
      
      final response = await dio.post(
        ApiEndpoints.chat,
        data: jsonEncode({
          'mode': 'cellar',
          'user_id': _userId,
          'session_id': sessionId,
          'message': message,
        }),
      );
      
      print('📥 Confirm response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = _parseChatResponse(response.data);
        print('📊 Parsed confirm result: $result');
        
        if (result['success'] != false) {
          await loadWines();
        }
        return result;
      }
      return {};
    } catch (e) {
      print('Error confirming wine: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancel pending wine upload
  Future<Map<String, dynamic>> cancelPendingWine() async {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }
    
    final dio = _createApiGatewayDio();
    final sessionId = 'cellar_${DateTime.now().millisecondsSinceEpoch}';
    
    _isLoading = true;
    notifyListeners();
    
    try {
      print('📤 Canceling pending wine upload with sessionId: $sessionId');
      
      final response = await dio.post(
        ApiEndpoints.chat,
        data: jsonEncode({
          'mode': 'cellar',
          'user_id': _userId,
          'session_id': sessionId,
          'message': 'Cancelar cadastro.',
        }),
      );
      
      print('📥 Cancel response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = _parseChatResponse(response.data);
        print('✅ Wine upload canceled');
        return result;
      }
      return {};
    } catch (e) {
      print('Error canceling wine: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== FILTER METHODS ====================
  
  List<String> getUniqueCountries() {
    return _wines
        .map((w) => w.country)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> getUniqueWineTypes() {
    final types = _wines
        .map((w) => w.wineType)
        .where((t) => t.isNotEmpty)
        .toSet()
        .toList();
    
    const order = ['red', 'white', 'rose', 'sparkling'];
    types.sort((a, b) {
      final indexA = order.indexOf(a);
      final indexB = order.indexOf(b);
      if (indexA == -1 && indexB == -1) return a.compareTo(b);
      if (indexA == -1) return 1;
      if (indexB == -1) return -1;
      return indexA.compareTo(indexB);
    });
    return types;
  }

  List<WineModel> filterWines({
    String? country,
    String? wineType,
    String? searchQuery,
    String? sortBy,
  }) {
    var filtered = List<WineModel>.from(_wines);

    if (country != null && country.isNotEmpty && country != 'all') {
      filtered = filtered.where((w) => w.country == country).toList();
    }

    if (wineType != null && wineType.isNotEmpty && wineType != 'all') {
      filtered = filtered.where((w) => w.wineType == wineType).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((w) =>
        w.name.toLowerCase().contains(query) ||
        w.grape.toLowerCase().contains(query) ||
        w.region.toLowerCase().contains(query)
      ).toList();
    }

    if (sortBy == 'name-az') {
      filtered.sort((a, b) => a.name.compareTo(b.name));
    } else if (sortBy == 'year-desc') {
      filtered.sort((a, b) => b.year.compareTo(a.year));
    }

    return filtered;
  }
}

// ==================== HELPER CLASSES ====================

class PresignedUploadResponse {
  final String uploadUrl;
  final String fileKey;
  
  PresignedUploadResponse({
    required this.uploadUrl,
    required this.fileKey,
  });
}

class WineAnalysisResult {
  final bool success;
  final Map<String, dynamic>? wineData;
  final String? message;
  final String? wineId;
  final String? fileKey;
  final String? error;
  
  WineAnalysisResult({
    required this.success,
    this.wineData,
    this.message,
    this.wineId,
    this.fileKey,
    this.error,
  });
}
