import '../../models/business/business_listing_model.dart';

abstract class IBusinessService {
  /// Yeni bir sürpriz kutu (bag) oluşturur.
  Future<bool> createBag(Map<String, dynamic> data);

  /// İşletmenin tüm ilanlarını getirir.
  Future<List<BusinessListingModel>> getMyBags();

  /// Belirli bir ilanı siler.
  Future<bool> deleteBag(int id);

  /// Mevcut bir ilanı günceller.
  Future<bool> updateBag(int id, Map<String, dynamic> data);
}
