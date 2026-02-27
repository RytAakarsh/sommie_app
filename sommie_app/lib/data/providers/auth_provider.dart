import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../core/utils/storage_helper.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  final AuthService _authService = AuthService();

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _loadSavedUser();
  }

  Future<void> _loadSavedUser() async {
    try {
      final user = await StorageHelper.getUser();
      final token = await StorageHelper.getToken();
      final profile = await StorageHelper.getUserProfile();
      
      if (user != null && token != null) {
        print('✅ Found saved user: ${user.name}');
        print('✅ Saved avatar: ${user.avatar}');
        
        // Always use profile data if available (it has the latest avatar)
        if (profile != null) {
          _currentUser = UserModel(
            userId: user.userId,
            name: profile['name'] ?? user.name,
            email: profile['email'] ?? user.email,
            plan: user.plan,
            age: user.age,
            country: user.country,
            gender: profile['gender'] ?? user.gender,
            role: profile['role'] ?? user.role,
            avatar: profile['avatar'] ?? user.avatar,
            token: user.token,
          );
          print('✅ Loaded user with profile avatar: ${_currentUser!.avatar}');
        } else {
          _currentUser = user;
          print('✅ Loaded user without profile: ${_currentUser!.avatar}');
        }
      } else {
        print('❌ No saved user found');
      }
    } catch (e) {
      print('❌ Error loading saved user: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.login(email, password);
      
      // IMPORTANT: Load existing profile data BEFORE overwriting
      final existingProfile = await StorageHelper.getUserProfile();
      
      print('📁 Existing profile: $existingProfile');
      
      if (existingProfile != null) {
        // Use existing profile data to create the user
        _currentUser = UserModel(
          userId: response.user.userId,
          name: existingProfile['name'] ?? response.user.name,
          email: existingProfile['email'] ?? response.user.email,
          plan: response.user.plan,
          age: response.user.age,
          country: response.user.country,
          gender: existingProfile['gender'] ?? response.user.gender,
          role: existingProfile['role'] ?? response.user.role,
          avatar: existingProfile['avatar'] ?? response.user.avatar,
          token: response.token,
        );
        print('✅ Preserved existing avatar: ${_currentUser!.avatar}');
      } else {
        // No existing profile, use response data
        _currentUser = response.user.copyWith(token: response.token);
        print('✅ New user created with avatar: ${_currentUser!.avatar}');
      }
      
      // Save token
      await StorageHelper.saveToken(response.token);
      
      // Save user with preserved profile data
      await StorageHelper.saveUser(_currentUser!);
      print('✅ User saved with avatar: ${_currentUser!.avatar}');
      
      // If no profile existed, create one
      if (existingProfile == null) {
        final newProfile = {
          'name': _currentUser!.name,
          'email': _currentUser!.email,
          'avatar': _currentUser!.avatar ?? '',
          'role': _currentUser!.role ?? '',
          'phone': '',
          'cpf': '',
          'address': '',
          'dob': '',
          'gender': _currentUser!.gender ?? '',
        };
        await StorageHelper.saveUserProfile(newProfile);
        print('✅ New profile created');
      } else {
        // Update existing profile with any new data from login
        existingProfile['name'] = _currentUser!.name;
        existingProfile['email'] = _currentUser!.email;
        // Don't overwrite avatar if it exists
        if (_currentUser!.avatar != null && _currentUser!.avatar!.isNotEmpty) {
          existingProfile['avatar'] = _currentUser!.avatar;
        }
        await StorageHelper.saveUserProfile(existingProfile);
        print('✅ Existing profile updated');
      }
      
      print('✅ Login successful - User: ${_currentUser!.name}');
      print('✅ Avatar: ${_currentUser!.avatar}');
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Login error: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required int age,
    required String country,
    required String gender,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.signup(
        name: name,
        email: email,
        password: password,
        age: age,
        country: country,
        gender: gender,
      );
      
      _currentUser = response.user;
      
      await StorageHelper.saveToken(response.token);
      await StorageHelper.saveUser(response.user);
      
      // Save profile
      await StorageHelper.saveUserProfile({
        'name': name,
        'email': email,
        'avatar': '',
        'role': '',
        'phone': '',
        'cpf': '',
        'address': '',
        'dob': '',
        'gender': gender,
      });
      
      print('✅ Signup successful - User: ${response.user.name}');
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Signup error: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> refreshUser() async {
    try {
      final user = await StorageHelper.getUser();
      final profile = await StorageHelper.getUserProfile();
      
      if (user != null) {
        if (profile != null) {
          _currentUser = UserModel(
            userId: user.userId,
            name: profile['name'] ?? user.name,
            email: profile['email'] ?? user.email,
            plan: user.plan,
            age: user.age,
            country: user.country,
            gender: profile['gender'] ?? user.gender,
            role: profile['role'] ?? user.role,
            avatar: profile['avatar'] ?? user.avatar,
            token: user.token,
          );
        } else {
          _currentUser = user;
        }
        print('✅ Refreshed user: ${_currentUser!.name}');
        print('✅ Avatar: ${_currentUser!.avatar}');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error refreshing user: $e');
    }
  }

  Future<void> updateUser(UserModel updatedUser) async {
    _currentUser = updatedUser;
    await StorageHelper.saveUser(updatedUser);
    
    // Update profile
    final profile = await StorageHelper.getUserProfile() ?? {};
    profile['name'] = updatedUser.name;
    profile['email'] = updatedUser.email;
    profile['avatar'] = updatedUser.avatar;
    profile['role'] = updatedUser.role;
    profile['gender'] = updatedUser.gender;
    await StorageHelper.saveUserProfile(profile);
    
    print('✅ Updated user: ${updatedUser.name}');
    print('✅ Avatar: ${updatedUser.avatar}');
    print('✅ Profile saved with avatar: ${updatedUser.avatar}');
    
    notifyListeners();
  }

  Future<void> logout() async {
  // Don't clear all storage - only auth data
  await StorageHelper.removeToken();
  await StorageHelper.removeUser();
  // Keep cellar data
  _currentUser = null;
  print('✅ Logged out user - auth data cleared, cellar data preserved');
  notifyListeners();
}
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
