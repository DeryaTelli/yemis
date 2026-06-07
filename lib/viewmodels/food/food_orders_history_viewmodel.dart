import 'package:flutter/foundation.dart';
import '../../models/food/order_model.dart';
import '../../models/review/review_model.dart';
import '../../services/food/i_food_service.dart';
import '../../services/review/i_review_service.dart';

class FoodOrdersHistoryViewModel extends ChangeNotifier {
  final IFoodService _foodService;
  final IReviewService _reviewService;

  FoodOrdersHistoryViewModel(this._foodService, this._reviewService);

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;
  Map<int, ReviewModel> _reviewsByOrderId = {};
  ReviewModel? reviewForOrder(int orderId) => _reviewsByOrderId[orderId];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _foodService.getMyOrders();
      // En yeni sipariş en üstte olacak şekilde sırala
      _orders.sort((a, b) => b.orderTime.compareTo(a.orderTime));

      try {
        final reviews = await _reviewService.getMyReviews();
        _reviewsByOrderId = {
          for (final review in reviews)
            if (review.orderId != null) review.orderId!: review,
        };
      } catch (e) {
        _reviewsByOrderId = {};
        debugPrint('Error fetching order reviews: $e');
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching past orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
