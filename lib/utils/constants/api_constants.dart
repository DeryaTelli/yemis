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
  static const String logout = '/api/auth/logout';
  static const String profile = '/api/users/me';
  static const String uploadImage = '/api/upload/image';

  // --- Reviews ---
  static String reviewsForStore(int storeId) => '/api/reviews/stores/$storeId';
  static const String myReviews = '/api/reviews/my';
  static String reviewById(int id) => '/api/reviews/$id';

  // --- Locations ---
  static const String provinces = '/api/locations/provinces';
  static String districts(int provinceId) =>
      '/api/locations/provinces/$provinceId/districts';
  static String neighborhoods(int districtId) =>
      '/api/locations/districts/$districtId/neighborhoods';

  // --- Bags (Listings) ---
  static const String bags = '/api/bags';
  static const String myBags = '/api/bags/my';
  static String bagById(int id) => '/api/bags/$id';
}
