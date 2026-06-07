import '../../models/review/review_model.dart';
import '../../models/review/review_request_models.dart';
import 'i_review_service.dart';

/// Geliştirme aşamasında kullanılan sahte (mock) review servisi.
class MockReviewService implements IReviewService {
  final List<ReviewModel> _myReviews = [
    ReviewModel(
      id: 1,
      storeId: 101,
      reviewerName: 'Ben',
      rating: 4,
      comment: 'Çok lezzetliydi, tekrar sipariş vereceğim!',
      date: DateTime.now().subtract(const Duration(days: 2)),
      isOwn: true,
    ),
    ReviewModel(
      id: 2,
      storeId: 102,
      reviewerName: 'Ben',
      rating: 5,
      comment: 'Harika bir deneyimdi, kesinlikle tavsiye ederim.',
      date: DateTime.now().subtract(const Duration(days: 5)),
      isOwn: true,
    ),
  ];

  final Map<int, List<ReviewModel>> _storeReviews = {
    101: [
      ReviewModel(
        id: 1,
        storeId: 101,
        reviewerName: 'Ben',
        rating: 4,
        comment: 'Çok lezzetliydi, tekrar sipariş vereceğim!',
        date: DateTime.now().subtract(const Duration(days: 2)),
        isOwn: true,
      ),
      ReviewModel(
        id: 10,
        storeId: 101,
        reviewerName: 'Ahmet Y.',
        rating: 5,
        comment: 'Muhteşem bir lezzet. Kesinlikle tavsiye ederim.',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ReviewModel(
        id: 11,
        storeId: 101,
        reviewerName: 'Zeynep K.',
        rating: 3,
        comment: 'Fiyat/performans iyi ama biraz daha taze olabilirdi.',
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ],
  };

  @override
  Future<List<ReviewModel>> getStoreReviews(int storeId) async {
    await _simulateDelay();
    return List.from(_storeReviews[storeId] ?? []);
  }

  @override
  Future<ReviewModel?> createReview(CreateReviewRequest request) async {
    await _simulateDelay();
    final newReview = ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch,
      storeId: 0,
      orderId: request.orderId,
      reviewerName: 'Ben',
      rating: request.rating.toDouble(),
      comment: request.comment,
      date: DateTime.now(),
      imageUrl1: request.imageUrl1,
      imageUrl2: request.imageUrl2,
      imageUrl3: request.imageUrl3,
      isOwn: true,
    );
    _myReviews.add(newReview);
    return newReview;
  }

  @override
  Future<List<ReviewModel>> getMyReviews() async {
    await _simulateDelay();
    return List.from(_myReviews);
  }

  @override
  Future<ReviewModel?> updateReview(UpdateReviewRequest request) async {
    await _simulateDelay();
    final idx = _myReviews.indexWhere((r) => r.id == request.reviewId);
    if (idx == -1) return null;
    final updated = _myReviews[idx].copyWith(
      rating: request.rating.toDouble(),
      comment: request.comment,
    );
    _myReviews[idx] = updated;
    // Store listesini de güncelle
    for (final storeId in _storeReviews.keys) {
      final list = _storeReviews[storeId]!;
      final storeIdx = list.indexWhere((r) => r.id == request.reviewId);
      if (storeIdx != -1) {
        list[storeIdx] = updated;
      }
    }
    return updated;
  }

  @override
  Future<bool> deleteReview(int reviewId) async {
    await _simulateDelay();
    final existed = _myReviews.any((r) => r.id == reviewId);
    _myReviews.removeWhere((r) => r.id == reviewId);
    for (final storeId in _storeReviews.keys) {
      _storeReviews[storeId]!.removeWhere((r) => r.id == reviewId);
    }
    return existed;
  }

  Future<void> _simulateDelay() =>
      Future.delayed(const Duration(milliseconds: 800));
}
