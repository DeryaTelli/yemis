import '../../models/food/food_listing.dart';
import '../../models/food/food_review.dart';
import '../../models/food/order_model.dart';

/// Yemek servisinin soyut arayüzü.
///
/// Mock → Api değişimini kolaylaştırır.
abstract class IFoodService {
  /// Kullanıcının konum adını döner.
  Future<String> getUserLocationName();

  /// Öne çıkan yemek ilanlarını döner.
  Future<List<FoodListing>> getFeaturedListings();

  /// Popüler yemek ilanlarını döner.
  Future<List<FoodListing>> getPopularListings({int? limit, String? category});

  /// Bugünün popüler ilanlarını (tükendiler dahil) döner.
  Future<List<FoodListing>> getPopularTodayListings({int? limit, String? category});

  /// Belirtilen id'ye sahip ilan detayını döner.
  Future<FoodListing> getFoodDetail(String id);

  /// Belirtilen ilanın yorumlarını döner.
  Future<List<FoodReview>> getFoodReviews(String id);

  /// Favori durumunu değiştirir.
  Future<void> toggleFavorite(String id);

  /// Favori olan ilanları döner.
  Future<List<FoodListing>> getFavorites();

  /// Sipariş oluşturur. [bagId] ilan ID'si, [quantity] adet sayısıdır.
  Future<bool> createOrder(int bagId, int quantity);
  /// Kullanıcının sipariş geçmişini döner.
  Future<List<OrderModel>> getMyOrders();
}

