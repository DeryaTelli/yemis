import 'package:yemis/models/volunteer/volunteer_listing.dart';

/// Gönüllü servisi için arayüz.
abstract class IVolunteerService {
  /// Kullanıcının mevcut konum adını döndürür.
  Future<String> getUserLocationName();

  /// Gönüllü ilanlarını getirir.
  Future<List<VolunteerListing>> getFeaturedListings({double? lat, double? lng, double? radius});

  /// ID'ye göre tek bir ilan detayı getirir.
  Future<VolunteerListing> getVolunteerDetail(String id);

  /// Kullanıcının aktif oluşturduğu ilanları getirir.
  Future<List<VolunteerListing>> getActiveListings();

  /// Kullanıcının geçmiş (süresi dolmuş/kapanmış) ilanlarını getirir.
  Future<List<VolunteerListing>> getPastListings();

  /// Kullanıcının gönüllü olarak katıldığı ilanları getirir.
  Future<List<VolunteerListing>> getAttendedListings();

  /// Yeni bir gönüllü ilanı oluşturur.
  Future<bool> createMeal(Map<String, dynamic> data);

  /// Bir gönüllü ilanını siler.
  Future<bool> deleteMeal(int id);

  /// Bir gönüllü ilanını günceller.
  Future<bool> updateMeal(int id, Map<String, dynamic> data);
}
