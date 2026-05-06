import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';

/// Gönüllü arama sonuçları için sıralama türleri.
enum VolunteerSortType {
  none,
  ratingAsc,
  distanceAsc;

  String get label {
    switch (this) {
      case VolunteerSortType.none:
        return LocaleKeys.sorting_defaultSort.tr();
      case VolunteerSortType.ratingAsc:
        return '${LocaleKeys.sorting_rating.tr()} (${LocaleKeys.sorting_lowToHigh.tr()})';
      case VolunteerSortType.distanceAsc:
        return '${LocaleKeys.sorting_distance.tr()} (${LocaleKeys.sorting_nearToFar.tr()})';
    }
  }
}
