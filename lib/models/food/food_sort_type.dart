/// Yemek arama sonuçları için sıralama türleri.
enum FoodSortType {
  none,
  ratingAsc,
  priceAsc,
  distanceAsc;

  String get label {
    switch (this) {
      case FoodSortType.none:
        return 'Varsayılan';
      case FoodSortType.ratingAsc:
        return 'Derecelendirme (Düşükten Yükseğe)';
      case FoodSortType.priceAsc:
        return 'Fiyat (Düşükten Yükseğe)';
      case FoodSortType.distanceAsc:
        return 'Mesafe (Yakından Uzağa)';
    }
  }
}
