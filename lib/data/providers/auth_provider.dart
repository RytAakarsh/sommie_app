import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/utils/storage_helper.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty && _currentUser != null;

  /// Load user from storage on app start
  Future<void> loadUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      _token = await StorageHelper.getToken();

      // Load stored user first
      final storedUser = await StorageHelper.getUser();
      if (storedUser != null) {
        _currentUser = storedUser;
        print("📦 Loaded stored user: ${_currentUser?.name}, Plan: ${_currentUser?.plan}");
        notifyListeners();
      }

      // Then fetch fresh data from backend if token exists
      if (_token != null && _token!.isNotEmpty) {
        await fetchUser();
      }
    } catch (e) {
      print("Error loading user: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch user profile from backend
  Future<void> fetchUser() async {
    try {
      if (_token == null) return;

      print("🔄 Fetching user profile...");
      
      final response = await Dio().get(
        ApiEndpoints.getProfile,
        options: Options(
          headers: {'Authorization': 'Bearer $_token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print("📦 Raw response: $data");
        
        Map<String, dynamic> userData;
        
        if (data['profile'] != null && data['profile'] is Map) {
          final profile = data['profile'] as Map<String, dynamic>;
          
          // CRITICAL FIX: Extract avatar and photo correctly
          String? avatarValue;
          String? photoValue;
          
          // Handle avatar - could be String or Map
          if (profile['avatar'] != null) {
            if (profile['avatar'] is String) {
              avatarValue = profile['avatar'] as String;
            } else if (profile['avatar'] is Map) {
              avatarValue = (profile['avatar'] as Map)['path'] ?? 
                           (profile['avatar'] as Map)['url'] ??
                           (profile['avatar'] as Map)['avatar'];
              if (avatarValue == null) {
                avatarValue = 'assets/sommie_avatar/Avatar_Sommie_Lucia_Herrera.png';
              }
            }
          }
          
          // Handle photo - could be String or Map
          if (profile['photo'] != null) {
            if (profile['photo'] is String) {
              photoValue = profile['photo'] as String;
            } else if (profile['photo'] is Map) {
              photoValue = (profile['photo'] as Map)['path'] ?? 
                          (profile['photo'] as Map)['url'] ??
                          (profile['photo'] as Map)['photo'];
            }
          }
          
          // Handle phone and cpf
          String? phoneValue;
          if (profile['phone'] != null) {
            if (profile['phone'] is String) {
              phoneValue = profile['phone'] as String;
            } else if (profile['phone'] is Map) {
              phoneValue = (profile['phone'] as Map)['number'] ?? 
                          (profile['phone'] as Map)['phone'] ??
                          profile['phone'].toString();
            }
          }
          
          String? cpfValue;
          if (profile['cpf'] != null) {
            if (profile['cpf'] is String) {
              cpfValue = profile['cpf'] as String;
            } else if (profile['cpf'] is Map) {
              cpfValue = (profile['cpf'] as Map)['number'] ?? 
                        (profile['cpf'] as Map)['cpf'] ??
                        profile['cpf'].toString();
            }
          }
          
          // ✅ FIXED: Better address parsing from Map
          String addressValue = '';
          final addressMap = profile['address'];
          
          if (addressMap != null && addressMap is Map) {
            final parts = <String>[];
            
            if (addressMap['street'] != null && addressMap['street'].toString().isNotEmpty) {
              parts.add(addressMap['street'].toString());
            }
            if (addressMap['city'] != null && addressMap['city'].toString().isNotEmpty) {
              parts.add(addressMap['city'].toString());
            }
            if (addressMap['state'] != null && addressMap['state'].toString().isNotEmpty) {
              parts.add(addressMap['state'].toString());
            }
            if (addressMap['zipCode'] != null && addressMap['zipCode'].toString().isNotEmpty) {
              parts.add(addressMap['zipCode'].toString());
            }
            if (addressMap['country'] != null && addressMap['country'].toString().isNotEmpty) {
              parts.add(addressMap['country'].toString());
            }
            
            addressValue = parts.join(', ');
          } else if (addressMap != null && addressMap is String) {
            addressValue = addressMap;
          }
          
          userData = {
            'userId': profile['userId'],
            'name': profile['name'],
            'email': profile['email'],
            'plan': profile['plan'],
            'age': profile['age'],
            'country': profile['country'],
            'gender': profile['gender'],
            'role': profile['role'],
            'photo': photoValue,
            'avatar': avatarValue ?? 'assets/sommie_avatar/Avatar_Sommie_Lucia_Herrera.png',
            'phone': phoneValue ?? '',
            'cpf': cpfValue ?? '',
            'address': addressValue,
            'dob': profile['dob'] ?? '',
            'emailVerified': profile['emailVerified'] ?? false,
          };
          
          print("✅ Parsed user data:");
          print("  - Avatar: ${userData['avatar']}");
          print("  - Photo: ${userData['photo']}");
          print("  - Phone: ${userData['phone']}");
          print("  - CPF: ${userData['cpf']}");
          print("  - Address: ${userData['address']}");
          print("  - DOB: ${userData['dob']}");
        } else {
          userData = data as Map<String, dynamic>;
        }
        
        _currentUser = UserModel.fromJson(userData).copyWith(
          token: _token,
        );

        // Save to storage
        await StorageHelper.saveUser(_currentUser!);
        notifyListeners();

        print("✅ User loaded: ${_currentUser?.name}, Plan: ${_currentUser?.plan}");
        print("✅ Avatar: ${_currentUser?.avatar}");
        print("✅ Photo: ${_currentUser?.photo}");
      }
    } catch (e) {
      print("❌ Error fetching user: $e");
      if (e is DioException && e.response?.statusCode == 401) {
        await logout();
      }
    }
  }
  
  /// Refresh user data (called after payment)
  Future<void> refreshUser() async {
    print("🔄 Refreshing user data...");
    await fetchUser();
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await Dio().post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        _token = data['token'];

        if (_token != null && _token!.isNotEmpty) {
          await StorageHelper.saveToken(_token!);
          await fetchUser();
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          throw Exception('No token received');
        }
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print("Login error: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Signup user - NO TOKEN EXPECTED (user must verify email first)
  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required int age,
    required String country,
    required String gender,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await Dio().post(
        ApiEndpoints.signup,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'age': age,
          'country': country,
          'gender': gender,
        },
      );

      print('✅ Signup response status: ${response.statusCode}');
      print('📦 Signup response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print("Signup error: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    await StorageHelper.clearAll();
    notifyListeners();
  }

  /// Update profile
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      print("📤 Updating profile with data: $data");

      final response = await Dio().post(
        ApiEndpoints.updateProfile,
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $_token'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchUser();
        print('✅ Profile updated successfully');
      } else {
        print('❌ Update profile failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Update profile error: $e');
      if (e is DioException) {
        print('Response data: ${e.response?.data}');
        print('Status code: ${e.response?.statusCode}');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}