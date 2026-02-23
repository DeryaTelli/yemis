/// Filtreleme seçenekleri — chip'lere karşılık gelir.
enum FoodFilter {
  all('Hepsi'),
  food('Yemek'),
  breadPastry('Ekmek & Pasta'),
  market('Market'),
  buyNow('Şimdi Al');

  const FoodFilter(this.label);

  final String label;
}
