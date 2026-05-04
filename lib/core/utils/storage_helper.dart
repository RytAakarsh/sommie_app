// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'dart:convert';
// import '../../data/models/user_model.dart';
// import '../../data/models/chat_session.dart';
// import '../../data/models/wine_model.dart';

// class StorageHelper {
//   static const _storage = FlutterSecureStorage();
  
//   static const String _tokenKey = 'auth_token';
//   static const String _userKey = 'user_data';
//   static const String _profileKey = 'user_profile';
//   static const String _chatSessionsPrefix = 'sommie_chat_';
//   static const String _cellarCacheKey = 'sommie_cellar_cache';



// static Future<void> removeToken() async {
//   await _storage.delete(key: _tokenKey);
// }

// static Future<void> removeUser() async {
//   await _storage.delete(key: _userKey);
// }

//   // Token methods
//   static Future<void> saveToken(String token) async {
//     await _storage.write(key: _tokenKey, value: token);
//     print('✅ Token saved');
//   }

//   static Future<String?> getToken() async {
//     final token = await _storage.read(key: _tokenKey);
//     print('🔑 Token retrieved: ${token != null ? 'Yes' : 'No'}');
//     return token;
//   }

//   // User methods
//   static Future<void> saveUser(UserModel user) async {
//     await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
//     print('✅ User saved: ${user.name} - Avatar: ${user.avatar}');
//   }

//   static Future<UserModel?> getUser() async {
//     final userString = await _storage.read(key: _userKey);
//     if (userString != null) {
//       try {
//         final user = UserModel.fromJson(jsonDecode(userString));
//         print('✅ User loaded: ${user.name} - Avatar: ${user.avatar}');
//         return user;
//       } catch (e) {
//         print('❌ Error parsing user: $e');
//         return null;
//       }
//     }
//     print('❌ No user found');
//     return null;
//   }

//   // Profile methods
//   static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
//     await _storage.write(key: _profileKey, value: jsonEncode(profile));
//     print('✅ Profile saved: ${profile['name']} - Avatar: ${profile['avatar']}');
//   }

//   static Future<Map<String, dynamic>?> getUserProfile() async {
//     final profileString = await _storage.read(key: _profileKey);
//     if (profileString != null) {
//       try {
//         final profile = jsonDecode(profileString);
//         print('✅ Profile loaded - Avatar: ${profile['avatar']}');
//         return profile;
//       } catch (e) {
//         print('❌ Error parsing profile: $e');
//         return null;
//       }
//     }
//     print('❌ No profile found');
//     return null;
//   }

//   // Chat sessions methods
//   static Future<void> saveChatSessions(String userId, List<ChatSession> sessions) async {
//     final sessionsJson = sessions.map((s) => s.toJson()).toList();
//     await _storage.write(
//       key: '$_chatSessionsPrefix$userId',
//       value: jsonEncode(sessionsJson),
//     );
//     print('✅ Saved ${sessions.length} chat sessions for user $userId');
//   }

//   static Future<List<ChatSession>> getChatSessions(String userId) async {
//     final sessionsString = await _storage.read(key: '$_chatSessionsPrefix$userId');
//     if (sessionsString != null) {
//       try {
//         final List<dynamic> sessionsJson = jsonDecode(sessionsString);
//         final sessions = sessionsJson.map((j) => ChatSession.fromJson(j)).toList();
//         print('✅ Loaded ${sessions.length} chat sessions for user $userId');
//         return sessions;
//       } catch (e) {
//         print('❌ Error parsing chat sessions: $e');
//         return [];
//       }
//     }
//     print('❌ No chat sessions found for user $userId');
//     return [];
//   }

//   // Cellar methods
//   static Future<void> saveCellarWines(String userId, List<WineModel> wines) async {
//     final cacheString = await _storage.read(key: _cellarCacheKey);
//     final Map<String, dynamic> cache = cacheString != null
//         ? jsonDecode(cacheString)
//         : {};
    
//     cache[userId] = wines.map((w) => w.toJson()).toList();
//     await _storage.write(key: _cellarCacheKey, value: jsonEncode(cache));
//     print('✅ Saved ${wines.length} wines for user $userId');
    
