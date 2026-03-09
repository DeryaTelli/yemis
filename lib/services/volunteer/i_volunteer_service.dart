import '../../models/volunteer/volunteer_listing.dart';

/// Gönüllü servisi için arayüz.
abstract class IVolunteerService {
  /// Kullanıcının mevcut konum adını döndürür.
  Future<String> getUserLocationName();

  /// Gönüllü ilanlarını getirir.
  Future<List<VolunteerListing>> getFeaturedListings();

  /// ID'ye göre tek bir ilan detayı getirir.
  Future<VolunteerListing> getVolunteerDetail(String id);

  /// Kullanıcının aktif oluşturduğu ilanları getirir.
  Future<List<VolunteerListing>> getActiveListings();

  /// Kullanıcının geçmiş (süresi dolmuş/kapanmış) ilanlarını getirir.
  Future<List<VolunteerListing>> getPastListings();

  /// Kullanıcının gönüllü olarak katıldığı ilanları getirir.
  Future<List<VolunteerListing>> getAttendedListings();
}
