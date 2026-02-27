import '../models/auth_response.dart';
import '../models/user_model.dart';

class MockAuthService {
  static final Map<String, UserModel> _users = {};
  static final Map<String, String> _tokens = {};

  Future<AuthResponse> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    // Find user by email
    final user = _users.values.firstWhere(
      (u) => u.email == email,
      orElse: () => UserModel(
        userId: 'mock-${DateTime.now().millisecondsSinceEpoch}',
        name: email.split('@')[0],
        email: email,
        plan: 'FREE',
      ),
    );
    
    final token = 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
    _tokens[user.userId] = token;
    
    return AuthResponse(
      token: token,
      user: user,
    );
  }

  Future<AuthResponse> signup({
    required String name,
    required String email,
    required String password,
    required int age,
    required String country,
    required String gender,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final userId = 'user-${DateTime.now().millisecondsSinceEpoch}';
    final user = UserModel(
      userId: userId,
      name: name,
      email: email,
      plan: 'FREE', // Default FREE, will be upgraded later
      age: age,
      country: country,
      gender: gender,
    );
    
    _users[userId] = user;
    final token = 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
    _tokens[userId] = token;
    
    return AuthResponse(
      token: token,
      user: user,
    );
  }

  Future<UserModel> upgradeToPro(String userId, String planType) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (_users.containsKey(userId)) {
      final user = _users[userId]!;
      final upgradedUser = user.copyWith(plan: 'PRO');
      _users[userId] = upgradedUser;
      return upgradedUser;
    }
    throw Exception('User not found');
  }
}