//     // Verify save
//     if (wines.isNotEmpty) {
//       print('✅ First wine saved: ${wines.first.name}');
//     }
//   }

//   static Future<List<WineModel>> getCellarWines(String userId) async {
//     final cacheString = await _storage.read(key: _cellarCacheKey);
//     if (cacheString != null) {
//       try {
//         final Map<String, dynamic> cache = jsonDecode(cacheString);
//         final winesJson = cache[userId] as List? ?? [];
//         final wines = winesJson.map((j) => WineModel.fromJson(j)).toList();
//         print('✅ Loaded ${wines.length} wines for user $userId');
//         if (wines.isNotEmpty) {
//           print('✅ First wine: ${wines.first.name}');
//         }
//         return wines;
//       } catch (e) {
//         print('❌ Error parsing cellar wines: $e');
//         return [];
//       }
//     }
//     print('❌ No wines found for user $userId');
//     return [];
//   }

//   // Wine upload methods
//   static Future<void> saveWineUpload(Map<String, dynamic> uploadData) async {
//     await _storage.write(key: 'sommie_wine_upload', value: jsonEncode(uploadData));
//   }

//   static Future<Map<String, dynamic>?> getWineUpload() async {
//     final uploadString = await _storage.read(key: 'sommie_wine_upload');
//     if (uploadString != null) {
//       return jsonDecode(uploadString);
//     }
//     return null;
//   }

//   static Future<void> saveWineResult(Map<String, dynamic> resultData) async {
//     await _storage.write(key: 'sommie_wine_result', value: jsonEncode(resultData));
//   }

//   static Future<Map<String, dynamic>?> getWineResult() async {
//     final resultString = await _storage.read(key: 'sommie_wine_result');
//     if (resultString != null) {
//       return jsonDecode(resultString);
//     }
//     return null;
//   }

//   static Future<void> clearAll() async {
//     await _storage.deleteAll();
//     print('✅ All storage cleared');
//   }
// }

//  import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//  import 'dart:convert';
//  import '../../data/models/user_model.dart';
//  import '../../data/models/chat_session.dart';
//  import '../../data/models/wine_model.dart';

// class StorageHelper {
//   static const _storage = FlutterSecureStorage();
  
//   static const String _tokenKey = 'auth_token';
//   static const String _userKey = 'user_data';
//   static const String _profileKey = 'user_profile';
//   static const String _chatSessionsPrefix = 'sommie_chat_';
//   static const String _cellarCacheKey = 'sommie_cellar_cache';

//   // Token methods
//   static Future<void> saveToken(String token) async {
//     await _storage.write(key: _tokenKey, value: token);
//     print('✅ Token saved');
//   }

//   static Future<String?> getToken() async {
//     return await _storage.read(key: _tokenKey);
//   }

//   static Future<void> removeToken() async {
//     await _storage.delete(key: _tokenKey);
//     print('✅ Token removed');
//   }

//   // User methods
//   static Future<void> saveUser(UserModel user) async {
//     await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
//     print('✅ User saved: ${user.name} - Plan: ${user.plan} - Avatar: ${user.avatar}');
//   }

//   static Future<UserModel?> getUser() async {
//     final userString = await _storage.read(key: _userKey);
//     if (userString != null) {
//       try {
//         final user = UserModel.fromJson(jsonDecode(userString));
//         print('✅ User loaded: ${user.name} - Plan: ${user.plan} - Avatar: ${user.avatar}');
//         return user;
//       } catch (e) {
//         print('❌ Error parsing user: $e');
//         return null;
//       }
//     }
//     return null;
//   }

//   static Future<void> removeUser() async {
//     await _storage.delete(key: _userKey);
//     print('✅ User removed');
//   }

//   // Profile methods
//   static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
//     await _storage.write(key: _profileKey, value: jsonEncode(profile));
//     print('✅ Profile saved: ${profile['name']} - Avatar: ${profile['avatar']}');
//   }

