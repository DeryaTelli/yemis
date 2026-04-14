/// Gönüllü arama sonuçları için sıralama türleri.
enum VolunteerSortType {
  none,
  ratingAsc,
  distanceAsc;

  String get label {
    switch (this) {
      case VolunteerSortType.none:
        return 'Varsayılan';
      case VolunteerSortType.ratingAsc:
        return 'Derecelendirme (Düşükten Yükseğe)';
      case VolunteerSortType.distanceAsc:
        return 'Mesafe (Yakından Uzağa)';
    }
  }
}
