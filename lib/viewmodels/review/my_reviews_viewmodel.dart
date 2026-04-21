import 'package:flutter/material.dart';
import '../../models/review/review_model.dart';
import '../../models/review/review_request_models.dart';
import '../../services/review/i_review_service.dart';

/// Kullanıcının kendi yorumlarını listeleyen, düzenleyen ve silen ViewModel.
class MyReviewsViewModel extends ChangeNotifier {
  MyReviewsViewModel({required IReviewService reviewService})
      : _reviewService = reviewService;

  final IReviewService _reviewService;

  List<ReviewModel> _reviews = [];
  List<ReviewModel> get reviews => _reviews;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadMyReviews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reviews = await _reviewService.getMyReviews();
    } catch (e) {
      _errorMessage = 'Yorumlar yüklenemedi.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deleteReview(int reviewId) async {
    final success = await _reviewService.deleteReview(reviewId);
    if (success) {
      _reviews.removeWhere((r) => r.id == reviewId);
      notifyListeners();
    }
    return success;
  }

  Future<bool> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    final updated = await _reviewService.updateReview(
      UpdateReviewRequest(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      ),
    );
    if (updated != null) {
      final idx = _reviews.indexWhere((r) => r.id == reviewId);
      if (idx != -1) {
        _reviews[idx] = updated;
        notifyListeners();
      }
      return true;
    }
    return false;
  }
}
