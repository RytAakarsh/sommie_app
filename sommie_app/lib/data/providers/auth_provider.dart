import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';  // THIS IS MISSING - ADD THIS LINE
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
    final user = await StorageHelper.getUser();
    if (user != null) {
      _currentUser = user;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.login(email, password);
      _currentUser = response.user;
      
      await StorageHelper.saveToken(response.token);
      await StorageHelper.saveUser(response.user);
      
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
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
    
    _setLoading(false);
    notifyListeners();
    return true;
  } catch (e) {
    print('Signup error in provider: $e'); // Debug log
    _setError(e.toString().replaceFirst('Exception: ', ''));
    _setLoading(false);
    return false;
  }
}

  Future<void> logout() async {
    await StorageHelper.clearAll();
    _currentUser = null;
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