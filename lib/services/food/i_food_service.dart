import '../../models/food/food_listing.dart';
import '../../models/food/food_review.dart';

/// Yemek servisinin soyut arayüzü.
///
/// Mock → Api değişimini kolaylaştırır.
abstract class IFoodService {
  /// Kullanıcının konum adını döner.
  Future<String> getUserLocationName();

  /// Öne çıkan yemek ilanlarını döner.
  Future<List<FoodListing>> getFeaturedListings();

  /// Belirtilen id'ye sahip ilan detayını döner.
  Future<FoodListing> getFoodDetail(String id);

  /// Belirtilen ilanın yorumlarını döner.
  Future<List<FoodReview>> getFoodReviews(String id);

  /// Favori durumunu değiştirir.
  Future<void> toggleFavorite(String id);

  /// Favori olan ilanları döner.
  Future<List<FoodListing>> getFavorites();
}
