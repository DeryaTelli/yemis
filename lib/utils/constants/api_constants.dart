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
  static const String changePassword = '/api/auth/change-password';
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
  static const String myUnsoldBags = '/api/bags/my/unsold';
  static const String mySoldBags = '/api/bags/my/sold';
  static String bagById(int id) => '/api/bags/$id';

  // --- Favourites ---
  static const String favorites = '/api/favourites';
  static const String myFavorites = '/api/favourites/my';
  static String favoriteById(int id) => '/api/favourites/$id';

  // --- Meals (Volunteer Listings) ---
  static const String meals = '/api/meals';
  static const String myMeals = '/api/meals/my';
  static const String myPastMeals = '/api/meals/my/past';
  static const String myActiveTasks = '/api/volunteer/tasks/my/active';
  static const String attendedTasks = '/api/volunteer/tasks/my/attended';
  static String mealById(int id) => '/api/meals/$id';
  static String mealVolunteer(int id) => '/api/meals/$id/volunteer';

  // --- Assistant ---
  static const String assistantAsk = '/api/assistant/ask';
}
