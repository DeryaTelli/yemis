import 'package:yemis/utils/locale_keys.dart';
import 'package:easy_localization/easy_localization.dart';

/// Filtreleme seçenekleri — chip'lere karşılık gelir.
enum FoodFilter {
  all,
  food,
  breadPastry,
  market,
  buyNow;

  String get label {
    switch (this) {
      case FoodFilter.all:
        return LocaleKeys.filters_all.tr();
      case FoodFilter.food:
        return LocaleKeys.filters_food.tr();
      case FoodFilter.breadPastry:
        return LocaleKeys.filters_breadPastry.tr();
      case FoodFilter.market:
        return LocaleKeys.filters_market.tr();
      case FoodFilter.buyNow:
        return LocaleKeys.filters_buyNow.tr();
    }
  }
}