//   static Future<Map<String, dynamic>?> getUserProfile() async {
//     final profileString = await _storage.read(key: _profileKey);
//     if (profileString != null) {
//       try {
//         return jsonDecode(profileString);
//       } catch (e) {
//         print('❌ Error parsing profile: $e');
//         return null;
//       }
//     }
//     return null;
//   }

//   // Chat sessions methods
//   static Future<void> saveChatSessions(String userId, List<ChatSession> sessions) async {
//     final sessionsJson = sessions.map((s) => s.toJson()).toList();
//     await _storage.write(
//       key: '$_chatSessionsPrefix$userId',
//       value: jsonEncode(sessionsJson),
//     );
//     print('✅ Saved ${sessions.length} chat sessions for user $userId');
//   }

//   static Future<List<ChatSession>> getChatSessions(String userId) async {
//     final sessionsString = await _storage.read(key: '$_chatSessionsPrefix$userId');
//     if (sessionsString != null) {
//       try {
//         final List<dynamic> sessionsJson = jsonDecode(sessionsString);
//         return sessionsJson.map((j) => ChatSession.fromJson(j)).toList();
//       } catch (e) {
//         print('❌ Error parsing chat sessions: $e');
//         return [];
//       }
//     }
//     return [];
//   }

//   // Cellar methods
//   static Future<void> saveCellarWines(String userId, List<WineModel> wines) async {
//     final cacheString = await _storage.read(key: _cellarCacheKey);
//     final Map<String, dynamic> cache = cacheString != null
//         ? jsonDecode(cacheString)
//         : {};
    
//     cache[userId] = wines.map((w) => w.toJson()).toList();
//     await _storage.write(key: _cellarCacheKey, value: jsonEncode(cache));
//     print('✅ Saved ${wines.length} wines for user $userId');
//   }

//   static Future<List<WineModel>> getCellarWines(String userId) async {
//     final cacheString = await _storage.read(key: _cellarCacheKey);
//     if (cacheString != null) {
//       try {
//         final Map<String, dynamic> cache = jsonDecode(cacheString);
//         final winesJson = cache[userId] as List? ?? [];
//         return winesJson.map((j) => WineModel.fromJson(j)).toList();
//       } catch (e) {
//         print('❌ Error parsing cellar wines: $e');
//         return [];
//       }
//     }
//     return [];
//   }

//   // Wine upload methods
//   static Future<void> saveWineUpload(Map<String, dynamic> uploadData) async {
//     await _storage.write(key: 'sommie_wine_upload', value: jsonEncode(uploadData));
//   }

//   static Future<Map<String, dynamic>?> getWineUpload() async {
//     final uploadString = await _storage.read(key: 'sommie_wine_upload');
//     if (uploadString != null) {
//       return jsonDecode(uploadString);
//     }
//     return null;
//   }

//   static Future<void> saveWineResult(Map<String, dynamic> resultData) async {
//     await _storage.write(key: 'sommie_wine_result', value: jsonEncode(resultData));
//   }

//   static Future<Map<String, dynamic>?> getWineResult() async {
//     final resultString = await _storage.read(key: 'sommie_wine_result');
//     if (resultString != null) {
//       return jsonDecode(resultString);
//     }
//     return null;
//   }

//   static Future<void> clearAll() async {
//     await _storage.deleteAll();
//     print('✅ All storage cleared');
//   }
// }



import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/user_model.dart';
import '../../data/models/wine_model.dart';
import '../../data/models/chat_session.dart';

class StorageHelper {
  static const String _tokenKey = 'sommie_token';
  static const String _userKey = 'sommie_user';
  static const String _stableUserIdKey = 'sommie_stable_user_id';
  
  // Profile storage with user-specific keys
  static String _profileKey(String userId) => 'sommie_profile_$userId';
  static String _chatKey(String userId) => 'sommie_chat_$userId';
  static String _cellarKey(String userId) => 'sommie_cellar_$userId';
  
  // Temporary storage for wine upload
  static const String _wineUploadKey = 'sommie_wine_upload';
  static const String _wineResultKey = 'sommie_wine_result';

