import '../../models/review/review_model.dart';
import '../../models/review/review_request_models.dart';

/// Review servisinin sözleşmesi (interface).
abstract class IReviewService {
  /// Bir store'un tüm yorumlarını listeler.
  Future<List<ReviewModel>> getStoreReviews(int storeId);

  /// Bir store'a yeni yorum ekler.
  Future<ReviewModel?> createReview(CreateReviewRequest request);

  /// Oturum açmış kullanıcının tüm yorumlarını listeler.
  Future<List<ReviewModel>> getMyReviews();

  /// Kullanıcının mevcut yorumunu günceller.
  Future<ReviewModel?> updateReview(UpdateReviewRequest request);

  /// Kullanıcının yorumunu siler. Başarılıysa true döner.
  Future<bool> deleteReview(int reviewId);
}
