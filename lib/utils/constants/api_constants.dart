class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://yemisback.onrender.com';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const Duration notificationTokenTimeout = Duration(seconds: 3);

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
  static const String popularBags = '/api/bags/popular';
  static const String popularTodayBags = '/api/bags/popular/today';
  static String bagById(int id) => '/api/bags/$id';

  // --- Favourites ---
  static const String favorites = '/api/favourites';
  static const String myFavorites = '/api/favourites/my';
  static String favoriteById(int id) => '/api/favourites/$id';

  // --- Meals (Volunteer Listings) ---
  static const String meals = '/api/meals';
  static const String myMeals = '/api/meals/my';
  static const String myActiveMeals = '/api/meals/my/active';
  static const String myPastMeals = '/api/meals/my/past';
  static const String ownerVolunteerTasks = '/api/volunteer/tasks/owner';
  static const String myActiveTasks = '/api/volunteer/tasks/my/active';
  static const String attendedTasks = '/api/volunteer/tasks/my/attended';
  static String mealById(int id) => '/api/meals/$id';
  static String mealVolunteer(int id) => '/api/meals/$id/volunteer';

  // --- Assistant ---
  static const String assistantAsk = '/api/assistant/ask';

  // --- Shelters ---
  static const String sheltersNearby = '/api/shelters/nearby';

  // --- Notifications ---
  static const String notifications = '/api/notifications/my';
  static const String notificationsUnreadCount =
      '/api/notifications/unread-count';
  static const String notificationsReadAll = '/api/notifications/read-all';
  static const String notificationPreferences =
      '/api/notifications/preferences';
  static const String notificationDeviceToken =
      '/api/notifications/device-token';
  static String notificationRead(int id) => '/api/notifications/$id/read';
  static String notificationById(int id) => '/api/notifications/$id';
  static String completeTask(int id) => '/api/volunteer/tasks/$id/complete';
  static String cancelTask(int id) => '/api/volunteer/tasks/$id/cancel';
  static String startPickup(int id) => '/api/volunteer/tasks/$id/start-pickup';
  static String markPickedUp(int id) =>
      '/api/volunteer/tasks/$id/mark-picked-up';
  static String startDelivery(int id) =>
      '/api/volunteer/tasks/$id/start-delivery';
  static String confirmDelivery(int id) =>
      '/api/volunteer/tasks/$id/confirm-delivery';
  static String acceptVolunteer(int id) => '/api/volunteer/tasks/$id/approve';
  static String rejectVolunteer(int id) => '/api/volunteer/tasks/$id/reject';
  static String ownerHandover(int id) => '/api/volunteer/tasks/$id/hand-over';
  static String volunteerReview(int id) => '/api/reviews/volunteer-tasks/$id';
  static String ownerReview(int id) => '/api/reviews/volunteer-tasks/$id/owner';

  // --- Stats ---
  static const String businessDashboard = '/api/stats/business/dashboard';

  // --- Orders ---
  static const String orders = '/api/orders';
  static const String myOrders = '/api/orders/my';
  static const String businessOrderApprovals = '/api/orders/business/approvals';
  static String cancelOrder(int id) => '/api/orders/$id/cancel';
  static String orderArrived(int id) => '/api/orders/$id/arrived';
  static String confirmOrderPickup(int id) => '/api/orders/$id/confirm-pickup';
}