  // Token methods
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // User methods
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    
    // Save stable user ID
    if (user.userId.isNotEmpty) {
      await prefs.setString(_stableUserIdKey, user.userId);
    }
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr == null) return null;
    
    try {
      final json = jsonDecode(userStr);
      return UserModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  static Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  static Future<String?> getStableUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_stableUserIdKey);
  }

  // Profile methods
  static Future<void> saveUserProfile(String userId, Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey(userId), jsonEncode(profile));
  }

  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final profileStr = prefs.getString(_profileKey(userId));
    if (profileStr == null) return null;
    
    try {
      return jsonDecode(profileStr);
    } catch (e) {
      return null;
    }
  }

  // Chat session methods
  static Future<void> saveChatSessions(String userId, List<ChatSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_chatKey(userId), jsonEncode(sessionsJson));
  }

  static Future<List<ChatSession>> getChatSessions(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsStr = prefs.getString(_chatKey(userId));
    if (sessionsStr == null) return [];
    
    try {
      final List<dynamic> sessionsJson = jsonDecode(sessionsStr);
      return sessionsJson.map((json) => ChatSession.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Cellar methods
  static Future<void> saveCellarWines(String userId, List<WineModel> wines) async {
    final prefs = await SharedPreferences.getInstance();
    final winesJson = wines.map((w) => w.toJson()).toList();
    await prefs.setString(_cellarKey(userId), jsonEncode(winesJson));
  }

  static Future<List<WineModel>> getCellarWines(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final winesStr = prefs.getString(_cellarKey(userId));
    if (winesStr == null) return [];
    
    try {
      final List<dynamic> winesJson = jsonDecode(winesStr);
      return winesJson.map((json) => WineModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Wine upload temporary storage
  static Future<void> saveWineUpload(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wineUploadKey, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getWineUpload() async {
    final prefs = await SharedPreferences.getInstance();
    final dataStr = prefs.getString(_wineUploadKey);
    if (dataStr == null) return null;
    
    try {
      return jsonDecode(dataStr);
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveWineResult(Map<String, dynamic> result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wineResultKey, jsonEncode(result));
  }

  static Future<Map<String, dynamic>?> getWineResult() async {
    final prefs = await SharedPreferences.getInstance();
    final resultStr = prefs.getString(_wineResultKey);
    if (resultStr == null) return null;
    
    try {
      return jsonDecode(resultStr);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearWineTempData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_wineUploadKey);
    await prefs.remove(_wineResultKey);
  }

  // Clear all user data on logout
  static Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await getStableUserId();
    
    if (userId != null) {
      await prefs.remove(_profileKey(userId));
      await prefs.remove(_chatKey(userId));
      await prefs.remove(_cellarKey(userId));
    }
    
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_stableUserIdKey);
    await prefs.remove(_wineUploadKey);
    await prefs.remove(_wineResultKey);
  }
  
  // ============ NEW METHODS ADDED ============
  
  /// Clear authentication token (alias for removeToken for compatibility)
  static Future<void> clearToken() async {
    await removeToken();
  }
  
  /// Clear user data (alias for removeUser for compatibility)
  static Future<void> clearUser() async {
    await removeUser();
  }
  
  /// Clear all data (alias for clearAllUserData for compatibility)
  static Future<void> clearAll() async {
    await clearAllUserData();
  }
  
  /// Get user ID from storage (alias for getStableUserId for compatibility)
  static Future<String?> getUserId() async {
    return await getStableUserId();
  }
  
  /// Save user data with JSON string (compatibility method for older code)
  static Future<void> saveUserJson(String userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userJson);
    
    // Try to extract userId from JSON and save it
    try {
      final json = jsonDecode(userJson);
      if (json['userId'] != null && json['userId'].toString().isNotEmpty) {
        await prefs.setString(_stableUserIdKey, json['userId'].toString());
      }
    } catch (e) {
      // Ignore parsing errors
    }
  }
  
  /// Get user data as JSON string (compatibility method for older code)
  static Future<String?> getUserJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }
  
  /// Save profile with JSON string (compatibility method)
  static Future<void> saveUserProfileJson(String userId, String profileJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey(userId), profileJson);
  }
  
  /// Get profile as JSON string (compatibility method)
  static Future<String?> getUserProfileJson(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileKey(userId));
  }
}