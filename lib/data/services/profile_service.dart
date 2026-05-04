import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/utils/storage_helper.dart';

class ProfileService {
  static Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) return null;

      final response = await Dio().get(
        ApiEndpoints.getProfile,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['profile'] ?? data;
      }
      return null;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) return false;

      final response = await Dio().post(
        ApiEndpoints.updateProfile,
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  static Future<bool> updateAvatar(String avatarPath, String role) async {
    return await updateProfile({
      'avatar': avatarPath,
      'role': role,
    });
  }
}
