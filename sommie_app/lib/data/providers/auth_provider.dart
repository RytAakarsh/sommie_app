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
  bool get isProUser => _currentUser?.plan == 'PRO';

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
        print('✅ Saved plan: ${user.plan}');
        print('✅ Saved avatar: ${user.avatar}');
        
        // Merge profile data with user data
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
          print('✅ Loaded user with plan: ${_currentUser!.plan}');
        } else {
          _currentUser = user;
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
      
      final savedUser = await StorageHelper.getUser();
      final existingProfile = await StorageHelper.getUserProfile();
      
      print('📁 Saved user plan: ${savedUser?.plan}');
      print('📁 Login response plan: ${response.user.plan}');
      
      // Use saved plan if it exists (for PRO users), otherwise use response plan
      final correctPlan = savedUser?.plan == 'PRO' ? 'PRO' : response.user.plan;
      print('📁 Using plan: $correctPlan');
      
      _currentUser = UserModel(
        userId: response.user.userId,
        name: existingProfile?['name'] ?? response.user.name,
        email: existingProfile?['email'] ?? response.user.email,
        plan: correctPlan,
        age: response.user.age,
        country: response.user.country,
        gender: existingProfile?['gender'] ?? response.user.gender,
        role: existingProfile?['role'] ?? response.user.role,
        avatar: existingProfile?['avatar'] ?? response.user.avatar,
        token: response.token,
      );
      
      await StorageHelper.saveToken(response.token);
      await StorageHelper.saveUser(_currentUser!);
      
      if (existingProfile != null) {
        existingProfile['name'] = _currentUser!.name;
        existingProfile['email'] = _currentUser!.email;
        existingProfile['avatar'] = _currentUser!.avatar ?? existingProfile['avatar'];
        existingProfile['role'] = _currentUser!.role ?? existingProfile['role'];
        await StorageHelper.saveUserProfile(existingProfile);
        print('✅ Existing profile updated');
      } else {
        await StorageHelper.saveUserProfile({
          'name': _currentUser!.name,
          'email': _currentUser!.email,
          'avatar': _currentUser!.avatar ?? '',
          'role': _currentUser!.role ?? '',
          'gender': _currentUser!.gender ?? '',
        });
        print('✅ New profile created');
      }
      
      print('✅ Login successful - User: ${_currentUser!.name}');
      print('✅ Plan: ${_currentUser!.plan}');
      
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
      print('✅ Plan: ${response.user.plan}');
      
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

  // Upgrade user to PRO on backend
  Future<bool> upgradeToPro() async {
    if (_currentUser == null) return false;
    
    _setLoading(true);
    
    try {
      final token = await StorageHelper.getToken();
      if (token == null) throw Exception('No token found');
      
      print('🔄 Upgrading user to PRO...');
      
      // Call backend to upgrade
      final updatedUser = await _authService.upgradeToPro(_currentUser!.userId, token);
      
      // Update local user
      _currentUser = _currentUser!.copyWith(
        plan: 'PRO',
        role: 'PRO User',
      );
      
      await StorageHelper.saveUser(_currentUser!);
      
      // Update profile
      final profile = await StorageHelper.getUserProfile() ?? {};
      profile['role'] = 'PRO User';
      await StorageHelper.saveUserProfile(profile);
      
      print('✅ User upgraded to PRO successfully');
      print('✅ New plan: ${_currentUser!.plan}');
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Upgrade error: $e');
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    try {
      final user = await StorageHelper.getUser();
      if (user != null) {
        _currentUser = user;
        print('✅ Refreshed user: ${user.name} - Plan: ${user.plan}');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error refreshing user: $e');
    }
  }

  // Update user profile
  Future<void> updateUser(UserModel updatedUser) async {
    _currentUser = updatedUser;
    await StorageHelper.saveUser(updatedUser);
    
    final profile = await StorageHelper.getUserProfile() ?? {};
    profile['name'] = updatedUser.name;
    profile['email'] = updatedUser.email;
    profile['avatar'] = updatedUser.avatar;
    profile['role'] = updatedUser.role;
    profile['gender'] = updatedUser.gender;
    await StorageHelper.saveUserProfile(profile);
    
    print('✅ Updated user: ${updatedUser.name} - Plan: ${updatedUser.plan}');
    print('✅ Avatar: ${updatedUser.avatar}');
    
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    await StorageHelper.removeToken();
    await StorageHelper.removeUser();
    _currentUser = null;
    print('✅ Logged out user');
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
