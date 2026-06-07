class BusinessDashboardModel {
  final List<double> weeklySales;
  final double co2Saved;
  final int totalOrders;
  final int activeBags;
  final int pickedUpOrders;
  final double rating;
  final int soldOutBags;
  final double totalRevenue;
  final int mealsSaved;
  final int unsoldItems;
  final double co2SavedKg;
  final double wastePreventedKg;
  final double sellThroughRate;

  BusinessDashboardModel({
    required this.weeklySales,
    required this.co2Saved,
    required this.totalOrders,
    required this.activeBags,
    required this.pickedUpOrders,
    required this.rating,
    required this.soldOutBags,
    required this.totalRevenue,
    required this.mealsSaved,
    required this.unsoldItems,
    required this.co2SavedKg,
    required this.wastePreventedKg,
    required this.sellThroughRate,
  });

  factory BusinessDashboardModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    return BusinessDashboardModel(
      weeklySales: _parseWeeklySales(json['weekly_sales']),
      co2Saved: (json['co2_saved'] as num?)?.toDouble() ?? 0.0,
      totalOrders: (summary['total_orders'] as num?)?.toInt() ?? 0,
      activeBags: (summary['active_bags'] as num?)?.toInt() ?? 0,
      pickedUpOrders: (summary['picked_up_orders'] as num?)?.toInt() ?? 0,
      rating: (summary['rating'] as num?)?.toDouble() ?? 0.0,
      soldOutBags: (summary['sold_out_bags'] as num?)?.toInt() ?? 0,
      totalRevenue: (summary['total_revenue'] as num?)?.toDouble() ?? 0.0,
      mealsSaved: (summary['meals_saved'] as num?)?.toInt() ?? 0,
      unsoldItems: (summary['unsold_items'] as num?)?.toInt() ?? 0,
      co2SavedKg: (summary['co2_saved_kg'] as num?)?.toDouble() ?? 0.0,
      wastePreventedKg: (summary['waste_prevented_kg'] as num?)?.toDouble() ?? 0.0,
      sellThroughRate: (summary['sell_through_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static List<double> _parseWeeklySales(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      // Eğer doğrudan sayı listesiyse: [10, 20, 15, ...]
      if (data.every((e) => e is num)) {
        return data.map((e) => (e as num).toDouble()).toList();
      }
      // Eğer obje listesiyse: [{"day": "Pzt", "count": 10}, ...]
      try {
        return data.map((e) => (e['count'] as num).toDouble()).toList();
      } catch (_) {}
    }
    return [];
  }
}
