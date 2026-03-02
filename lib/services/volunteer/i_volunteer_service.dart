import '../../models/volunteer/volunteer_listing.dart';

/// Gönüllü servisi için arayüz.
abstract class IVolunteerService {
  /// Kullanıcının mevcut konum adını döndürür.
  Future<String> getUserLocationName();

  /// Gönüllü ilanlarını getirir.
  Future<List<VolunteerListing>> getFeaturedListings();

  /// ID'ye göre tek bir ilan detayı getirir.
  Future<VolunteerListing> getVolunteerDetail(String id);
}
