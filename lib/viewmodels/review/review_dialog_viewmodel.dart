import 'package:flutter/material.dart';
import '../../models/review/review_request_models.dart';
import '../../services/review/i_review_service.dart';

/// Zorunlu yorum dialog'unun ViewModel'i.
///
/// Dialog [barrierDismissible: false] ile gösterilir;
/// yorum gönderilmeden kapanmaz.
class ReviewDialogViewModel extends ChangeNotifier {
  ReviewDialogViewModel({
    required IReviewService reviewService,
    required int storeId,
    required String storeName,
  })  : _reviewService = reviewService,
        _storeId = storeId,
        _storeName = storeName;

  final IReviewService _reviewService;
  final int _storeId;
  final String _storeName;

  String get storeName => _storeName;

  final TextEditingController commentController = TextEditingController();

  int _rating = 0;
  int get rating => _rating;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isSubmitted = false;
  bool get isSubmitted => _isSubmitted;

  void setRating(int value) {
    _rating = value;
    _errorMessage = null;
    notifyListeners();
  }

  /// Yorum gönderir. Başarılıysa [isSubmitted] true olur.
  Future<void> submit() async {
    if (_rating == 0) {
      _errorMessage = 'Lütfen bir puan seçin.';
      notifyListeners();
      return;
    }
    if (commentController.text.trim().isEmpty) {
      _errorMessage = 'Lütfen bir yorum yazın.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _reviewService.createReview(
      CreateReviewRequest(
        storeId: _storeId,
        rating: _rating,
        comment: commentController.text.trim(),
      ),
    );

    _isLoading = false;

    if (result != null) {
      _isSubmitted = true;
    } else {
      _errorMessage = 'Yorum gönderilemedi. Lütfen tekrar deneyin.';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }
}
