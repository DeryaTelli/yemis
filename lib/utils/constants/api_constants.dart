class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://yemisback.onrender.com';


  // --- Auth ---
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String verifyCode = '/api/auth/verify-code';
  static const String resendCode = '/api/auth/resend-code';
  static const String resetPassword = '/api/auth/reset-password';
}
