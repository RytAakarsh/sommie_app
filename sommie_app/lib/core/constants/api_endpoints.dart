class ApiEndpoints {
  // IMPORTANT: Add the port :5000
  static const String baseUrl = 'https://sommie-backend.onrender.com:5000';
  
  // Auth endpoints
  static const String signup = '/api/auth/signup';
  static const String login = '/api/auth/login';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String resetPassword = '/api/auth/reset-password';
  
  // User endpoints
  static const String upgradePlan = '/api/users/upgrade-plan';
  
  // Chat endpoints
  static const String chat = '/api/chat';
  
  // Wine endpoints
  static const String uploadWine = '/api/wine/upload';
}