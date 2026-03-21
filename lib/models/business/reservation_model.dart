/// Kullanıcının bir ilanı rezerve etmesini temsil eder.
class ReservationModel {
  final String id;
  final String listingDate;   // e.g. "12/01/2026"
  final String timeWindow;    // e.g. "15.30-19.00"
  final int orderedCount;     // kullanıcının aldığı adet
  final int totalCount;       // ilanın toplam adedi
  final String customerName;
  final String? foodImageUrl; // network URL or null → placeholder

  const ReservationModel({
    required this.id,
    required this.listingDate,
    required this.timeWindow,
    required this.orderedCount,
    required this.totalCount,
    required this.customerName,
    this.foodImageUrl,
  });
}
