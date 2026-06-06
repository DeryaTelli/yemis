import 'package:flutter/foundation.dart';
import '../../models/food/order_model.dart';
import '../../services/food/i_food_service.dart';

class FoodOrdersHistoryViewModel extends ChangeNotifier {
  final IFoodService _foodService;

  FoodOrdersHistoryViewModel(this._foodService);

  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

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
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching past orders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
