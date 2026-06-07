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
    required int orderId,
    required String storeName,
  })  : _reviewService = reviewService,
        _orderId = orderId,
        _storeName = storeName;

  final IReviewService _reviewService;
  final int _orderId;
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
  Future<void> submit({List<String> imageUrls = const []}) async {
    if (_rating == 0) {
      _errorMessage = 'Lütfen bir puan seçin.';
      notifyListeners();
      return;
    }
    if (commentController.text.trim().length < 15) {
      _errorMessage = 'Yorum en az 15 karakter olmalı.';
      notifyListeners();
      return;
    }
    if (imageUrls.isEmpty) {
      _errorMessage = 'En az 1 fotoğraf eklemelisiniz.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _reviewService.createReview(
      CreateReviewRequest(
        orderId: _orderId,
        rating: _rating,
        comment: commentController.text.trim(),
        imageUrl1: imageUrls[0],
        imageUrl2: imageUrls.length > 1 ? imageUrls[1] : null,
        imageUrl3: imageUrls.length > 2 ? imageUrls[2] : null,
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
