class ApiEndpoints {
  // App Backend URL (Your backend for auth, users, etc.)
  static const String baseUrl = 'https://sommie-app-backend.onrender.com';
  
  // Website Backend URL
  static const String websiteBackend = 'https://sommie-backend.onrender.com';
  
  // ==================== CHAT API (API Gateway) ====================
  static const String chatBaseUrl = 'https://2n0y285v45.execute-api.us-east-1.amazonaws.com';
  static const String chatApiKey = 'a63cbd1ecbef2b6e570e712b3852cbe942d4b95c9d48075e69a8f0dca8dd61e6';
  
  // ✅ NEW: Presign upload endpoint
  static const String presignUpload = '$chatBaseUrl/uploads/presign';
  
  // ✅ Chat endpoint (for sending messages and file_key)
  static const String chat = '$chatBaseUrl/chat';
  static const String saveChat = '$baseUrl/api/users/chat';
  static const String getChats = '$baseUrl/api/users/chat';
  static const String deleteChat = '$baseUrl/api/users/chat';
  
  // ==================== AUTH ENDPOINTS ====================
  static const String signup = '$baseUrl/api/auth/signup';
  static const String login = '$baseUrl/api/auth/login';
  static const String logout = '$baseUrl/api/auth/logout';
  static const String getProfile = '$baseUrl/api/users/profile';
  static const String updateProfile = '$baseUrl/api/users/profile';
  
  // ==================== PASSWORD RESET ENDPOINTS ====================
  static const String forgotPassword = '$baseUrl/api/auth/forgot-password';
  static const String verifyResetOtp = '$baseUrl/api/auth/verify-reset-otp';
  static const String resetPassword = '$baseUrl/api/auth/reset-password';
  
  // ==================== EMAIL VERIFICATION ENDPOINTS ====================
  static const String sendOtp = '$baseUrl/api/verify/send-otp';
  static const String verifyOtp = '$baseUrl/api/verify/verify-otp';
  static const String resendOtp = '$baseUrl/api/verify/resend-otp';
  
  // ==================== MOBILE PAYMENT FLOW ENDPOINTS ====================
  static const String createCheckoutSession = '$baseUrl/api/mobile/create-checkout-session';
  static const String validateMobileSession = '$baseUrl/api/mobile/validate-session';
  
  // ==================== USER ENDPOINTS ====================

  static const String getUserChats = '$baseUrl/api/users/chats';
  static const String upgradePlan = '$baseUrl/api/users/upgrade-plan';
  static const String getFullUserData = '$baseUrl/api/users/full-data';
  
  // ==================== WINE / CELLAR ENDPOINTS ====================
  static const String getCellar = '$baseUrl/api/users/cellar';
  static const String addWine = '$baseUrl/api/users/cellar';
  static const String updateWine = '$baseUrl/api/users/cellar';
  static const String deleteWine = '$baseUrl/api/users/cellar';
}
