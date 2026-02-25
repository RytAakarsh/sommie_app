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
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // User methods
  static Future<void> saveUser(UserModel user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getUser() async {
    final userString = await _storage.read(key: _userKey);
    if (userString != null) {
      return UserModel.fromJson(jsonDecode(userString));
    }
    return null;
  }

  static Future<void> removeUser() async {
    await _storage.delete(key: _userKey);
  }

  // Profile methods
  static Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    await _storage.write(key: _profileKey, value: jsonEncode(profile));
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final profileString = await _storage.read(key: _profileKey);
    if (profileString != null) {
      return jsonDecode(profileString);
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
  }

  static Future<List<ChatSession>> getChatSessions(String userId) async {
    final sessionsString = await _storage.read(key: '$_chatSessionsPrefix$userId');
    if (sessionsString != null) {
      final List<dynamic> sessionsJson = jsonDecode(sessionsString);
      return sessionsJson.map((j) => ChatSession.fromJson(j)).toList();
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
  }

  static Future<List<WineModel>> getCellarWines(String userId) async {
    final cacheString = await _storage.read(key: _cellarCacheKey);
    if (cacheString != null) {
      final Map<String, dynamic> cache = jsonDecode(cacheString);
      final winesJson = cache[userId] as List? ?? [];
      return winesJson.map((j) => WineModel.fromJson(j)).toList();
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
  }
}