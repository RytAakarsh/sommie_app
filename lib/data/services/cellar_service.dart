import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/wine_model.dart';

class CellarService {
  final Dio _dio = Dio(BaseOptions(
    headers: {'Content-Type': 'application/json'},
  ));

  Future<List<WineModel>> fetchCellar(String userId, String token) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getCellar,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> wines = data['bottles'] ?? data['data'] ?? [];
        return wines.map((json) => WineModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching cellar: $e');
      return [];
    }
  }

  Future<void> addWine(WineModel wine, String userId, String token) async {
    await _dio.post(
      ApiEndpoints.addWine,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
      data: {
        'userId': userId,
        'bottles': [wine.toJson()],
      },
    );
  }

  Future<void> updateWine(WineModel wine, String userId, String token) async {
    await _dio.put(
      ApiEndpoints.updateWine,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
      data: wine.toJson(),
    );
  }

  Future<void> deleteWine(String wineId, String userId, String token) async {
    await _dio.delete(
      ApiEndpoints.deleteWine,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
      data: {'userId': userId, 'wineId': wineId},
    );
  }
}