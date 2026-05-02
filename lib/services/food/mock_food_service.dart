import '../../models/food/food_listing.dart';
import '../../models/food/food_review.dart';
import '../auth/user_session.dart';
import 'i_food_service.dart';

/// Sahte yemek servisi — backend hazır olunca [ApiFoodService] ile değiştirilir.
///
/// Singleton olarak kullanılır; böylece tüm ViewModel'ler aynı
/// [_listings] listesini paylaşır ve favori durumu ekranlar arasında senkron kalır.
class MockFoodService implements IFoodService {
  MockFoodService._internal();
  static final MockFoodService _instance = MockFoodService._internal();
  factory MockFoodService() => _instance;

  UserSession? _userSession;

  /// UserSession'ı dışarıdan set etmek için (ViewModel'lerde kolaylık sağlar)
  void setUserSession(UserSession session) {
    _userSession = session;
  }

  @override
  Future<String> getUserLocationName() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _userSession?.currentAddress ?? '';
  }

  @override
  Future<List<FoodListing>> getFeaturedListings() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_listings);
  }

  @override
  Future<FoodListing> getFoodDetail(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _listings.firstWhere(
      (l) => l.id == id,
      orElse: () => _listings.first,
    );
  }

  @override
  Future<List<FoodReview>> getFoodReviews(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _mockReviews;
  }

  /// Favori durumunu senkron olarak değiştirir.
  /// ViewModel'ler bunu çağırır, ardından [getFeaturedListings] ile güncel listeyi alır.
  void toggleFavorite(String id) {
    final index = _listings.indexWhere((l) => l.id == id);
    if (index == -1) return;
    _listings[index] = _listings[index].copyWith(
      isFavorite: !_listings[index].isFavorite,
    );
  }

  /// Sadece favori olan ilanları döner.
  List<FoodListing> getFavorites() {
    return _listings.where((l) => l.isFavorite).toList();
  }

  // ─── Listings (mutable) ──────────────────────────────────────────────

  static final List<FoodListing> _listings = [
    // ── Sürpriz Kutu ─────────────────────────────────────
    FoodListing(
      id: 'sb_1',
      title: 'Süpriz Kutu Pasta',
      shopName: 'Murat Pastanesi',
      location: '679m | Murat Pastanesi',
      category: 'Pasta',
      timeRange: 'Bugün Al  15.30-19.00',
      imageUrl: 'assets/foodIcon/foodSide.png',
      price: 100,
      rating: 4.8,
      section: FoodSection.surpriseBox,
      shopLogoUrl: null,
      isFavorite: true,
      description:
          'Bu paket, gün sonunda satılamayan ama hâlâ taze olan çeşitli yiyeceklerden oluşur. '
          'Ne çıkacağı tamamen sürprizdir.',
      ingredients:
          'Paketin içeriğini kesin olarak söyleyemiyoruz çünkü sürpriz. '
          'Mekân, satılmamış ürünlerden bir seçim koyuyor. '
          'Alerjen veya içerik sorularınız varsa lütfen doğrudan mekâna sorunuz.',
      allergens: 'Gluten, Süt, Yumurta',
      latitude: 41.2048,
      longitude: 32.6218,
      deliveryStartTime: DateTime.now().subtract(const Duration(hours: 1)),
      deliveryEndTime: DateTime.now().add(const Duration(hours: 3)),
    ),
    FoodListing(
      id: 'sb_2',
      title: 'Karışık Simit Sepeti',
      shopName: 'Bodrum Fırın',
      location: '1.2km | Bodrum Fırın Şubesi',
      category: 'Ekmek & Pasta',
      timeRange: 'Bugün Al  08.00-11.00',
      imageUrl: 'assets/foodIcon/foodSide.png',
      price: 45,
      rating: 4.5,
      section: FoodSection.surpriseBox,
      shopLogoUrl: null,
      description:
          'Günün ilk saatlerinde hazırlanan taze simitler ve açma çeşitleri. '
          'Miktarlar her gün değişebilir.',
      ingredients: 'Buğday unu, susam, maya, tuz.',
      allergens: 'Gluten, Susam',
      latitude: 41.2060,
      longitude: 32.6235,
      deliveryStartTime: DateTime.now().add(const Duration(days: 2, hours: 2)),
      deliveryEndTime: DateTime.now().add(const Duration(days: 2, hours: 5)),
    ),
    FoodListing(
      id: 'sb_3',
      title: 'Mevsim Salata Kutusu',
      shopName: 'Yeşil Sofrası',
      location: '2.1km | Yeşil Sofrası Şubesi',
      category: 'Yemek',
      timeRange: 'Bugün Al  12.00-15.00',
      imageUrl: 'assets/foodIcon/foodSide.png',
      price: 70,
      rating: 4.6,
      section: FoodSection.surpriseBox,
      description: 'Mevsim sebzeleriyle hazırlanan taze ve sağlıklı salata kutusu.',
      ingredients: 'Marul, domates, salatalık, zeytinyağı, limon.',
      allergens: 'Yok',
      latitude: 41.2035,
      longitude: 32.6200,
    ),

    // ── Şimdi Al ─────────────────────────────────────────
    FoodListing(
      id: 'bn_1',
      title: 'Meyveli Pasta',
      shopName: 'Murat Pastanesi',
      location: '679m | Murat Pastanesi',
      category: 'Pasta',
      timeRange: 'Bugün Al  15.30-19.00',
      imageUrl: 'assets/foodIcon/foodSide.png',
      price: 100,
      rating: 4.5,
      section: FoodSection.buyNow,
      shopLogoUrl: null,
      isFavorite: true,
      description: 'Taze meyvelerle hazırlanan güzel bir pasta dilimi.',
      ingredients: 'Un, yumurta, şeker, tereyağı, çilek, muz.',
      allergens: 'Gluten, Süt, Yumurta',
      latitude: 41.2048,
      longitude: 32.6218,
      deliveryStartTime: DateTime.now().subtract(const Duration(hours: 1)),
      deliveryEndTime: DateTime.now().add(const Duration(hours: 3)),
    ),
    FoodListing(
      id: 'bn_2',
      title: 'Tavuklu Dürüm',
      shopName: 'Lezzet Büfe',
      location: '1.5km | Lezzet Büfe Merkez',
      category: 'Yemek',
      timeRange: 'Şimdi Al  11.00-22.00',
      imageUrl: 'assets/foodIcon/foodSide.png',
      price: 60,
      rating: 4.3,
      section: FoodSection.buyNow,
      description: 'Izgara tavuk, domates ve taze çeşitli soslarla hazırlanan lezzetli dürüm.',
      ingredients: 'Tavuk, lavaş, domates, mayonez, ketçap, marul.',
      allergens: 'Gluten, Yumurta (mayonez)',
      latitude: 41.2070,
      longitude: 32.6240,
    ),
    FoodListing(
      id: 'bn_3',
      title: 'Karışık Börek',
      shopName: 'Anadolu Börekçisi',
      location: '900m | Anadolu Börekçisi Şubesi',
      category: 'Ekmek & Pasta',
      timeRange: 'Şimdi Al  07.00-20.00',
      imageUrl: 'assets/foodIcon/foodSide.png',
      price: 35,
      rating: 4.7,
      section: FoodSection.buyNow,
      description: 'Peynirli, patatesli ve kıymalı börek seçenekleri. Her gün taze pişirilir.',
      ingredients: 'Yufka, peynir, patates, kıyma, tereyağı.',
      allergens: 'Gluten, Süt',
      latitude: 41.2055,
      longitude: 32.6210,
    ),

    // ── Bugün Popüler ─────────────────────────────────────
    FoodListing(
      id: 'tp_1',
      title: 'Meyveli Pasta',
      shopName: 'Murat Pastanesi',
      location: '679m | Murat Pastanesi',
      category: 'Pasta',
      timeRange: 'Bugün Al  15.30-19.00',
      imageUrl: 'assets/foodIcon/foodSide.png',
      price: 100,
      rating: 4.9,
      section: FoodSection.todayPopular,
      shopLogoUrl: null,
      description: 'En çok tercih edilen pasta. Taze meyveler ile süslü.',
      ingredients: 'Un, yumurta, şeker, tereyağı, çilek, muz, çikolata.',
      allergens: 'Gluten, Süt, Yumurta',
      latitude: 41.2048,
      longitude: 32.6218,
      deliveryStartTime: DateTime.now().subtract(const Duration(hours: 1)),
      deliveryEndTime: DateTime.now().add(const Duration(hours: 3)),
    ),
    FoodListing(
      id: 'tp_2',
      title: 'Tam Buğday Ekmek',
      shopName: 'Doğal Fırın',
      location: '3.0km | Doğal Fırın Merkez',
      category: 'Market',
      timeRange: 'Bugün Al  09.00-18.00',
      imageUrl: 'assets/foodIcon/foodSide.png',
      price: 25,
      rating: 4.4,
      section: FoodSection.todayPopular,
      description: 'Tam buğday unundan elde edilen sağlıklı ekmek. Katkısız, doğal.',
      ingredients: 'Tam buğday unu, su, tuz, maya.',
      allergens: 'Gluten',
      latitude: 41.2020,
      longitude: 32.6190,
    ),
  ];

  // ─── Mock Reviews ─────────────────────────────────────────────────────

  static final List<FoodReview> _mockReviews = [
    FoodReview(
      id: 'r_1',
      reviewerName: 'Derya Telli',
      avatarUrl: '',
      rating: 5.0,
      comment:
          'Yemek her zaman olduğu gibi hem üst katta hem alt katta iyi, ortam her zaman temiz. '
          'Her zaman üst katta oturuyorum, daha rahat bir ortamı var.',
      date: DateTime(2026, 2, 23, 9, 12),
      photoUrls: [
        'assets/foodIcon/foodSide.png',
        'assets/foodIcon/foodSide.png',
        'assets/foodIcon/foodSide.png',
        'assets/foodIcon/foodSide.png',
        'assets/foodIcon/foodSide.png',
      ],
    ),
    FoodReview(
      id: 'r_2',
      reviewerName: 'Derya Telli',
      avatarUrl: '',
      rating: 5.0,
      comment:
          'Yemek her zaman olduğu gibi hem üst katta hem alt katta iyi, ortam her zaman temiz. '
          'Her zaman üst katta oturuyorum, daha rahat bir ortamı var.',
      date: DateTime(2026, 2, 23, 9, 12),
      photoUrls: [
        'assets/foodIcon/foodSide.png',
        'assets/foodIcon/foodSide.png',
        'assets/foodIcon/foodSide.png',
        'assets/foodIcon/foodSide.png',
        'assets/foodIcon/foodSide.png',
      ],
    ),
  ];
}
