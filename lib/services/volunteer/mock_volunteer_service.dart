import '../../models/volunteer/volunteer_listing.dart';
import '../../models/volunteer/shelter_model.dart';
import 'i_volunteer_service.dart';

/// Sahte gönüllü servisi — backend hazır olunca [ApiVolunteerService] ile değiştirilir.
class MockVolunteerService implements IVolunteerService {
  MockVolunteerService._internal();
  static final MockVolunteerService _instance =
      MockVolunteerService._internal();
  factory MockVolunteerService() => _instance;

  @override
  Future<String> getUserLocationName() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return '';
  }

  @override
  Future<List<VolunteerListing>> getFeaturedListings({
    double? lat,
    double? lng,
    double? radius,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_listings);
  }

  @override
  Future<VolunteerListing> getVolunteerDetail(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _listings.firstWhere(
      (l) => l.id == id,
      orElse: () => _listings.first,
    );
  }

  @override
  Future<List<VolunteerListing>> getActiveListings() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // Sadece ilk ilanı aktif ilanmış gibi döndürüyoruz
    return [_listings.first];
  }

  @override
  Future<List<VolunteerListing>> getPastListings() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // İkinci ilanı geçmiş ilanmış gibi döndürüyoruz
    return [_listings[1]];
  }

  @override
  Future<List<VolunteerListing>> getAttendedListings() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // Katıldığımız ilanı döndürüyoruz
    return [_listings.last];
  }

  @override
  Future<bool> createMeal(Map<String, dynamic> data) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<bool> deleteMeal(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<bool> updateMeal(int id, Map<String, dynamic> data) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return true;
  }

  // ─── LİSTELER (mutable) ──────────────────────────────────────────────

  static final List<VolunteerListing> _listings = [
    // ── Sana Yakın Yerler ─────────────────────────────────
    VolunteerListing(
      id: 'ny_1',
      title: 'Sokak Hayvanları İçin Yemek',
      userName: 'Kullanıcı Adı',
      userLogoUrl: null,
      location: 'Karabük, Merkez',
      timeRange: 'Bugün Al 15.30-19.00',
      imageUrl: 'assets/foodIcon/foodSide.png', // todo: update image
      rating: 4.8,
      section: VolunteerSection.nearYou,
      latitude: 41.2048,
      longitude: 32.6218,
      description:
          'Bu paketler insan tüketimi için değildir. Tamamen sokak hayvanlarına veya barınaklara gönüllü olarak ulaştırılması amacıyla hazırlanmıştır.',
      ingredients:
          'Ürünlerin içerik veya alerjen bilgilerinde tutarsızlıklar olabilir. Bu nedenle içerik ve alerjen konularında sokak hayvanlarının tüketimine uygunluğu açısından detaylı bilgi almak isterseniz lütfen doğrudan mekâna danışınız.',
      packageInfo:
          'Gönüllü yemeği barınağa veya sokak hayvanlarına ulaştırabilmek için, lütfen yanınıza poşet veya taşıma paketi almayı unutmayınız.',
      shelterLatitude: 41.2100,
      shelterLongitude: 32.6100,
      shelterName: 'Karabük Sokak Hayvanları Barınağı',
      shelterAddress: 'Karabük, Merkez, Barınak Cd. No:1',
    ),
    VolunteerListing(
      id: 'ny_2',
      title: 'İhtiyaç Sahipleri İçin Ekstra Porsiyon',
      userName: 'Kullanıcı Adı',
      userLogoUrl: null,
      location: 'Karabük, 100. Yıl',
      timeRange: 'Bugün Al 18.00-20.00',
      imageUrl: 'assets/foodIcon/foodSide.png',
      rating: 4.5,
      section: VolunteerSection.nearYou,
      latitude: 41.2060,
      longitude: 32.6235,
      description:
          'Bu paketler insan tüketimi için değildir. Tamamen sokak hayvanlarına veya barınaklara gönüllü olarak ulaştırılması amacıyla hazırlanmıştır.',
      ingredients:
          'Ürünlerin içerik veya alerjen bilgilerinde tutarsızlıklar olabilir. Bu nedenle içerik ve alerjen konularında sokak hayvanlarının tüketimine uygunluğu açısından detaylı bilgi almak isterseniz lütfen doğrudan mekâna danışınız.',
      packageInfo:
          'Gönüllü yemeği barınağa veya sokak hayvanlarına ulaştırabilmek için, lütfen yanınıza poşet veya taşıma paketi almayı unutmayınız.',
      shelterLatitude: 41.2100,
      shelterLongitude: 32.6100,
    ),

    // ── Bugün Popüler Olanlar ─────────────────────────────
    VolunteerListing(
      id: 'tp_1',
      title: 'Sokak Hayvanları İçin Yemek',
      userName: 'Kullanıcı Adı',
      userLogoUrl: null,
      location: 'Karabük, Merkez',
      timeRange: 'Bugün Al 15.30-19.00',
      imageUrl: 'assets/foodIcon/foodSide.png',
      rating: 4.8,
      section: VolunteerSection.todayPopular,
      latitude: 41.2048,
      longitude: 32.6218,
      description:
          'Bu paketler insan tüketimi için değildir. Tamamen sokak hayvanlarına veya barınaklara gönüllü olarak ulaştırılması amacıyla hazırlanmıştır.',
      ingredients:
          'Ürünlerin içerik veya alerjen bilgilerinde tutarsızlıklar olabilir. Bu nedenle içerik ve alerjen konularında sokak hayvanlarının tüketimine uygunluğu açısından detaylı bilgi almak isterseniz lütfen doğrudan mekâna danışınız.',
      packageInfo:
          'Gönüllü yemeği barınağa veya sokak hayvanlarına ulaştırabilmek için, lütfen yanınıza poşet veya taşıma paketi almayı unutmayınız.',
      shelterLatitude: 41.2100,
      shelterLongitude: 32.6100,
    ),
    VolunteerListing(
      id: 'tp_2',
      title: 'Öğrenciler İçin Sıcak Çorba',
      userName: 'Kullanıcı Adı',
      userLogoUrl: null,
      location: 'Karabük, Üniversite',
      timeRange: 'Yarın Al 12.00-14.00',
      imageUrl: 'assets/foodIcon/foodSide.png',
      rating: 4.9,
      section: VolunteerSection.todayPopular,
      latitude: 41.2055,
      longitude: 32.6210,
      description:
          'Bu paketler insan tüketimi için değildir. Tamamen sokak hayvanlarına veya barınaklara gönüllü olarak ulaştırılması amacıyla hazırlanmıştır.',
      ingredients:
          'Ürünlerin içerik veya alerjen bilgilerinde tutarsızlıklar olabilir. Bu nedenle içerik ve alerjen konularında sokak hayvanlarının tüketimine uygunluğu açısından detaylı bilgi almak isterseniz lütfen doğrudan mekâna danışınız.',
      packageInfo:
          'Gönüllü yemeği barınağa veya sokak hayvanlarına ulaştırabilmek için, lütfen yanınıza poşet veya taşıma paketi almayı unutmayınız.',
      shelterLatitude: 41.2100,
      shelterLongitude: 32.6100,
    ),
    // ── Gönüllü Olunan (Mock) ───────────────────────────
    VolunteerListing(
      id: 'attended_1',
      title: 'Barınak İçin Mama Dağıtımı',
      userName: 'Derya Telli',
      userLogoUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      location: 'Kastamonu, Merkez',
      timeRange: '10.05.2026 | 10:53 - 20:50',
      imageUrl:
          'https://images.unsplash.com/photo-1548191265-cc70d3d45ba1?w=800',
      rating: 4.8,
      section: VolunteerSection.nearYou,
      isNetworkImage: true,
      isAttended: true,
      volunteerComment:
          'Bu ilana gönüllü olarak katıldım, barınaktaki hayvanlar için çok verimli bir mama dağıtımı gerçekleştirdik. Teşekkürler!',
    ),
  ];

  @override
  Future<bool> becomeVolunteer(int mealId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<List<ShelterModel>> getNearbyShelters({
    required double lat,
    required double lng,
    double radiusKm = 50,
    String? city,
    String? district,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Test için örnek bir barınak dönüyoruz
    return [
      ShelterModel(
        id: 1,
        name: 'Karabük Sokak Hayvanları Barınağı',
        city: 'Karabük',
        district: 'Merkez',
        address: 'Barınak Cd. No:1',
        latitude: 41.2100,
        longitude: 32.6100,
        capacity: 100,
        isActive: true,
        distanceKm: 2.5,
      ),
    ];
  }

  @override
  Future<bool> completeTask(int taskId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<bool> cancelTask(int taskId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
