import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';

/// Yemek arama sonuçları için sıralama türleri.
enum FoodSortType {
  none,
  ratingAsc,
  priceAsc,
  distanceAsc;

  String get label {
    switch (this) {
      case FoodSortType.none:
        return LocaleKeys.sorting_defaultSort.tr();
      case FoodSortType.ratingAsc:
        return '${LocaleKeys.sorting_rating.tr()} (${LocaleKeys.sorting_lowToHigh.tr()})';
      case FoodSortType.priceAsc:
        return '${LocaleKeys.sorting_price.tr()} (${LocaleKeys.sorting_lowToHigh.tr()})';
      case FoodSortType.distanceAsc:
        return '${LocaleKeys.sorting_distance.tr()} (${LocaleKeys.sorting_nearToFar.tr()})';
    }
  }
}
