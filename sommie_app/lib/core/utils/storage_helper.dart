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

 import 'package:flutter_secure_storage/flutter_secure_storage.dart';
 import 'dart:convert';
 import '../../data/models/user_model.dart';
 import '../../data/models/chat_session.dart';
 import '../../data/models/wine_model.dart';

class StorageHelper {
  static const _storage = FlutterSecureStorage();
  
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _profileKey = 'user_profile';
  static const String _chatSessionsPrefix = 'sommie_chat_';
  static const String _cellarCacheKey = 'sommie_cellar_cache';

  // Token methods
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    print('✅ Token saved');
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
    print('✅ Token removed');
  }

  // User methods
  static Future<void> saveUser(UserModel user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    print('✅ User saved: ${user.name} - Plan: ${user.plan} - Avatar: ${user.avatar}');
  }

  static Future<UserModel?> getUser() async {
    final userString = await _storage.read(key: _userKey);
    if (userString != null) {
      try {
        final user = UserModel.fromJson(jsonDecode(userString));
        print('✅ User loaded: ${user.name} - Plan: ${user.plan} - Avatar: ${user.avatar}');
        return user;
      } catch (e) {
        print('❌ Error parsing user: $e');
        return null;
      }
    }
    return null;
  }

  static Future<void> removeUser() async {
    await _storage.delete(key: _userKey);
    print('✅ User removed');
  }

  // Profile methods
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await _storage.write(key: _profileKey, value: jsonEncode(profile));
    print('✅ Profile saved: ${profile['name']} - Avatar: ${profile['avatar']}');
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final profileString = await _storage.read(key: _profileKey);
    if (profileString != null) {
      try {
        return jsonDecode(profileString);
      } catch (e) {
        print('❌ Error parsing profile: $e');
        return null;
      }
    }
    return null;
  }

  // Chat sessions methods
  static Future<void> saveChatSessions(String userId, List<ChatSession> sessions) async {
    final sessionsJson = sessions.map((s) => s.toJson()).toList();
    await _storage.write(
      key: '$_chatSessionsPrefix$userId',
      value: jsonEncode(sessionsJson),
    );
    print('✅ Saved ${sessions.length} chat sessions for user $userId');
  }

  static Future<List<ChatSession>> getChatSessions(String userId) async {
    final sessionsString = await _storage.read(key: '$_chatSessionsPrefix$userId');
    if (sessionsString != null) {
      try {
        final List<dynamic> sessionsJson = jsonDecode(sessionsString);
        return sessionsJson.map((j) => ChatSession.fromJson(j)).toList();
      } catch (e) {
        print('❌ Error parsing chat sessions: $e');
        return [];
      }
    }
    return [];
  }

  // Cellar methods
  static Future<void> saveCellarWines(String userId, List<WineModel> wines) async {
    final cacheString = await _storage.read(key: _cellarCacheKey);
    final Map<String, dynamic> cache = cacheString != null
        ? jsonDecode(cacheString)
        : {};
    
    cache[userId] = wines.map((w) => w.toJson()).toList();
    await _storage.write(key: _cellarCacheKey, value: jsonEncode(cache));
    print('✅ Saved ${wines.length} wines for user $userId');
  }

  static Future<List<WineModel>> getCellarWines(String userId) async {
    final cacheString = await _storage.read(key: _cellarCacheKey);
    if (cacheString != null) {
      try {
        final Map<String, dynamic> cache = jsonDecode(cacheString);
        final winesJson = cache[userId] as List? ?? [];
        return winesJson.map((j) => WineModel.fromJson(j)).toList();
      } catch (e) {
        print('❌ Error parsing cellar wines: $e');
        return [];
      }
    }
    return [];
  }

  // Wine upload methods
  static Future<void> saveWineUpload(Map<String, dynamic> uploadData) async {
    await _storage.write(key: 'sommie_wine_upload', value: jsonEncode(uploadData));
  }

  static Future<Map<String, dynamic>?> getWineUpload() async {
    final uploadString = await _storage.read(key: 'sommie_wine_upload');
    if (uploadString != null) {
      return jsonDecode(uploadString);
    }
    return null;
  }

  static Future<void> saveWineResult(Map<String, dynamic> resultData) async {
    await _storage.write(key: 'sommie_wine_result', value: jsonEncode(resultData));
  }

  static Future<Map<String, dynamic>?> getWineResult() async {
    final resultString = await _storage.read(key: 'sommie_wine_result');
    if (resultString != null) {
      return jsonDecode(resultString);
    }
    return null;
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
    print('✅ All storage cleared');
  }
}