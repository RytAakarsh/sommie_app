class ApiEndpoints {
  // Main backend URL (for auth, users, chat)
  static const String baseUrl = 'https://sommie-app-backend.onrender.com';
  
  // API Gateway URL (for wine upload only)
  static const String apiGatewayUrl = 'https://nno6bbdldf.execute-api.us-east-1.amazonaws.com';

  // Auth endpoints
  static const String signup = '$baseUrl/api/auth/signup';
  static const String login = '$baseUrl/api/auth/login';
  static const String forgotPassword = '$baseUrl/api/auth/forgot-password';
  static const String verifyOtp = '$baseUrl/api/auth/verify-otp';
  static const String resetPassword = '$baseUrl/api/auth/reset-password';

  // User endpoints
  static const String upgradePlan = '$baseUrl/api/users/upgrade-plan';
  
  // Chat endpoints
  static const String chat = '$baseUrl/api/chat';

  // Wine endpoints (API Gateway)
  static const String uploadWine = '$apiGatewayUrl/wines/upload';
  static const String registerWine = '$apiGatewayUrl/register';
}