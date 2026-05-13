class BusinessDashboardModel {
  final List<double> weeklySales;
  final double co2Saved;

  BusinessDashboardModel({
    required this.weeklySales,
    required this.co2Saved,
  });

  factory BusinessDashboardModel.fromJson(Map<String, dynamic> json) {
    return BusinessDashboardModel(
      weeklySales: _parseWeeklySales(json['weekly_sales']),
      co2Saved: (json['co2_saved'] as num?)?.toDouble() ?? 0.0,
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
